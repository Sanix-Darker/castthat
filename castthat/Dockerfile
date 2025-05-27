FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# tini = clean signal handling  |  ca-certificates required by ffmpeg HLS
# this is the tinest i could comes up with...
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        slop \
        pulseaudio-utils \
        libpulse0 \
        bash \
        tini \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# put script into the image (i mean... the PATH... kind of)
COPY castthat.sh /usr/local/bin/castthat
RUN chmod +x /usr/local/bin/castthat

# needed for libpulse to know where the socket live
ENV PULSE_SERVER=unix:/tmp/pulse-native

# Not 100% sure about this one :
RUN export AUDIO_GID=$(getent group audio | cut -d: -f3)

ENTRYPOINT ["/usr/bin/tini","--","castthat"]
