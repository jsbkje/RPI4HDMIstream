📡 Raspberry Pi HDMI Video Streamer
This project sets up a FastAPI-powered server on a Raspberry Pi 4 that captures video from a USB HDMI dongle, scales it to 640×480, and streams it to a browser <canvas> in real time via MJPEG over WebSockets. Perfect for remote monitoring, embedded dashboards, or custom iframe-based viewers.

🚀 Features
FastAPI + Uvicorn WebSocket-based server

MJPEG streaming from /dev/video0

Client-side decoding using <canvas>

Embedded-friendly via <iframe src="/video">

systemd service for auto-start on boot

Logs to /var/log/video_streamer.log

🔧 Setup Instructions
On a fresh Raspberry Pi OS install:

bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/setup_video_streamer.sh | bash
Replace YOUR_USERNAME and YOUR_REPO with your actual GitHub path.

📺 Viewing the Stream
Once installed, visit:

http://<raspberrypi-ip>:8000/video
Or embed it directly in any webpage:

html
<iframe src="http://<raspberrypi-ip>:8000/video" width="640" height="480" frameborder="0"></iframe>
🛠️ Customization
Video Device: The default capture device is /dev/video0. To change this, edit video_app.py.

Resolution: You can tweak FFmpeg’s -s 640x480 flag to adjust resolution.

Frame Size: Adjust chunk = ffmpeg.stdout.read(1024 * 32) to experiment with performance.

📄 Files Created
/opt/video_streamer/video_app.py – FastAPI application

/opt/video_streamer/static/video_client.html – HTML frontend

/opt/video_streamer/venv/ – Python virtualenv

/etc/systemd/system/video-streamer.service – systemd unit

/var/log/video_streamer.log – log output

🤝 Contributions
Pull requests and feature ideas welcome—especially around:

multi-client support

autodetection of video devices

optional audio or overlays

stream authentication
