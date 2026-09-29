#!/bin/sh
# Create matching Ergo and The Lounge accounts with one initial password.
set +x
umask 077

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
. "$script_dir/chat-user-lib.sh"

[ "$#" -eq 1 ] || fail "Usage: $0 <lowercase-alias>"
check_alias "$1"
command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required.'
command -v base64 >/dev/null 2>&1 || fail 'base64 is required.'

check_lounge
if lounge_user_exists; then
    fail "The Lounge user $alias already exists."
fi

[ -r /dev/tty ] || fail 'Run this script from a terminal to enter the password.'
old_stty=$(stty -g </dev/tty) || fail 'Could not read terminal settings.'
trap 'stty "$old_stty" </dev/tty 2>/dev/null' 0
trap 'exit 1' 1 2 3 15
stty -echo </dev/tty || fail 'Could not hide password input.'
printf 'Password for %s: ' "$alias" >/dev/tty
IFS= read -r password </dev/tty || fail 'Could not read the password.'
printf '\nRepeat password: ' >/dev/tty
IFS= read -r confirmation </dev/tty || fail 'Could not read password confirmation.'
printf '\n' >/dev/tty
stty "$old_stty" </dev/tty || fail 'Could not restore terminal settings.'
trap - 0 1 2 3 15
[ "$password" = "$confirmation" ] || fail 'Passwords do not match.'
unset confirmation

case "$password" in
    ''|'*'|:*|*[![:graph:]]*) fail 'Use a nonempty printable ASCII password without spaces; it cannot be * or start with a colon.' ;;
esac
[ "${#password}" -le 400 ] || fail 'Password must be at most 400 bytes.'

load_oper_password
ergo_reply=$(ergo_request "SAREGISTER $alias $password") || fail 'Could not reach Ergo; no Lounge user was created.'
check_oper "$ergo_reply"
printf '%s\n' "$ergo_reply" | grep -F "Successfully registered account $alias" >/dev/null ||
    fail "Ergo did not confirm registration for $alias; no Lounge user was created."
unset oper_password ergo_reply
printf 'Ergo account %s created.\n' "$alias"

# The CLI accepts a password argument. Reading it from kubectl stdin keeps it
# out of the local command line and the Kubernetes exec request arguments; it
# is briefly present in the thelounge process arguments inside the pod.
lounge_reply=$(printf '%s\n' "$password" |
    kubectl -n "$namespace" exec -i "$lounge_deployment" -- sh -c '
        IFS= read -r password || exit 1
        exec thelounge add "--password=$password" --save-logs "$1"
    ' sh "$alias") || fail "The Lounge command failed. Ergo account $alias remains; finish Lounge creation manually."
unset password
unset lounge_reply
lounge_user_exists || fail "The Lounge user file was not created. Ergo account $alias remains."
printf 'The Lounge user %s created with the same initial password.\n' "$alias"
