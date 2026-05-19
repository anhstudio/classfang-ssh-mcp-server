#!/bin/sh
set -eu

: "${SSH_HOST:?SSH_HOST is required}"
: "${SSH_USER:?SSH_USER is required}"
: "${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY is required}"
SSH_PORT="${SSH_PORT:-22}"

KEY_FILE="$(mktemp /tmp/sshkey.XXXXXX)"
trap 'rm -f "$KEY_FILE"' EXIT
printf '%s\n' "$SSH_PRIVATE_KEY" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

set -- \
  "--host=$SSH_HOST" \
  "--port=$SSH_PORT" \
  "--username=$SSH_USER" \
  "--privateKey=$KEY_FILE"

if [ -n "${SSH_PASSPHRASE:-}" ]; then
  set -- "$@" "--passphrase=$SSH_PASSPHRASE"
fi

if [ -n "${SSH_WHITELIST:-}" ]; then
  set -- "$@" "--whitelist=$SSH_WHITELIST"
fi

if [ -n "${SSH_BLACKLIST:-}" ]; then
  set -- "$@" "--blacklist=$SSH_BLACKLIST"
fi

if [ -n "${SSH_ALLOWED_REMOTE_PATHS:-}" ]; then
  set -- "$@" "--allowed-remote-paths=$SSH_ALLOWED_REMOTE_PATHS"
fi

exec node /app/build/index.js "$@"
