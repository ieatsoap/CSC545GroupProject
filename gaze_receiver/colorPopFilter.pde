int popRadius = 280;

PImage colorPopFilter(PImage src, int gazeX, int gazeY) {
    PImage target = createImage(src.width, src.height, RGB);
    src.loadPixels();
    
    for (int y = 0; y < src.height; y++) {
        for (int x = 0; x < src.width; x++) {
            float d = dist(x, y, gazeX, gazeY);
            
            // Determine saturation based on proximity to gaze point 
            float saturation = map(d, popRadius * 0.65, popRadius, 1, 0);
            saturation = constrain(saturation, 0, 1);
            
            int idx = x + y * src.width;
            color c = src.pixels[idx];
            
            float r = red(c);
            float g = green(c);
            float b = blue(c);
            
            // Desaturate based on distance
            float gray = (r + g + b) / 3.0;
            r = lerp(gray, r, saturation);
            g = lerp(gray, g, saturation);
            b = lerp(gray, b, saturation);
            
            target.pixels[idx] = color(r, g, b);
        }
    }
    
    target.updatePixels();
    return target;
}
