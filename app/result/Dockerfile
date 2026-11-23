# syntax=docker/dockerfile:1

# Node 24 = current LTS line. "-slim" = Debian without extras.
FROM node:24-slim

# NODE_ENV=production makes Express and many libraries turn off debug features.
ENV NODE_ENV=production \
    PORT=4000

WORKDIR /app

# ---- Dependencies (cached layer) ----
# package.json + package-lock.json first, so `npm ci` is cached until dependencies change.
COPY package.json package-lock.json ./
# npm ci (not npm install): installs EXACTLY what's in package-lock.json, fails if it's out of sync.
# That's what you want in builds: reproducible. --omit=dev skips test/dev dependencies.
RUN npm ci --omit=dev && npm cache clean --force

# ---- App code ----
# .dockerignore keeps node_modules/ and tests/ from the host out of the image.
COPY . .

# The node image already ships an unprivileged user "node" (UID 1000).
USER node

EXPOSE 4000

# Run node directly (not "npm start"): npm doesn't forward SIGTERM to the app,
# so `docker stop` would wait 10 s and then kill it hard.
# Node as PID 1 also doesn't reap zombie processes; compose uses `init: true` to add a tiny init.
CMD ["node", "server.js"]
