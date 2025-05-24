#!/usr/bin/env bash

set -Eeuo pipefail

### sanity-check prerequisites
for cmd in ffmpeg slop; do
  command -v "$cmd" >/dev/null || {
    echo >&2 "❌  $cmd not found – install it first."; exit 1; }
done

### user-configurable knobs (env vars override for ffmpeg)
PORT_RTMP=${PORT_RTMP:-1935}           # where MediaMTX listens for RTMP
RTMP_IP="127.0.0.1"                    # If the server is not ran locally
PATH_NAME=${PATH_NAME:-live/stream}    # RTMP/HLS/WebRTC path
FPS=${FPS:-40}                         # capture frame rate
BITRATE=${BITRATE:-1000k}              # CBR so Wi-Fi phones cope
GOP=$((FPS*2))                         # 2 s key-int > segment-aligned for HLS
PRESET=${PRESET:-veryfast}             # good CPU/quality trade-off
CRF=${CRF:-23}

### regarding audio
# Pulse / PipeWire: pick the monitor of the current system output
DEFAULT_SINK=$(pactl get-default-sink)
AUDIO_SRC=${AUDIO_SRC:-${DEFAULT_SINK}.monitor}
AUDIO_BR=${AUDIO_BR:-160k}

### automatically pick the best H.264 encoder available
if ffmpeg -hide_banner -encoders | grep -q h264_nvenc; then
  VENC=h264_nvenc ; PRESET=${PRESET:-p3}
elif ffmpeg -hide_banner -encoders | grep -q h264_vaapi; then
  VENC=h264_vaapi
else
  VENC=libx264
fi

echo "> Drag to select the area you want to stream…"
GEOMETRY=$(slop -f "%x %y %w %h") || exit 1
read -r X Y W H <<< "$GEOMETRY"

# guarantee even dimensions for yuv420p
W=$((W - W%2)); H=$((H - H%2))

IP=$(hostname -I | awk '{print $1}')

echo "▶  Streaming ${W}x${H}@${FPS} → rtmp://$IP:$PORT_RTMP/$PATH_NAME"
echo "   HLS playlist:   http://$IP:8888/$PATH_NAME/index.m3u8"
echo "   Low-latency HLS http://$IP:8888/$PATH_NAME/llhls.m3u8"

cleanup() { echo "⏹  Stopping…"; kill "$FF" 2>/dev/null; }
trap cleanup INT TERM EXIT

ffmpeg -hide_banner -loglevel warning \
  -thread_queue_size 512 \
  -f pulse              -i "$AUDIO_SRC" \
  -f x11grab            -video_size "${W}x${H}" -framerate "$FPS" -i ":0.0+$X,$Y" \
  -vcodec "$VENC"       -preset "$PRESET"        -tune zerolatency \
  -profile:v baseline   -level 3.1               -pix_fmt yuv420p \
  -g "$GOP"             -keyint_min "$GOP" \
  -b:v "$BITRATE"       -maxrate "$BITRATE"      -bufsize "$(( ${BITRATE%k}*2 ))k" \
  -f flv "rtmp://127.0.0.1:$PORT_RTMP/$PATH_NAME" &
FF=$!
wait "$FF"
