import os
import socket
import struct
import threading
import time
import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

# Server coniguration
HOST = '127.0.0.1'
PORT = 5001

# Mediapipe face landmark indices for eyes
LEFT_EYE  = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]

# Build the path to the face_landmarker.task file
model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data', 'face_landmarker.task')

# Initialize the face landmarker
base_options = python.BaseOptions(model_asset_path=model_path)
options = vision.FaceLandmarkerOptions(
  base_options=base_options,
  num_faces=1
)
detector = vision.FaceLandmarker.create_from_options(options)

# Open the webcam
cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
cap.set(cv2.CAP_PROP_FPS, 30)

# Catch camera open error
if not cap.isOpened():
  print("error: could not open camera")
  exit()

# Shared variables for latest eye images and synchronization lock
latest_left = None
latest_right = None
lock = threading.Lock()

# Function to calculate bounding box around eye landmarks with padding
def eye_bounds(indices, lm, w, h, padding=20):
  xs = [int(lm[i].x * w) for i in indices]
  ys = [int(lm[i].y * h) for i in indices]
  x1 = max(0, min(xs) - padding)
  y1 = max(0, min(ys) - padding)
  x2 = min(w, max(xs) + padding)
  y2 = min(h, max(ys) + padding)
  return x1, y1, x2, y2

# Thread function to continuously capture frames, detect face landmarks, and update latest eye images
def capture_thread():
  global latest_left, latest_right
  while True:
    ret, frame = cap.read()
    if not ret: # Read if possible, continue otherwise
      continue

    h, w = frame.shape[:2] # Get frame dimensions

    mp_image = mp.Image(
      image_format=mp.ImageFormat.SRGB,
      data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    ) # Convert frame to Mediapipe image format

    result = detector.detect(mp_image) # Run face landmark detection

    # Variables to hold left and right eye crops
    left_jpg = None
    right_jpg = None

    if result.face_landmarks:
      lm = result.face_landmarks[0] # Get landmarks for the first detected face

      lx1, ly1, lx2, ly2 = eye_bounds(LEFT_EYE,  lm, w, h) # Get bounding box for left eye
      rx1, ry1, rx2, ry2 = eye_bounds(RIGHT_EYE, lm, w, h) # Get bounding box for right eye

      left_crop = frame[ly1:ly2, lx1:lx2] # Crop left eye region from frame
      right_crop = frame[ry1:ry2, rx1:rx2] # Crop right eye region from frame

      if left_crop.size > 0:
        left_resized = cv2.resize(left_crop, (480, 640))
        _, buf = cv2.imencode('.jpg', left_resized, [cv2.IMWRITE_JPEG_QUALITY, 80])
        left_jpg = buf.tobytes() # Resize left eye crop to 480x640 and encode as JPEG

      if right_crop.size > 0:
        right_resized = cv2.resize(right_crop, (480, 640))
        _, buf = cv2.imencode('.jpg', right_resized, [cv2.IMWRITE_JPEG_QUALITY, 80])
        right_jpg = buf.tobytes() # Resize right eye crop to 480x640 and encode as JPEG

    with lock: # Update shared latest eye images with synchronization
      latest_left = left_jpg
      latest_right = right_jpg

# Thread function to send latest eye images to Processing program at target FPS
def send_thread(conn):
  target_fps = 30
  interval = 1.0 / target_fps
  last_send = 0

  while True: # Time sending intervals
    now = time.time()
    if now - last_send < interval:
      continue
    last_send = now

    with lock: # Get latest eye images with synchronization
      left_jpg = latest_left
      right_jpg = latest_right

    if left_jpg is None or right_jpg is None:
      try: # If no valid eye images, send "none" message to Processing
        conn.sendall(b"none\n")
      except:
        break
      continue

    # Pack left and right JPEG images
    left_size = struct.pack('>I', len(left_jpg))
    right_size = struct.pack('>I', len(right_jpg))

    try: # Send success message with JPEG data to Processing
      conn.sendall(b"ok\n" + left_size + left_jpg + right_size + right_jpg)
    except:
      break

# Initialize server and wait for Processing to connect
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(1)
print("waiting for Processing to connect...")
conn, _ = server.accept()
print("connected")

# Start capture thread to continuously update latest eye images
t = threading.Thread(target=capture_thread, daemon=True)
t.start()

# Start send thread to continuously send latest eye images to Processing
time.sleep(1)
send_thread(conn)

# Cleanup on exit
cap.release()
conn.close()
server.close()