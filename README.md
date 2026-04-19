# CSC545 Group Project

Streams webcam gaze coordinates to a Processing sketch via UDP. A white circle follows your eyes on a black screen.

## Requirements

- Python 3.11
- [Processing 4](https://processing.org/download) with the **UDP by Hypermedia** library

## Setup
(uses [uv](https://docs.astral.sh/uv/getting-started/installation/) as Python package/version manager)

**Windows**
```
uv init --python 3.11
uv venv
.venv/Scripts/activate
uv add -r requirements.txt
```

**Mac**
```
uv init --python 3.11
uv venv
source .venv/bin/activate
uv add -r requirements.txt
```

### Processing

Open Processing → Sketch → Import Library → Manage Libraries → search **UDP** → Install

## Run

1. Run the Python sender:
```
uv run gaze_sender.py
```
2. Follow the calibration dots
3. Once calibration window exits fullscreen, open `gaze_receiver/gaze_receiver.pde` in Processing and click Run

**Note:**
PyGame windows have minimizing issues on Mac. The calibration window will freeze after calibration is done--just run the Processing program regardless. Do not force quit the PyGame window.