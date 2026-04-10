#!/bin/bash

# install python dependencies
python3 -m pip install -r requirements.txt

# download mediapipe face landmarker model into data/
echo "downloading face_landmarker.task..."
curl -o data/face_landmarker.task \
  https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task

echo "done. run python/main.py first, then open processing/project/project.pde"