import hypermedia.net.*;

UDP udp;
int gx, gy;
boolean hasGaze = false;

void setup() {
  fullScreen();
  background(0);
  udp = new UDP(this, 5005);
  udp.listen(true);
  gx = width / 2;
  gy = height / 2;
}

void draw() {
  background(0);
  if (hasGaze) {
    stroke(255);
    strokeWeight(3);
    noFill();
    ellipse(gx, gy, 80, 80);
  }
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
