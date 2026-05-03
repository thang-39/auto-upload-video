# STAGE 1: Download static binaries
FROM alpine:latest AS builder
RUN apk add --no-cache curl xz

# 1. Download yt-dlp static binary
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && chmod a+rx /usr/local/bin/yt-dlp

# 2. Download ffmpeg static binary (John Van Sickle builds)
# We use the 'release' build which is stable and contains all codecs
RUN curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz \
    && tar -xJf /tmp/ffmpeg.tar.xz -C /tmp \
    && mv /tmp/ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/ffmpeg \
    && mv /tmp/ffmpeg-*-amd64-static/ffprobe /usr/local/bin/ffprobe \
    && chmod a+rx /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# STAGE 2: Official n8n image (The hardened one)
FROM n8nio/n8n:latest

# We must be root to copy files into /usr/local/bin
USER root

# Copy the static binaries from the builder
COPY --from=builder /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=builder /usr/local/bin/ffprobe /usr/local/bin/ffprobe

# Ensure they are executable
RUN chmod +x /usr/local/bin/yt-dlp /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Switch back to the standard 'node' user that n8n expects
USER node