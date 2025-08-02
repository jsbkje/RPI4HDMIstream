#!/bin/bash
# 📡 Raspberry Pi HDMI Streaming Setup Script
# Installs FastAPI + Uvicorn app with MJPEG streaming to canvas over WebSocket

set -e

APP_DIR="/opt/video_streamer"
VENV_DIR="$APP_DIR/venv"
SERVICE_NAME="video-streamer"
LOG_FILE="/var/log/video_streamer.log"

echo "📦 Updating and installing system packages..."
sudo apt update
sudo apt install -y ffmpeg python3 python3-venv python3-pip git curl

echo "📁 Creating app directory..."
sudo mkdir -p "$APP_DIR/static"
sudo chown -R $USER:$USER "$APP_DIR"

echo "🐍 Setting up Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "📦 Installing Python dependencies with version pinning..."
pip install fastapi==0.110.0 "uvicorn[standard]==0.27.1"

echo "🧠 Creating FastAPI app..."
cat > "$APP_DIR/video_app.py" <<EOF
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
import subprocess
import asyncio

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/video")
async def video_page():
    return HTMLResponse(open("static/video_client.html").read())

@app.websocket("/ws")
async def video_stream(websocket: WebSocket):
    await websocket.accept()
    ffmpeg = subprocess.Popen([
        "ffmpeg", "-f", "v4l2", "-i", "/dev/video0",
        "-s", "640x480", "-f", "mjpeg", "pipe:1"
    ], stdout=subprocess.PIPE)

    try:
        while True:
            chunk = ffmpeg.stdout.read(1024 * 32)
            await websocket.send_bytes(chunk)
            await asyncio.sleep(0)
    except Exception as e:
        ffmpeg.terminate()
EOF

echo "🖼️ Creating HTML client page..."
cat > "$APP_DIR/static/video_client.html" <<EOF
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Video Stream</title></head>
<body style="margin:0;background:black;">
<canvas id="videoCanvas" width="640" height="480"></canvas>
<script>
const canvas = document.getElementById("videoCanvas");
const ctx = canvas.getContext("2d");
const socket = new WebSocket("ws://" + location.host + "/ws");
socket.binaryType = "arraybuffer";
const img = new Image();
socket.onmessage = event => {
    const blob = new Blob([event.data], { type: 'image/jpeg' });
    img.onload = () => ctx.drawImage(img, 0, 0);
    img.src = URL.createObjectURL(blob);
};
</script>
</body></html>
EOF

echo "🔧 Creating systemd service..."
cat | sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" > /dev/null <<EOF
[Unit]
Description=FastAPI HDMI Video Streamer
After=network.target

[Service]
User=$USER
WorkingDirectory=$APP_DIR
ExecStart=${VENV_DIR}/bin/uvicorn video_app:app --host 0.0.0.0 --port 8000
Restart=always
StandardOutput=append:${LOG_FILE}
StandardError=append:${LOG_FILE}

[Install]
WantedBy=multi-user.target
EOF

echo "🧹 Reloading systemd and starting service..."
sudo systemctl daemon-reexec
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "✅ Setup complete!"
echo "Visit: http://<your-pi-ip>:8000/video or embed via:"
echo "<iframe src='http://<your-pi-ip>:8000/video' width='640' height='480'></iframe>"
