import processing.video.*;
import processing.net.*;

Capture cam; // Camera
Client pyClient; // Python client

int lx, ly, lw, lh; // Left eye coords
int rx, ry, rw, rh; // Right eye coords
boolean hasData = false; // Data presence flag
int PADDING = 10; // Eye bounding box padding

String latestLine = null; // Latest buffered line from Python
String HOST = "127.0.0.1"; // Host location
int PORT = 5001; // Host port

int WINDOW_W = 640, WINDOW_H = 480; // Display window size

void setup() { // Start everything up
  windowResizable(true);
  cam = new Capture(this, WINDOW_W, WINDOW_H, 30);
  cam.start();
  pyClient = new Client(this, HOST, PORT);
}

void settings() {
  size(WINDOW_W, WINDOW_H);
}

void draw() {
  if (cam.available()) {
    cam.read();
  }
  image(cam, 0, 0); // Display camera image

  drainCoords(); // Ignore old eye coordinates
  applyLatestLine(); // Fetch most recent eye coords

  if (!hasData) {
    return; // If no data present, skip draw iteration
  }

  noFill();
  stroke(0, 255, 0);
  strokeWeight(2);
  rect(lx - PADDING, ly - PADDING, lw + PADDING * 2, lh + PADDING * 2); // Left eye bounding box
  rect(rx - PADDING, ry - PADDING, rw + PADDING * 2, rh + PADDING * 2); // Right eye bounding box
}

void drainCoords() {
  while (pyClient.available() > 0) {
    String line = pyClient.readStringUntil('\n'); // Read until delimiting character
    if (line == null) {
      break; // If we are 'caught up' exit function
    }
    line = trim(line); // Trim pyClient read
    if (line.length() > 0) {
      latestLine = line; // Assign latest line
    }
  }
}

void applyLatestLine() {
  if (latestLine == null) {
    return; // If no latest line, exit function
  }

  String[] parts = split(latestLine, ',');
  if (parts.length < 8) {
    return; // If incorrect formatting, exit function
  }

  // Store eye coords for use
  lx = int(parts[0]);
  ly = int(parts[1]);
  lw = int(parts[2]);
  lh = int(parts[3]);
  rx = int(parts[4]);
  ry = int(parts[5]);
  rw = int(parts[6]);
  rh = int(parts[7]);
  hasData = true; // Update data flag
  latestLine = null; // Clear line variable
}