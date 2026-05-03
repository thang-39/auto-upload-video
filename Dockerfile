# 1. Start with the official standard Node 20 Alpine Linux image
FROM node:20-alpine

# 2. Install standard n8n dependencies AND your custom video tools
RUN apk add --no-cache \
    graphicsmagick \
    tzdata \
    ffmpeg \
    yt-dlp

# 3. Install the latest version of n8n directly via npm
RUN npm install -g n8n

# 4. Start the n8n application
CMD ["n8n"]