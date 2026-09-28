# Shared functions for add-chat-user.sh and del-chat-user.sh.
# This file is sourced by /bin/sh; it is not run directly.

LC_ALL=C
export LC_ALL

namespace=irc
ergo_pod=ergo-0
lounge_deployment=deploy/thelounge
lounge_users=/var/opt/thelounge/users
admin_nick=chatadmin$$

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

check_alias() {
    alias=$1
    case "$alias" in
        [a-z]*) ;;
        *) fail 'Alias must start with a lowercase letter.' ;;
    esac
    case "$alias" in
        *[!a-z0-9_-]*) fail 'Alias may contain only lowercase letters, digits, underscores, and hyphens.' ;;
    esac
    [ "${#alias}" -le 32 ] || fail 'Alias must be at most 32 characters.'
}

check_lounge() {
    kubectl -n "$namespace" exec "$lounge_deployment" -- test -d "$lounge_users" ||
        fail 'The Lounge user directory is unavailable.'
}

lounge_user_exists() {
    exists=$(kubectl -n "$namespace" exec "$lounge_deployment" -- sh -c '
        if [ -f "$1" ]; then printf yes; else printf no; fi
    ' sh "$lounge_users/$alias.json") || fail 'Could not check The Lounge user file.'
    case "$exists" in
        yes) return 0 ;;
        no) return 1 ;;
        *) fail 'The Lounge returned an unexpected user-file status.' ;;
    esac
}

load_oper_password() {
    oper_password=$(kubectl -n "$namespace" get secret ergo-oper-credentials -o 'jsonpath={.data.password}' | base64 -d) ||
        fail 'Could not read the Ergo operator password.'
    [ -n "$oper_password" ] || fail 'The Ergo operator password is empty.'
}

ergo_request() {
    request=$1
    {
        printf 'NICK %s\r\n' "$admin_nick"
        printf 'USER chatadmin 0 * :Chat account administrator\r\n'
        printf 'OPER admin %s\r\n' "$oper_password"
        printf 'PRIVMSG NickServ :%s\r\n' "$request"
        printf 'QUIT :account administration complete\r\n'
    } | kubectl -n "$namespace" exec -i "$ergo_pod" -c ergo -- nc -w 5 127.0.0.1 6667
}

check_oper() {
    printf '%s\n' "$1" | grep -F " 381 $admin_nick " >/dev/null ||
        fail 'Ergo did not accept the operator login.'
}
