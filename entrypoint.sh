#!/usr/bin/env bash
# entrypoint.sh
set -e

echo "Starting tailscaled in userspace networking mode..."
/usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 5

# Bring up Tailscale interface
if [[ -n "$TAILSCALE_AUTHKEY" ]]; then
  echo "Authenticating Tailscale with TAILSCALE_AUTHKEY..."
  tailscale up --authkey="$TAILSCALE_AUTHKEY" --hostname="${HOSTNAME:-flutter-web}"
else
  echo "No TAILSCALE_AUTHKEY set; starting Tailscale unauthenticated (requires manual login)..."
  tailscale up --hostname="${HOSTNAME:-flutter-web}"
fi

echo "Starting NGINX..."
exec nginx -g 'daemon off;'
