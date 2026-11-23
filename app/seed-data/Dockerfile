# syntax=docker/dockerfile:1
# One-shot container: fires 3000 fake votes at the vote service, then exits.
# Useful to generate load/data, e.g. to have something to look at in Grafana later.

FROM python:3.13-slim

# apache2-utils contains "ab" (ApacheBench), the load-testing tool used by generate-votes.sh.
# Same RUN line: update + install + delete apt lists. If split across lines, the deleted
# files would still exist in an earlier layer and the image would not get smaller.
# --no-install-recommends avoids pulling in extra "suggested" packages.
RUN apt-get update \
 && apt-get install -y --no-install-recommends apache2-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /seed
COPY . .

# Generate the POST bodies ("vote=a", "vote=b") at build time.
RUN python make-data.py

# "nobody" exists in every Debian image; good enough for a script that only sends HTTP requests.
USER nobody

# Target URL comes from the VOTE_URL env var (default http://vote:8080/).
CMD ["sh", "generate-votes.sh"]
