int invertRadius = 290;

PImage invertFilter(PImage src, int gazeX, int gazeY) {
    PImage target = src.copy();
    src.loadPixels();
    target.loadPixels();
    
    for (int y = 0; y < src.height; y++) {
        for (int x = 0; x < src.width; x++) {
            float d = dist(x, y, gazeX, gazeY);
            
            // Invert colors based on distance from gaze point 
            float invertAmount = map(d, invertRadius * 0.65, invertRadius, 1, 0);
            invertAmount = constrain(invertAmount, 0, 1);
            
            int idx = x + y * src.width;
            color c = src.pixels[idx];
            
            float r = red(c);
            float g = green(c);
            float b = blue(c);
            
            // Invert the color
            float invR = 255 - r;
            float invG = 255 - g;
            float invB = 255 - b;
            
            // Blend between original and inverted
            r = lerp(r, invR, invertAmount);
            g = lerp(g, invG, invertAmount);
            b = lerp(b, invB, invertAmount);
            
            target.pixels[idx] = color(r, g, b);
        }
    }
    
    target.updatePixels();
    return target;
}
