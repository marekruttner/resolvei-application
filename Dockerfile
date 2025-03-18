# Stage 1: Build the Flutter web application
FROM debian:stable-slim AS build-env

# Use noninteractive mode and allow running Flutter as root
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_ALLOW_ROOT=true

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the Flutter repository
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set Flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Switch to the stable channel and upgrade
RUN flutter channel stable && flutter upgrade

# Enable Flutter web support and pre-cache required binaries
RUN flutter config --enable-web
RUN flutter precache
RUN flutter doctor -v

# Create and set the working directory
WORKDIR /app
COPY . /app

# Get Flutter dependencies
RUN flutter pub get

# Build the Flutter web application (remove --web-renderer if unsupported)
RUN flutter build web --release

# Stage 2: Serve the application using NGINX
FROM nginx:stable-alpine

# Copy the Flutter web build output into NGINX's web directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
