import hypermedia.net.*;

// Set this to true to use mouse coordinates instead of gaze coordinates for testing
boolean testMode = false;

UDP udp;
int gx, gy;
boolean hasGaze = false;

PImage img;
PImage filteredImg;
String fname = "hot_air.jpg";
String[] filters = {"default", "spotlight", "colorPop", "ascii", "pixelate", "dither", "invert"};
int currentFilter = 0;

void setup() {
  fullScreen();
  pixelDensity(1);
  udp = new UDP(this, 5005);
  udp.listen(true);
  gx = width / 2;
  gy = height / 2;
  img = loadImage(fname);
  img.resize(width, height);
  background(img);
}

void draw() {
  if (hasGaze) {
    if (filters[currentFilter] == "default") {
      if (testMode) filteredImg = defaultFilter(img, mouseX, mouseY);
      else filteredImg = defaultFilter(img, gx, gy);
    } else if (filters[currentFilter] == "spotlight") {
      if (testMode) filteredImg = spotlight(img, mouseX, mouseY);
      else filteredImg = spotlight(img, gx, gy);
    } else if (filters[currentFilter] == "ascii") {
      if (testMode) filteredImg = colorPopFilter(img, mouseX, mouseY);
      else filteredImg = colorPopFilter(img, gx, gy);
    } else if (filters[currentFilter] == "colorPop") {
      if (testMode) filteredImg = asciiFilter(img, mouseX, mouseY);
      else filteredImg = asciiFilter(img, gx, gy);
    } else if (filters[currentFilter] == "pixelate") {
      if (testMode) filteredImg = pixelateFilter(img, mouseX, mouseY);
      else filteredImg = pixelateFilter(img, gx, gy);
    } else if (filters[currentFilter] == "dither") {
      if (testMode) filteredImg = ditherFilter(img, mouseX, mouseY);
      else filteredImg = ditherFilter(img, gx, gy);
    } else if (filters[currentFilter] == "invert") {
      if (testMode) filteredImg = invertFilter(img, mouseX, mouseY);
      else filteredImg = invertFilter(img, gx, gy);
    }
  
    background(filteredImg);
    
    // Display filter name
    fill(255);
    textSize(32);
    textAlign(LEFT);
    text("Filter: " + filters[currentFilter], 20, 50);
  }
}

// Press any key to rotate between filters
void keyPressed() {
  currentFilter = (currentFilter + 1) % filters.length;
}

void receive(byte[] data) {
  String msg = new String(data).trim();
  String[] parts = msg.split(",");
  if (parts.length == 2) {
    gx = int(parts[0]);
    gy = int(parts[1]);
    hasGaze = true;
  }
}
