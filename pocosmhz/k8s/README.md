# k8s
This part of the IaC tree takes care about Kubernetes clusters **and not** their underlying infrastructure, OS or else.

## Provisioning clusters
By adding an element to the `k8s_clusters` var with the required data (see var definition), you're on your way.

You need different providers for different Kubernetes cluster, that is. See the `providers.tf` and `providers.tofu` files, and Terraform / OpenTofu documentation on how to build and use aliases with providers.

A recommended way of creating assets for the cluster is to name Terraform / Tofu files with a prefix consisting in the Kubernetes cluster name. That is nice and easy to maintain.

### Configuration structure
Every cluster element inside `k8s_clusters` var defines a certain amount of required information on mandatory or optional resources inside that cluster.

A brief, non-comprehensive description, would be:
- Node list (needed for certain things)
- Shared storage with Ceph CSI
- Traefik ingress controller
- Kube-VIP load balancer
- cert-manager
- external-dns
- Prometheus (kube-prometheus-stack)
- Providers (see below)

## Providers
In the `providers` section of every cluster definition we'll include parameters needed to configure external resources like DNS entries with `external-dns` or things like that. An example of that would be using Google Cloud DNS for that purpose.

You are responsible of mapping the parameters of providers like Google Cloud, AWS or the like, with the files `providers.tf` / `providers.tofu` and creating the required provider aliases.

### Google Cloud provider
To use your gcloud credentials, run `gcloud auth application-default login`.

Make sure the selected credentials have permissions to access every project listed on all GCP projects used by your resources.

See https://cloud.google.com/docs/authentication/external/set-up-adc for more information

## kube-vip

kube-vip uses Helm chart 0.11.1 with the container image explicitly pinned to
`ghcr.io/kube-vip/kube-vip:v1.2.4` in
`source/helm/kube-vip/kube-vip-values.tpl.yml`, overriding the chart's default
v1.2.3 image. This includes the fix for
[endpoint watch recovery (#1685)](https://github.com/kube-vip/kube-vip/issues/1685):
a terminal watch error could stop watching endpoints and remove the Service VIP
without recovering. Review this image pin alongside the chart's default image
and release notes during future upgrades.

## Traefik ingress settings

Traefik chart 41.6.1 runs in the `traefik` namespace, using the configured
Deployment or DaemonSet and a kube-vip LoadBalancer Service. Public ports are
80 (HTTP and cert-manager HTTP-01), 443 (HTTPS), and 6697 (IRC TLS passthrough).
Applications and the cert-manager solver explicitly select ingress class
`traefik`; the class is not marked as the cluster default.

The `traefik` configuration block controls `kind`, `service_type` (normally
`LoadBalancer`), `load_balancer_ip`, `load_balancer_class`, and
`external_traffic_policy`. `ClusterIP` is available for staging without claiming
the public VIP or publishing the IRC DNS annotation. Keep the configured
traffic policy during controller migrations; `Local` requires kube-vip service
election and ready controller endpoints on the elected node. PROXY protocol is
not enabled. The current `Cluster` policy can obscure client source addresses.

HTTP redirects to HTTPS except for `/.well-known/acme-challenge/`, which is
handled by cert-manager solver Ingresses. Traefik consumes the existing HTTPS
Secrets; cert-manager continues to own issuance and renewal. Ergo terminates
IRC TLS and retains its certificate reload sidecar. The IRC TCP route accepts
clients with or without SNI. Forgejo uses a 1 GiB buffering middleware; requests
above 1 MiB can spill to the controller's temporary disk volume.

The Helm release installs Traefik CRDs and manages the IRC route and Forgejo
middleware through `extraObjects`, avoiding OpenTofu plan-time discovery of
new custom-resource schemas. Helm does not automatically upgrade or remove
CRDs. For future chart upgrades, review the pinned chart's CRD changes and
apply the updated Traefik CRDs before upgrading the release. Do not delete
CRDs during upgrades: deleting them deletes their custom resources.

For a controller migration, stage the new controller as ClusterIP, temporarily
allow both controller namespaces in application network policies, and test
HTTPS, HTTP-01, uploads, WebSockets, and IRC before moving the VIP. Release the
old controller's LoadBalancer address before assigning it to the replacement.
Verify public access and issuance before uninstalling the old release. Existing
IRC connections may reconnect during the handover.

## external-dns

`onprem01_dns.tf` pins the official Kubernetes SIGs external-dns chart 1.23.0
(application 0.23.0), replacing Bitnami chart 9.0.3 / application 0.18.0. The
full upstream values file remains at
`source/helm/external-dns/external-dns-values.tpl.yml`, with the existing
template variables supplying the Google project, credential Secret, domain
filter, policy, service account and metrics settings.

The controller watches Services and Ingresses, reuses the Google credential
Secret and Kubernetes `default` service account, and retains TXT owner
`default` and policy `sync`. Keep `enable-legacy-annotation-prefix` enabled
while application manifests use `external-dns.alpha.kubernetes.io/*`; version
0.22 changed the default annotation prefix. The official chart uses `Recreate`
to avoid overlapping DNS writers. Existing DNS records remain served while
the controller restarts.

The NetworkPolicy and PodDisruptionBudget are managed separately in OpenTofu
because the official chart does not provide them. The replacement policy is
created before the Helm migration, preserving ingress on TCP 7979 and
unrestricted egress. The replacement budget is created after Helm removes
the old one, retaining `maxUnavailable: 1` without overlapping budgets.

The 0.19–0.23 release notes require no intermediate data migration for this
Google provider, TXT registry and Service/Ingress configuration. Before
applying the chart migration, back up the DNS zone and run the target image
with the rendered arguments plus `--dry-run --once`. Check for unexpected
record creation, deletion, target or ownership changes, then apply the
OpenTofu plan and verify reconciliation and public records. See the
[official upgrade playbook](https://kubernetes-sigs.github.io/external-dns/latest/docs/version-update-playbook/).

## Prometheus stack

`onprem01_prometheus.tf` pins kube-prometheus-stack chart 91.9.0, including
Prometheus 3.15.0, Prometheus Operator 0.94.1, and Grafana 13.2.3. The full
upstream chart values remain in
`source/helm/prometheus/kube-prometheus-stack-values.tpl.yml`, with the
`prom_conf` variables supplying Grafana credentials, ingress and persistence
settings, and Prometheus storage size. Grafana and Prometheus retain their
existing Ceph RBD volumes; Grafana uses a StatefulSet.

The chart's `crds.upgradeJob` runs before upgrades to apply the matching
Operator CRDs with server-side apply. `forceConflicts` allows the hook to own
schema fields originally installed by the OpenTofu Helm provider. Do not delete
CRDs during upgrades, because that also deletes their monitoring resources.

The migration from chart 75.10.0 was performed through chart 83.7.0 / Grafana
12.4.3, updating installed plugins before moving to Grafana 13. The supplied
Prometheus overview dashboard changed UID; its obsolete duplicate registration
was cleaned through file provisioning and the current dashboard reprovisioned.
Back up the Grafana database and plugins and review the
[stack upgrade notes](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/UPGRADE.md)
and [Grafana upgrade guide](https://grafana.com/docs/grafana/latest/upgrade-guide/)
before future upgrades. The new chart uses distroless images and authenticates
control-plane scrapes through its service-account token Secret and the
`kube-root-ca.crt` ConfigMap, replacing filesystem token and CA references.

## cert-manager

The cert-manager CRDs are managed by `kubernetes_manifest` in
`onprem01_certs.tf`, separately from the Helm release. Keep `crds.enabled`
false in `source/helm/cert-manager/cert-manager-values.tpl.yml` so Helm does
not take ownership of them.

For future upgrades:

1. Check the [supported releases](https://cert-manager.io/docs/releases/),
   [upgrade instructions](https://cert-manager.io/docs/installation/upgrade/),
   and release notes for every minor version between the installed and target
   versions. Upgrade one minor version at a time, using its latest patch.
2. Back up the cert-manager custom resources, the ACME account Secret in the
   `cert-manager` namespace, and the TLS Secrets used by existing Certificates.
   Store these backups privately because the Secret exports contain key material.
3. For each version, update both the CRD download URL and Helm chart version in
   `onprem01_certs.tf`. Replace the values template with that version's complete
   chart `values.yaml`, retaining its comments, then reapply the local namespace
   and `prometheus_enabled` template substitutions. Compare the old and new CRD
   names. Existing CRDs should update in place; do not delete them, since doing
   so also deletes their custom resources.
4. Run `tofu plan -target=helm_release.cert_manager -out=/tmp/cert-manager.tfplan`.
   Check that it updates the CRDs and Helm release without replacing or
   destroying CRDs, then run `tofu apply /tmp/cert-manager.tfplan`. The Helm
   release depends on the CRDs, so they are updated first.
5. After each step, confirm the controller, webhook, and cainjector Deployments
   have rolled out and the ClusterIssuer and Certificates remain Ready. Run a
   full `tofu plan` after the final step to check for remaining changes.

## Elasticsearch and Kibana

ECK operator 3.5.0 manages Elasticsearch `es01` and Kibana in the
`elastic-system` namespace. Both run version 8.19.22; Kibana inherits the
Elasticsearch version and is enabled by the optional `kibana` object under
`elasticsearch.clusters.es01`. Access Kibana at
[kibana.k8s.example.com](https://kibana.k8s.example.com). The administrator
username is `elastic`, with the same password for Elasticsearch and Kibana.
With `kubectl` configured for `onprem01`, retrieve it from ECK's Secret:

```sh
kubectl -n elastic-system get secret es01-es-elastic-user -o jsonpath='{.data.elastic}' | base64 -d
printf '\n'
```

## Ergo IRC

The `irc` namespace runs Ergo with TLS on port 6697. Its hostname, network name,
and storage settings come from the encrypted `terraform.tfvars`; the checked-in
variable and chart defaults are examples. cert-manager supplies the IRC
certificate, and Ergo stores accounts and message history on an RBD volume.
The public listener requires an existing account; users cannot register their
own accounts. Clients can authenticate with SASL or the legacy `PASS
<account>:<password>` form.

To create matching Ergo and The Lounge accounts, run the scripts from this
directory. See the [scripts README](scripts/README.md) for requirements,
including `kubectl` access and `nc` inside the Ergo container:

```sh
./scripts/add-chat-user.sh alice
./scripts/del-chat-user.sh alice
./scripts/list-chat-user.sh
```

Ergo and The Lounge keep separate account lists. These scripts try to keep
them aligned, while `list-chat-user.sh` reads and displays each list
independently. A partial failure or a manual change can leave different users
in the two services.

The add script prompts twice for one password and creates the Ergo account
first. It creates the Lounge user only after Ergo confirms success. Passwords
are the same initially; later password changes in either application do not
sync. If the second step fails, the script reports the partial result for
manual recovery. Aliases must be lowercase, start with a letter, contain only
letters, digits, `_`, or `-`, and be at most 32 characters.

The delete script asks for confirmation, unregisters the Ergo account, then
removes the Lounge user. Ergo keeps an unregistered account name reserved, and
unregistration removes any channels that account founded. Transfer channel
ownership first if needed. The Lounge `remove` command leaves its old log files
on disk. See the [Ergo manual](https://github.com/ergochat/ergo/blob/master/docs/MANUAL.md)
and [The Lounge user guide](https://thelounge.chat/docs/users).

For manual bootstrap or recovery, retrieve the generated operator password
from the cluster Secret, then connect to the local-only listener inside the
Ergo pod:

```sh
kubectl -n irc get secret ergo-oper-credentials -o jsonpath='{.data.password}' | base64 -d
kubectl -n irc exec -it ergo-0 -c ergo -- nc 127.0.0.1 6667
```

Send these IRC protocol lines, replacing the placeholders:

```text
NICK bootstrap
USER bootstrap 0 * :Bootstrap administrator
OPER admin <operator-password>
PRIVMSG NickServ :SAREGISTER alice <initial-account-password>
```

Repeat `SAREGISTER` for each approved IRC account. The operator password grants
server administration; do not give it to ordinary users. For account and
operator commands, see the [Ergo manual](https://github.com/ergochat/ergo/blob/master/docs/MANUAL.md)
and the in-server `NickServ HELP SAREGISTER` command.

### BitchX in 2026
In order to compile and use BitchX in 2026 under Debian 13 you can follow these brief directions:

0. Download BitchX (see project's page at ):
    ```Shell
    $ mkdir source
    $ cd source
    $ wget -c https://deac-fra.dl.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz
    --2026-09-26 16:05:57--  https://deac-fra.dl.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz
    Resolving deac-fra.dl.sourceforge.net (deac-fra.dl.sourceforge.net)... 37.203.33.33
    Connecting to deac-fra.dl.sourceforge.net (deac-fra.dl.sourceforge.net)|37.203.33.33|:443... connected.
    HTTP request sent, awaiting response... 301 Moved Permanently
    Location: https://downloads.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz [following]
    --2026-09-26 16:05:58--  https://downloads.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz
    Resolving downloads.sourceforge.net (downloads.sourceforge.net)... 104.18.12.149, 104.18.13.149, 2606:4700::6812:d95, ...
    Connecting to downloads.sourceforge.net (downloads.sourceforge.net)|104.18.12.149|:443... connected.
    HTTP request sent, awaiting response... 302 Found
    Location: https://altushost-net.dl.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz?viasf=1&fid=b764f13a57842aa1&e=1790517958&st=kfAwDyOFhYj4W8-IuzudBw [following]
    --2026-09-26 16:05:58--  https://altushost-net.dl.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz?viasf=1&fid=b764f13a57842aa1&e=1790517958&st=kfAwDyOFhYj4W8-IuzudBw
    Resolving altushost-net.dl.sourceforge.net (altushost-net.dl.sourceforge.net)... 79.142.66.6
    Connecting to altushost-net.dl.sourceforge.net (altushost-net.dl.sourceforge.net)|79.142.66.6|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 2549182 (2.4M) [application/x-gzip]
    Saving to: ‘bitchx-1.2.1.tar.gz’

    bitchx-1.2.1.tar.gz                             100%[=====================================================================================================>]   2.43M  6.31MB/s    in 0.4s

    2026-09-26 16:05:59 (6.31 MB/s) - ‘bitchx-1.2.1.tar.gz’ saved [2549182/2549182]
    ```

1. Update the system and install build dependencies:
    ```Shell
    $ sudo apt install build-essential libncurses5-dev libssl-dev
    [sudo] password for manuelmc:
    Note, selecting 'libncurses-dev' instead of 'libncurses5-dev'
    build-essential is already the newest version (12.12).
    libncurses-dev is already the newest version (6.5+20250216-2).
    libssl-dev is already the newest version (3.5.7-1~deb13u2).
    Summary:
    Upgrading: 0, Installing: 0, Removing: 0, Not Upgrading: 0

    ```

2. In order to have proper SSL support, fix the configuration script:
    ```Shell
    $ tar xzf bitchx-1.2.1.tar.gz
    $ cd bitchx-1.2.1/
    $ cp configure configure.original
    $ cp configure.in configure.in.original
    $ sed -i 's/SSLeay/ERR_get_error/g' configure configure.in
    ```
    We've made a copy of the original file just in case, and replaced the SSL configuration part.

3. Now we configure it with SSL and IPv6 support:
    ```Shell
    $ ./configure \
    --with-ssl \
    --enable-ipv6 \
    CFLAGS="-g -O2 -fno-strict-aliasing -Wall -fcommon"
    ```
    Then, verify the options
    ```Shell
    $ grep -E 'HAVE_LIB(SSL|CRYPTO)' include/defs.h
    #define HAVE_LIBCRYPTO 1
    #define HAVE_LIBSSL 1
    $ grep -i ipv6 include/defs.h
    /* Define this if you want IPV6 support. */
    #define IPV6 1
    ```

4. Compile the application:
    ```Shell
    $ make -j"$(nproc)" 2>&1 | tee build.log
    ```

5. Verify that it worked:
    ```Shell
    $ echo $?
    0
    $ grep -m 1 '^gcc .* -c ' build.log
    gcc -I. -I/home/manuelmc/source/bitchx-1.2.1/include -I../include -I. -I./include -DHAVE_CONFIG_H -g -O2 -fno-strict-aliasing -Wall -fcommon  -c wserv.c
    $ file source/BitchX
    source/BitchX: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=97b8b22a91fe2ffd6bf2212d49f6c27a8ca99af4, for GNU/Linux 3.2.0, with debug_info, not stripped
    $ ldd source/BitchX | grep -E 'ssl|crypto'
        libssl.so.3 => /lib/x86_64-linux-gnu/libssl.so.3 (0x00007f35e891b000)
        libcrypto.so.3 => /lib/x86_64-linux-gnu/libcrypto.so.3 (0x00007f35e8200000)
    ```
6. Install it:
    ```Shell
    $ sudo make install
    ```

7. Use it:
    ```Shell
    $ BitchX -ssl -n myuser 'irc.example.com,6697,myuser:mypassword'
    ```

BitchX uses commas to separate the server, port, and server-password fields
here. Ergo expects the server password in `account:password` form; using colons
for BitchX's fields would split that value before it reaches Ergo.

## The Lounge

The Lounge is the web client for the IRC network. Its chart creates the HTTPS
Ingress and stores user settings and scrollback on a separate RBD volume. The
configuration sets `public: false`, so visitors see a login page and cannot
create their own accounts. The configured Ergo service remains the default IRC
network, while users can enter other servers when adding a network.

The account script above creates a web account at the same time as the Ergo
account. To create one manually after the Deployment is ready:

```sh
kubectl -n irc exec -it deploy/thelounge -- thelounge add alice
```

The command prompts for a web password. To list users, reset a password, or
remove a user, run `thelounge list`, `thelounge reset <name>`, or `thelounge
remove <name>` in the same Deployment. Changes take effect without restarting
The Lounge. Each person also needs an Ergo account and should enter those IRC
credentials in The Lounge. The web and IRC passwords remain independent even
when the account script sets them to the same initial value.

See the official [The Lounge user guide](https://thelounge.chat/docs/users)
for account management and [configuration reference](https://thelounge.chat/docs/configuration)
for private mode and network settings.

The chart's `branding.enabled` setting uses `files/pocosmhz_white.svg` for the
loading screen, sign-in page, and application sidebar in both light and dark
themes. A cropped vector P also replaces the browser, home screen, and Helm
chart icons. To use another full logo, place it in the chart's `files/` directory and set
`branding.logoFile` to its chart-relative path. Set `branding.enabled: false`
to use The Lounge's own logos. The optional `branding.stylesheet` value appends
CSS to The Lounge's default theme; it is empty by default. The logo mounts use
asset paths from the pinned The Lounge image version, so check them before
upgrading that image.
