int ditherRadius = 260;

// Bayer matrix for dithering pattern
int[][] bayerMatrix = {
    {0, 8, 2, 10},
    {12, 4, 14, 6},
    {3, 11, 1, 9},
    {15, 7, 13, 5}
};

PImage ditherFilter(PImage src, int gazeX, int gazeY) {
    PImage target = src.copy();
    src.loadPixels();
    target.loadPixels();
    
    // Reduce color palette to 8 colors for dithering effect
    int colorLevels = 2;
    
    for (int y = 0; y < src.height; y++) {
        for (int x = 0; x < src.width; x++) {
            float d = dist(x, y, gazeX, gazeY);
            float ditherAmount = map(d, ditherRadius * 0.65, ditherRadius, 1, 0);
            ditherAmount = constrain(ditherAmount, 0, 1);
            
            int idx = x + y * src.width;
            color c = src.pixels[idx];
            
            float r = red(c);
            float g = green(c);
            float b = blue(c);
            
            if (ditherAmount > 0) {
                // Apply dithering with Bayer matrix
                int bayerX = x % 4;
                int bayerY = y % 4;
                float threshold = (bayerMatrix[bayerY][bayerX] / 16.0) * 255;
                
                // Quantize and dither
                float qR = quantize(r, colorLevels);
                float qG = quantize(g, colorLevels);
                float qB = quantize(b, colorLevels);
                
                // Apply dither based on threshold
                if (r - qR > threshold / 255.0 * 127) qR = constrain(qR + 255/colorLevels, 0, 255);
                if (g - qG > threshold / 255.0 * 127) qG = constrain(qG + 255/colorLevels, 0, 255);
                if (b - qB > threshold / 255.0 * 127) qB = constrain(qB + 255/colorLevels, 0, 255);
                
                // Blend dithered and original
                r = lerp(r, qR, ditherAmount);
                g = lerp(g, qG, ditherAmount);
                b = lerp(b, qB, ditherAmount);
            }
            
            target.pixels[idx] = color(r, g, b);
        }
    }
    
    target.updatePixels();
    return target;
}

float quantize(float value, int levels) {
    return round(value / 255.0 * levels) / levels * 255.0;
}
