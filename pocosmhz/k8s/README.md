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
- Nginx ingress controller
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

## Nginx ingress settings
You can either set `externalTrafficPolicy` to `Local` and preserve source IP addresses or set to `""` and that would mean `Cluster`.

When you use a `LoadBalancer` service for that, together with `kube-vip`, you must take into account that

1. Read https://kube-vip.io/docs/usage/kubernetes-services/#external-traffic-policy-kube-vip-v050
2. `svc_election` must be `true`.

You can use `externalTrafficPolicy` to `Cluster` with any other service besides the ingress controller service and that will be fine.

Also, in order to get access to source IP address you must enable `use_proxy_protocol` setting on Nginx ingress.

And also, use the [unofficial solution](https://hub.docker.com/r/shilazi/kube-vip) suggested [here](https://github.com/kube-vip/kube-vip/issues/1027#issuecomment-2750374646).

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
```

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
create their own accounts. It also locks the IRC network address and TLS
settings to the configured Ergo service.

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
