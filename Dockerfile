# syntax=docker/dockerfile:1.7
FROM node:24.15.0-bookworm AS builder
WORKDIR /src
COPY . .
RUN npm ci --workspaces --include-workspace-root --ignore-scripts
RUN npm run --workspace=packages/scratch-gui prepare
ENV NODE_ENV=production
RUN npm run --workspace=packages/task-herder build && \
    npm run --workspace=packages/scratch-storage build && \
    npm run --workspace=packages/scratch-svg-renderer build && \
    npm run --workspace=packages/scratch-render build && \
    npm run --workspace=packages/scratch-vm build && \
    npm run --workspace=packages/scratch-gui build
# Cache-bust gui.js so a new deploy cannot be masked by a stale Cloudflare/browser
# cached bundle (index.html is no-store, but gui.js is cached for 4h).
RUN VERSION=$(node -p "require('./package.json').version") && \
    sed -i "s|src=\"gui.js\"|src=\"gui.js?v=${VERSION}\"|g" packages/scratch-gui/build/index.html && \
    grep -q "gui.js?v=" packages/scratch-gui/build/index.html && \
    echo "cache-bust OK: gui.js?v=${VERSION}"
RUN set -e; \
    d=packages/scratch-gui/build; \
    for f in "$d/index.html" "$d/gui.js"; do \
      test -s "$f" || { echo "FATAL: missing/empty $f" >&2; exit 1; }; \
    done; \
    test -d "$d/chunks" && [ -n "$(ls -A "$d/chunks")" ] || { echo "FATAL: $d/chunks missing/empty" >&2; exit 1; }; \
    test -d "$d/static" && [ -n "$(ls -A "$d/static")" ] || { echo "FATAL: $d/static missing/empty" >&2; exit 1; }; \
    echo "artifact OK: $(du -sh "$d" | cut -f1) in $d"
RUN node -p "require('./package.json').version" > /src/VERSION

FROM nginxinc/nginx-unprivileged:1.27-alpine@sha256:65e3e85dbaed8ba248841d9d58a899b6197106c23cb0ff1a132b7bfe0547e4c0 AS runtime
COPY --from=builder /src/packages/scratch-gui/build/index.html               /usr/share/nginx/html/
COPY --from=builder /src/packages/scratch-gui/build/gui.js                   /usr/share/nginx/html/
COPY --from=builder /src/packages/scratch-gui/build/gui.js.LICENSE.txt       /usr/share/nginx/html/
COPY --from=builder /src/packages/scratch-gui/build/extension-worker.js      /usr/share/nginx/html/
COPY --from=builder /src/packages/scratch-gui/build/extension-worker.js.LICENSE.txt /usr/share/nginx/html/
COPY --from=builder /src/packages/scratch-gui/build/30d09ba32a17082ef820b57d52d60b7b.hex /usr/share/nginx/html/
COPY --from=builder /src/packages/scratch-gui/build/chunks/ /usr/share/nginx/html/chunks/
COPY --from=builder /src/packages/scratch-gui/build/static/ /usr/share/nginx/html/static/
COPY --from=builder /src/VERSION /usr/share/nginx/html/VERSION
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/env-config.js.template /usr/share/spark.env-config.js.template
COPY --chmod=0755 docker/30-spark-env.sh /docker-entrypoint.d/30-spark-env.sh
EXPOSE 8080
