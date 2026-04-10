import os
import socket
import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

# Server information
HOST = '127.0.0.1'
PORT = 5001

# Capture window size
WINDOW_W = 640
WINDOW_H = 480

LEFT_EYE  = [33, 160, 158, 133, 153, 144] # Left eye landmark indicies
RIGHT_EYE = [362, 385, 387, 263, 373, 380] # Right eye landmark indicies

model_path = os.path.join(os.path.dirname(__file__), 'data', 'face_landmarker.task') # Get path to face landmarker

# Set up face landmarker
base_options = python.BaseOptions(model_asset_path=model_path)
options = vision.FaceLandmarkerOptions(
  base_options=base_options,
  num_faces=1
)
detector = vision.FaceLandmarker.create_from_options(options)

# Set up video capture and define window size
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, WINDOW_W)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, WINDOW_H)

# Start server on specified host:port and wait for connection
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(1)
print("waiting for Processing to connect...")
conn, addr = server.accept()
print("connected")

while True:
    ret, frame = cap.read() # Read capture information
    if not ret: continue # Continue if no capture

    h, w = frame.shape[:2] # Get capture height and width

    # Repackage captured image
    mp_image = mp.Image(
        image_format=mp.ImageFormat.SRGB,
        data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    )

    # Detect landmarks and store result
    result = detector.detect(mp_image)

    # If result is empty, continue
    if not result.face_landmarks:
        continue

    # Create eye boxes from landmarks
    def eye_box(indices):
        xs = [int(result.face_landmarks[0][i].x * w) for i in indices]
        ys = [int(result.face_landmarks[0][i].y * h) for i in indices]
        return min(xs), min(ys), max(xs) - min(xs), max(ys) - min(ys)

    lx, ly, lw, lh = eye_box(LEFT_EYE) # Left eye bounding box coords
    rx, ry, rw, rh = eye_box(RIGHT_EYE) # Right eye bounding box coords

    msg = f"{lx},{ly},{lw},{lh},{rx},{ry},{rw},{rh}\n" # Format message to Processing program
    try:
        conn.sendall(msg.encode()) # Send bounding box coords
    except:
        break

cap.release() # Release camera
conn.close() # Close connection
server.close() # Close server