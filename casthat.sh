#!/bin/bash

# Check if required tools are installed
command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "ffmpeg is required but not installed. Aborting."; exit 1; }
command -v slop >/dev/null 2>&1 || { echo >&2 "slop is required but not installed. Aborting."; exit 1; }

# Get screen selection from user
echo "Select the area of your screen to stream..."
# GEOMETRY=$(import -pause 1 -frame -silent -geometry +100+100 -crop 800x600 +repage /dev/null 2>&1 | grep "Geometry" | awk '{print $2}')
GEOMETRY=$(slop -f "%x %y %w %h") || exit 1

read -r X Y W H <<< "$GEOMETRY"

PORT=8889
BITRATE="1000k"
FRAMERATE=30
CODEC="libx264"  # or use h264_nvenc if you have NVIDIA GPU

# Get local IP address
IP_ADDR=$(hostname -I | awk '{print $1}')

echo "CastThat started"
echo "Starting stream... on ${W}x${H} Press Ctrl+C to stop."
echo "View the stream at: http://$IP_ADDR:$PORT/live/stream/"

# Trap Ctrl+C to clean up
cleanup() {
    echo "Stopping stream..."
    kill $FFMPEG_PID 2>/dev/null
    exit 0
}
trap cleanup INT TERM

# Start FFmpeg streaming
# considering there is a running rtsp server (on port 8890)
# docker run --rm -it --network=host bluenviron/mediamtx:latest
ffmpeg -loglevel error \
    -f x11grab -video_size "${W}x${H}" -framerate "$FRAMERATE" -i ":0.0+$X,$Y" \
    -vcodec "$CODEC" -tune zerolatency -b:v "$BITRATE" \
    -f flv "rtmp://0.0.0.0:1935/live/stream"

FFMPEG_PID=$!
# Keep script running while FFmpeg is alive
wait $FFMPEG_PID
