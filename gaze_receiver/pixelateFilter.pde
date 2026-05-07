int pixelSize = 20;
int pixelRadius = 240;

PImage pixelateFilter(PImage src, int gazeX, int gazeY) {
    PImage target = src.copy();
    src.loadPixels();
    target.loadPixels();
    
    for (int y = 0; y < src.height; y += pixelSize) {
        for (int x = 0; x < src.width; x += pixelSize) {
            // Check if this block is OUTSIDE the gaze radius (inverted pixelation)
            float d = dist(x + pixelSize/2, y + pixelSize/2, gazeX, gazeY);
            float pixelEffect = map(d, pixelRadius * 0.65, pixelRadius, 0, 1);
            pixelEffect = constrain(pixelEffect, 0, 1);
            
            if (pixelEffect > 0) {
                // Average color in this block
                float sumR = 0, sumG = 0, sumB = 0;
                int count = 0;
                
                for (int py = y; py < y + pixelSize && py < src.height; py++) {
                    for (int px = x; px < x + pixelSize && px < src.width; px++) {
                        int idx = px + py * src.width;
                        color c = src.pixels[idx];
                        sumR += red(c);
                        sumG += green(c);
                        sumB += blue(c);
                        count++;
                    }
                }
                
                float avgR = sumR / count;
                float avgG = sumG / count;
                float avgB = sumB / count;
                
                // Apply pixelation based on proximity (inverted)
                for (int py = y; py < y + pixelSize && py < src.height; py++) {
                    for (int px = x; px < x + pixelSize && px < src.width; px++) {
                        int idx = px + py * src.width;
                        color original = src.pixels[idx];
                        
                        float r = lerp(red(original), avgR, pixelEffect);
                        float g = lerp(green(original), avgG, pixelEffect);
                        float b = lerp(blue(original), avgB, pixelEffect);
                        
                        target.pixels[idx] = color(r, g, b);
                    }
                }
            }
        }
    }
    
    target.updatePixels();
    return target;
}
