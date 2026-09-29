#!/bin/sh
# List Ergo registered nicknames and The Lounge web users.
set +x
umask 077

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
. "$script_dir/chat-user-lib.sh"

[ "$#" -eq 0 ] || fail "Usage: $0"
command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required.'
command -v base64 >/dev/null 2>&1 || fail 'base64 is required.'

load_oper_password
ergo_reply=$(ergo_request LIST) || fail 'Could not reach Ergo.'
unset oper_password
check_oper "$ergo_reply"
printf '%s\n' "$ergo_reply" | grep -F 'End of NickServ LIST' >/dev/null ||
    fail 'Ergo did not return a complete NickServ list.'
ergo_names=$(printf '%s\n' "$ergo_reply" |
    sed -n "s/^:NickServ[^ ]* NOTICE $admin_nick :    //p" | tr -d '\r')
unset ergo_reply

lounge_reply=$(kubectl -n "$namespace" exec "$lounge_deployment" -- thelounge list 2>/dev/null) ||
    fail 'Could not list The Lounge users.'
printf '%s\n' "$lounge_reply" | grep -F '[INFO] Users:' >/dev/null ||
    fail 'The Lounge did not return a user list.'
lounge_names=$(printf '%s\n' "$lounge_reply" |
    sed -n 's/^.*\[INFO\] [0-9][0-9]*\. //p')
unset lounge_reply

printf 'Ergo registered nicknames:\n'
if [ -n "$ergo_names" ]; then
    printf '%s\n' "$ergo_names" | sed 's/^/  /'
else
    printf '  (none)\n'
fi
printf 'The Lounge users:\n'
if [ -n "$lounge_names" ]; then
    printf '%s\n' "$lounge_names" | sed 's/^/  /'
else
    printf '  (none)\n'
fi
