# Dockerfile

FROM alpine:3.17

# Install NGINX, Tailscale, and others
RUN apk update && \
    apk add --no-cache \
      nginx \
      ca-certificates \
      iptables ip6tables \
      curl \
      bash \
      openrc \
      # Tailscale (community package)
      tailscale

# Copy Flutter web build into NGINX directory
COPY build/web /usr/share/nginx/html

# Copy entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE 80

# Run our entrypoint (starts Tailscale + NGINX)
ENTRYPOINT ["/entrypoint.sh"]
