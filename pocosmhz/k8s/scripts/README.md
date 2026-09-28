# Chat account scripts

`add-chat-user.sh` creates an Ergo account and then a user in The Lounge with the
same initial password. `del-chat-user.sh` unregisters the Ergo account and then
removes the Lounge user. `list-chat-user.sh` shows both sets of names without
changing either service.

## Requirements

- On the machine running the scripts: `/bin/sh`, `kubectl`, `base64`, and the
  standard `dirname`, `grep`, `sed`, `tr`, and `stty` utilities. Run the add
  script from a terminal so it can prompt for the password without echoing it.
- A working `kubectl` context with permission to read the
  `ergo-oper-credentials` Secret and execute commands in the Ergo and The Lounge
  pods in the `irc` namespace.
- In the Ergo container: `nc` with `-w` support. The scripts use it through
  `kubectl exec` to reach Ergo's local-only IRC listener; no local `nc`
  installation is needed.
- The Ergo and The Lounge workloads must be running. The Lounge container must
  provide the `thelounge` command.

From `pocosmhz/k8s`, run:

```sh
./scripts/add-chat-user.sh alice
./scripts/del-chat-user.sh alice
./scripts/list-chat-user.sh
```

The list script shows Ergo's registered nicknames and The Lounge's web users in
separate sections. This deployment forces an authenticated IRC nickname to
equal its account name and permits no additional grouped nicknames, so the
Ergo list represents the current account names. See Ergo's [NickServ LIST
implementation](https://github.com/ergochat/ergo/blob/v2.19.1/irc/nickserv.go)
and [The Lounge user documentation](https://thelounge.chat/docs/users).

Aliases must start with a lowercase letter, use only lowercase letters,
digits, `_`, or `-`, and be no longer than 32 characters. See the [Kubernetes
README](../README.md#ergo-irc) for account behavior and deletion effects.
