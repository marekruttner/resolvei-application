# Stage 1: Build the Flutter web application
FROM debian:stable-slim AS build-env

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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

# Enable Flutter web support
RUN flutter config --enable-web

# Pre-download development binaries
RUN flutter precache

# Run flutter doctor
RUN flutter doctor -v

# Create and set the working directory
RUN mkdir /app
WORKDIR /app

# Copy application files
COPY . /app

# Get Flutter dependencies
RUN flutter pub get

# Build the Flutter web application
RUN flutter build web --release --web-renderer html

# Stage 2: Serve the application using NGINX
FROM nginx:stable-alpine

# Copy the build output to NGINX's html directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
