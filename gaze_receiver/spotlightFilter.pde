int spotlightRadius = 100;

PImage spotlight(PImage src, int gazeX, int gazeY) {
    PImage target = createImage(src.width, src.height, RGB);
    src.loadPixels();

    for (int y = 0; y < src.height; y++) {
        for (int x = 0; x < src.width; x++) {

            float d = dist(x, y, gazeX, gazeY);

            float alpha = map(d, 0, spotlightRadius*2, 0, 255);
            alpha = constrain(alpha, 0, 255);

            int idx = x + y * src.width;

            color c = src.pixels[idx];

            float r = red(c) * (1 - alpha / 255.0);
            float g = green(c) * (1 - alpha / 255.0);
            float b = blue(c) * (1 - alpha / 255.0);

            target.pixels[idx] = color(r, g, b);
        }
    }

    target.updatePixels();
    return target;
}