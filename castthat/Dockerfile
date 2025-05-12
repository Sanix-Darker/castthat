FROM debian:bookworm-slim

# tini = clean signal handling  |  ca-certificates required by ffmpeg HLS
# this is the tinest i could comes up with...
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        slop \
        bash \
        tini \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# put script into the image (i mean... the PATH... kind of)
COPY castthat.sh /usr/local/bin/castthat
RUN chmod +x /usr/local/bin/castthat

ENTRYPOINT ["/usr/bin/tini","--","castthat"]
