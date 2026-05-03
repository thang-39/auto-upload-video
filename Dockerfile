# STAGE 1: Download static binaries + musl-compatible Python
FROM alpine:latest AS builder
RUN apk add --no-cache curl xz python3

# Bundle musl-linked Python3 into a tarball (preserves symlinks, version-agnostic)
# This bypasses the apk restriction in the hardened final image
RUN PYVER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")') && \
    tar czf /tmp/python3-bundle.tar.gz \
      /usr/bin/python3 \
      /usr/bin/python${PYVER} \
      /usr/lib/python${PYVER} \
      $(find /usr/lib -maxdepth 1 -name "libpython*.so*") \
    && echo "Bundled Python ${PYVER}"

# 1. Download yt-dlp Python script (requires python3, no PyInstaller/glibc issues)
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && chmod a+rx /usr/local/bin/yt-dlp

# 2. Download ffmpeg static binary (John Van Sickle builds)
RUN curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz \
    && tar -xJf /tmp/ffmpeg.tar.xz -C /tmp \
    && mv /tmp/ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/ffmpeg \
    && mv /tmp/ffmpeg-*-amd64-static/ffprobe /usr/local/bin/ffprobe \
    && chmod a+rx /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# STAGE 2: Official n8n image (The hardened one)
FROM n8nio/n8n:latest

USER root

# Extract musl-compatible Python3 from builder (no apk needed)
COPY --from=builder /tmp/python3-bundle.tar.gz /tmp/python3-bundle.tar.gz
RUN tar xzf /tmp/python3-bundle.tar.gz -C / && rm /tmp/python3-bundle.tar.gz

# Copy the static binaries from the builder
COPY --from=builder /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=builder /usr/local/bin/ffprobe /usr/local/bin/ffprobe

# Ensure they are executable
RUN chmod +x /usr/local/bin/yt-dlp /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Switch back to the standard 'node' user that n8n expects
USER node