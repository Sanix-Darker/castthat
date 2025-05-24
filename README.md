## CASTHAT

![screenshot](./screen.jpg)

A basic script to stream an area of your screen over network accessible via http/tcp/udb (locally or over internet).

## REQUIREMENTS

- Any rtmp/rtsp server (in my case i used the docker mediamtx).
- [ffmpeg](https://ffmpeg.org) to forward mixed media to the streaming server.
- [pactl) to grab forward the audio sink as stream.
- [slop](https://github.com/naelstrof/slop) (To select, drag to extract X, Y, W, H coordinates) for the portion of the screen that will be extract from display by ffmpeg.

## HOW TO RUN CASTTHAT

### NO DOCKER

```console
# First, start the mediamtx docker (or any other rtsp/rtmp server)
$ docker run --rm -it --network=host bluenviron/mediamtx:latest
```

```console
# Then run castthat script

$ ./castthat/casthat.sh
> Drag to select the area you want to stream…
Failed to detect a compositor, OpenGL hardware-accelleration disabled... (you can ignore this error)
▶  Streaming 938x638@40 → rtmp://192.168.1.30:1935/live/stream
   HLS playlist:   http://192.168.1.30:8888/live/stream/index.m3u8
   Low-latency HLS http://192.168.1.30:8888/live/stream/llhls.m3u8
```

### OR WITH DOCKER COMPOSE

Only if you have X11 server up and running for you.
see the ./docker-compose.yml for more details

```console
docker compose up --build
```

## TROUBLESHOOTHING

If you find yourself unable to read/get frames from the X server,
try those commands :
```bash
xhost +local:  # Allow local connections to X server
export DISPLAY=:0  # Set default display
```
