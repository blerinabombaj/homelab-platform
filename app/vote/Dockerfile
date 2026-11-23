# syntax=docker/dockerfile:1
# ^ Tells BuildKit which Dockerfile syntax version to use. Needed for "RUN --mount" below.

# ---- Base image ----
# python:3.13-slim = Debian with Python, without compilers/docs. ~45 MB vs ~400 MB for the full image.
# Always pin at least the minor version (3.13), never just "python" or "latest":
# otherwise a rebuild next month can silently pull a different Python.
FROM python:3.13-slim

# PYTHONDONTWRITEBYTECODE: don't write .pyc files into the image (useless in a container).
# PYTHONUNBUFFERED: print logs immediately; without it logs can be delayed/lost in `docker logs`.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# All following commands run in /app (created automatically).
WORKDIR /app

# Create an unprivileged user. Containers run as root by default; if the app gets hacked,
# root in the container makes escaping to the host much easier.
# A fixed numeric UID (10001) lets Kubernetes verify "runAsNonRoot" later.
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app

# ---- Dependencies (cached layer) ----
# Copy ONLY requirements.txt first. Docker caches each layer; as long as this file
# doesn't change, the slow "pip install" layer is reused even when app.py changes.
COPY requirements.txt .
# --mount=type=cache keeps pip's download cache between builds on the build machine,
# without putting it inside the image. --no-cache-dir would be the alternative.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# ---- App code ----
# Copied last because it changes most often (keeps the cache above valid).
COPY . .

# From here on, everything (including the running app) is the unprivileged user.
USER 10001

# Documentation only: tells humans/tools the app listens on 8080. It does NOT publish the port.
# 8080 instead of 80: ports < 1024 need root to bind.
EXPOSE 8080

# gunicorn = production WSGI server (Flask's built-in server is for development only).
#   app:app        -> module app.py, object "app"
#   -b 0.0.0.0     -> listen on all interfaces (127.0.0.1 would be unreachable from outside the container)
#   --access-logfile - / --error-logfile -  -> log to stdout/stderr, the container log convention
#   --workers 2    -> 2 processes; rule of thumb is 2*CPU+1, kept low for our RAM budget
# Exec form ["..."] (not a plain string) so gunicorn is PID 1 and receives SIGTERM on `docker stop`.
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--workers", "2", "--access-logfile", "-", "--error-logfile", "-"]
