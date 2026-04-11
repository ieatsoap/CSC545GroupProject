import processing.net.*;

Client pyClient; // Python client for receiving eye data

PImage leftEye, rightEye; // PImages to hold the left and right eye frames
boolean hasFrames = false; // Flag to indicate if valid eye frames have been received

// Set window size and initialize pyClient, leftEye, and rightEye
void setup() {
  size(960, 640);
  pyClient = new Client(this, "127.0.0.1", 5001);
  leftEye = createImage(480, 640, RGB);
  rightEye = createImage(480, 640, RGB);
}

// Read data from pyClient when available and display
void draw() {
  readData();
  background(0);

  if (!hasFrames) {
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("waiting for eye data...", width / 2, height / 2);
    return;
  }

  image(leftEye, 0, 0); // ------------------------------------------------------------------- Use these closeup PImages for further gaze detection
  image(rightEye, 480, 0); // ---------------------------------------------------------------- Use these closeup PImages for further gaze detection
}

// Read data from pyClient, decode JPEG images, and update leftEye and rightEye
void readData() {
  if (pyClient.available() <= 0) {
    return;
  } // Check if data is available

  String line = pyClient.readStringUntil('\n');
  if (line == null) {
    return;
  } // Remove any trailing newline characters

  line = trim(line); // Trim whitespace from the line

  if (line.equals("none")) {
    hasFrames = false;
    return;
  } // If "none" message is received, set hasFrames to false and return

  if (!line.equals("ok")) {
    return;
  } // If the message is not "ok", ignore it and return

  // Read left and right JPEG image sizes (4 bytes each) and then read the JPEG data
  byte[] leftSizeBuf = pyClient.readBytes(4);
  if (leftSizeBuf == null || leftSizeBuf.length < 4) {
    return;
  }
  int leftSize = ((leftSizeBuf[0] & 0xFF) << 24) |
                 ((leftSizeBuf[1] & 0xFF) << 16) |
                 ((leftSizeBuf[2] & 0xFF) << 8)  |
                 ((leftSizeBuf[3] & 0xFF));

  byte[] leftBytes = pyClient.readBytes(leftSize);
  if (leftBytes == null || leftBytes.length < leftSize) {
    return;
  }

  byte[] rightSizeBuf = pyClient.readBytes(4);
  if (rightSizeBuf == null || rightSizeBuf.length < 4) {
    return;
  }
  int rightSize = ((rightSizeBuf[0] & 0xFF) << 24) |
                  ((rightSizeBuf[1] & 0xFF) << 16) |
                  ((rightSizeBuf[2] & 0xFF) << 8)  |
                  ((rightSizeBuf[3] & 0xFF));

  byte[] rightBytes = pyClient.readBytes(rightSize);
  if (rightBytes == null || rightBytes.length < rightSize) {
    return;
  }

  // Decode JPEG byte arrays into PImage objects
  PImage decodedLeft = decodeJpeg(leftBytes);
  PImage decodedRight = decodeJpeg(rightBytes);

  // Update leftEye, rightEye, and hasFrames if both images were successfully decoded
  if (decodedLeft != null && decodedRight != null) {
    leftEye = decodedLeft;
    rightEye = decodedRight;
    hasFrames = true;
  }
}

// Decode JPEG byte array into a PImage object using Java's ImageIO
PImage decodeJpeg(byte[] jpegBytes) {
  try {
    java.io.ByteArrayInputStream bis = new java.io.ByteArrayInputStream(jpegBytes);
    java.awt.image.BufferedImage bimg = javax.imageio.ImageIO.read(bis);
    PImage img = new PImage(bimg.getWidth(), bimg.getHeight(), RGB);
    bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();
    return img;
  } catch (Exception e) {
    return null;
  }
}