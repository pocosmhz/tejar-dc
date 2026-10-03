# IRC deployment notes

The `irc` namespace contains one Ergo StatefulSet and one The Lounge Deployment.
Ergo stores account registrations and seven days of message history on its RBD
volume. The Lounge keeps users and its own seven-day SQLite scrollback on a
separate RBD volume. Back up both PVCs before upgrades or disaster recovery.

Set the IRC and chat hostnames, DNS target, and network name in the encrypted
`pocosmhz/k8s/terraform.tfvars`. The chart `values.yaml` files contain example
values only. Terraform renders each chart's `*-values.tpl.yml` file with the
configured values when deploying.
The chat CNAME is a Terraform resource so the HTTPS certificate can be issued
before The Lounge application is deployed. The Lounge chart creates its web
Ingress when the application is deployed.

The public endpoints use the IRC and chat hostnames configured in the encrypted
`terraform.tfvars`. Both certificates are issued by
the existing cert-manager `letsencrypt` ClusterIssuer. The Lounge reaches Ergo's
ClusterIP directly while retaining the public hostname for TLS verification.
The only plaintext IRC listener is bound to `127.0.0.1` inside the Ergo pod for
operator bootstrap; no Service exposes it.

## Create and remove accounts

From `pocosmhz/k8s`, use `./scripts/add-chat-user.sh alice` to create matching
Ergo and The Lounge users with the same initial password. Use
`./scripts/del-chat-user.sh alice` to unregister Ergo first and then remove the
Lounge user. Password changes after creation do not synchronize. Ergo preserves
the unregistered account name as reserved, and The Lounge keeps old log files.

For manual bootstrap or recovery:

Retrieve the generated Ergo operator password:

```sh
kubectl -n irc get secret ergo-oper-credentials -o jsonpath='{.data.password}' | base64 -d
```

Then open an IRC session from *inside* the Ergo pod:

```sh
kubectl -n irc exec -it ergo-0 -c ergo -- nc 127.0.0.1 6667
```

Enter these IRC protocol lines, replacing the placeholder credentials:

```text
NICK bootstrap
USER bootstrap 0 * :Bootstrap administrator
OPER admin <operator-password>
PRIVMSG NickServ :SAREGISTER alice <initial-account-password>
```

Public account registration is disabled. Network clients must authenticate
with SASL, or use `PASS alice:password` for legacy clients without SASL. The
account check accepts both paths in pinned Ergo v2.19.1.

Create each person's separate The Lounge web account with:

```sh
kubectl -n irc exec -it deploy/thelounge -- thelounge add alice
```

The Lounge web and Ergo account passwords are independent after creation. When
someone changes their Ergo password, they must update the saved IRC network
password in The Lounge too.

## Certificates

The Ergo TLS Secret is mounted as a normal Kubernetes Secret volume. A small
sidecar detects renewed certificate/key content and sends Ergo `SIGHUP` so new
connections use the renewed certificate. The Lounge HTTPS certificate is used
by Traefik directly.
