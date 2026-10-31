"""USB camera -> YOLO11 (BPU) -> MJPEG over HTTP, viewable from a phone browser.

Reuses the official sample class in /app/pydev_demo/02_detection_sample/02_ultralytics_yolo11.
Run on the board:  python3 live_web.py   then open http://<board-ip>:8080
"""
import os
import sys
import time
import threading
import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SAMPLE_DIR = "/app/pydev_demo/02_detection_sample/02_ultralytics_yolo11"
os.chdir(SAMPLE_DIR)
sys.path.insert(0, SAMPLE_DIR)
sys.path.append(os.path.abspath("../.."))

import cv2  # noqa: E402
from ultralytics_yolo11 import YoloV11  # noqa: E402
import utils.common_utils as common  # noqa: E402
import utils.draw_utils as draw  # noqa: E402

latest_jpeg = None
lock = threading.Lock()

PAGE = b"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>RDK X5 Live</title>
<style>body{margin:0;background:#111;color:#eee;font-family:sans-serif;text-align:center}
img{width:100%;max-width:960px}</style></head>
<body><p>RDK X5 / YOLO11n on BPU</p><img src="/stream"></body></html>"""


def detect_loop(opt):
    global latest_jpeg
    model = YoloV11(opt)
    model.set_scheduling_params(priority=0, bpu_cores=[0])
    names = common.load_class_names(opt.label_file)
    cap = cv2.VideoCapture(opt.camera)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    fps, last = 0.0, time.time()
    while True:
        ok, img = cap.read()
        if not ok:
            time.sleep(0.1)
            continue
        h, w = img.shape[:2]
        t0 = time.time()
        boxes, cls_ids, scores = model.post_process(model.forward(model.pre_process(img)), w, h)
        infer_ms = (time.time() - t0) * 1000
        img = draw.draw_boxes(img, boxes, cls_ids, scores, names, common.rdk_colors)
        now = time.time()
        fps = 0.9 * fps + 0.1 * (1.0 / max(now - last, 1e-6))
        last = now
        cv2.putText(img, f"{fps:.1f} FPS  infer {infer_ms:.0f} ms", (10, 25),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        ok, buf = cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 70])
        if ok:
            with lock:
                latest_jpeg = buf.tobytes()


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_GET(self):
        if self.path == "/stream":
            self.send_response(200)
            self.send_header("Content-Type", "multipart/x-mixed-replace; boundary=frame")
            self.end_headers()
            try:
                while True:
                    with lock:
                        frame = latest_jpeg
                    if frame:
                        self.wfile.write(b"--frame\r\nContent-Type: image/jpeg\r\n\r\n" + frame + b"\r\n")
                    time.sleep(0.05)
            except (BrokenPipeError, ConnectionResetError):
                return
        else:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(PAGE)


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--model-path", default="yolo11n_detect_bayese_640x640_nv12.bin")
    p.add_argument("--label-file", default="coco_classes.names")
    p.add_argument("--nms-thres", type=float, default=0.45)
    p.add_argument("--score-thres", type=float, default=0.25)
    p.add_argument("--camera", type=int, default=0)
    p.add_argument("--port", type=int, default=8080)
    opt = p.parse_args()
    threading.Thread(target=detect_loop, args=(opt,), daemon=True).start()
    ThreadingHTTPServer(("0.0.0.0", opt.port), Handler).serve_forever()
