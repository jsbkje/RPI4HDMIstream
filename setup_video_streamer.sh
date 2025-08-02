#!/bin/bash

APP_NAME="video-streamer"
APP_DIR="/opt/$APP_NAME"
VENV_DIR="$APP_DIR/venv"
SERVICE_NAME="$APP_NAME"
REPO_DIR="$(pwd)"

echo "🚀 Installing packages..."
sudo apt update
sudo apt install -y ffmpeg v4l-utils python3 python3-venv python3-pip

echo "📁 Creating app directory..."
sudo mkdir -p "$APP_DIR"
sudo cp -r "$REPO_DIR/" "$APP_DIR/"
sudo chown -R $USER:$USER "$APP_DIR"

echo "🐍 Creating virtualenv..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install flask

echo "📝 Writing systemd service..."
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Live video streamer
After=network.target

[Service]
ExecStart=${VENV_DIR}/bin/python3 ${APP_DIR}/video_app.py
WorkingDirectory=${APP_DIR}
Restart=on-failure
User=${USER}
Group=${USER}
Environment=FLASK_ENV=production

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and enabling service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "✅ $SERVICE_NAME is now running and auto-start enabled!"

