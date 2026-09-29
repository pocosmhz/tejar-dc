#!/bin/sh
# Unregister an Ergo account, then remove its matching The Lounge user.
set +x
umask 077

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
. "$script_dir/chat-user-lib.sh"

[ "$#" -eq 1 ] || fail "Usage: $0 <lowercase-alias>"
check_alias "$1"
command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required.'
command -v base64 >/dev/null 2>&1 || fail 'base64 is required.'

check_lounge
load_oper_password

# Asking without a code is read-only: Ergo returns the confirmation command.
ergo_reply=$(ergo_request "UNREGISTER $alias") || fail 'Could not reach Ergo.'
check_oper "$ergo_reply"
ergo_exists=yes
if printf '%s\n' "$ergo_reply" | grep -F 'Invalid account name' >/dev/null; then
    ergo_exists=no
else
    confirmation_line=$(printf '%s\n' "$ergo_reply" | tr -d '\r' |
        sed -n '/To confirm, run this command: \/NS UNREGISTER / { p; q; }')
    [ -n "$confirmation_line" ] || fail 'Ergo did not provide an UNREGISTER confirmation code.'
    confirmation_command=${confirmation_line#*'/NS UNREGISTER '}
    confirmation_account=${confirmation_command%% *}
    confirmation_code=${confirmation_command#* }
    canonical_account=$(printf '%s' "$confirmation_account" | tr '[:upper:]' '[:lower:]')
    [ "$canonical_account" = "$alias" ] || fail 'The Ergo confirmation names a different account.'
    case "$confirmation_code" in
        ''|*[!a-zA-Z0-9]*) fail 'Ergo returned an unexpected confirmation code.' ;;
    esac
fi

if [ "$ergo_exists" = no ] && ! lounge_user_exists; then
    printf 'Neither Ergo nor The Lounge has user %s.\n' "$alias"
    exit 0
fi

printf 'Remove %s from Ergo and The Lounge? [y/N] ' "$alias" >&2
IFS= read -r answer || exit 1
case "$answer" in
    y|Y|yes|YES) ;;
    *) printf 'Cancelled.\n' >&2; exit 0 ;;
esac

if [ "$ergo_exists" = yes ]; then
    ergo_reply=$(ergo_request "UNREGISTER $confirmation_account $confirmation_code") ||
        fail 'Could not finish Ergo unregistration; The Lounge user was kept.'
    check_oper "$ergo_reply"
    printf '%s\n' "$ergo_reply" | grep -F "Successfully unregistered account $confirmation_account" >/dev/null ||
        fail 'Ergo did not confirm unregistration; The Lounge user was kept.'
    printf 'Ergo account %s unregistered.\n' "$confirmation_account"
else
    printf 'Ergo account %s was already absent.\n' "$alias"
fi
unset oper_password ergo_reply confirmation_code

if lounge_user_exists; then
    lounge_reply=$(kubectl -n "$namespace" exec "$lounge_deployment" -- thelounge remove "$alias") ||
        fail "The Lounge command failed. Ergo account $alias is no longer active; remove the Lounge user manually."
    unset lounge_reply
    if lounge_user_exists; then
        fail "The Lounge user file still exists for $alias."
    fi
    printf 'The Lounge user %s removed.\n' "$alias"
else
    printf 'The Lounge user %s was already absent.\n' "$alias"
fi
