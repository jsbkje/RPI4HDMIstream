from flask import Flask, Response, render_template
import subprocess
import os

app = Flask(__name__, static_folder='static', template_folder='static')

@app.route('/')
def index():
    return render_template('video_client.html')

@app.route('/video_feed')
def video_feed():
    # Replace this with actual video device or stream command
    # Example using FFmpeg to pipe MJPEG (adjust as needed)
    command = [
        'ffmpeg', '-f', 'v4l2', '-i', '/dev/video0',
        '-vf', 'scale=640:480',
        '-f', 'mjpeg', '-q:v', '5', 'pipe:1'
    ]
    return Response(subprocess.Popen(command, stdout=subprocess.PIPE).stdout,
                    mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
