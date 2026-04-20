int asciiRadius = 150;
int asciiCharSize = 8;
String asciiChars = "@G7+-:. ";

PImage asciiFilter(PImage src, int gazeX, int gazeY) {
    PImage target = src.copy();
    target.filter(GRAY);
    
    // Create a graphics buffer for ASCII rendering
    PGraphics pg = createGraphics(target.width, target.height);
    pg.beginDraw();
    pg.background(0);
    
    // ASCII art effect around gaze point
    pg.fill(255);
    pg.textSize(asciiCharSize+1);
    pg.textAlign(LEFT);
    
    src.loadPixels();
    
    for (int y = 0; y < src.height; y += asciiCharSize) {
        for (int x = 0; x < src.width; x += asciiCharSize) {
            float d = dist(x, y, gazeX, gazeY);
            
            // Apply ASCII effect within radius
            if (d < asciiRadius) {
                // Get average brightness of the region
                float brightness = 0;
                int count = 0;
                for (int dy = 0; dy < asciiCharSize && y + dy < src.height; dy++) {
                    for (int dx = 0; dx < asciiCharSize && x + dx < src.width; dx++) {
                        int idx = (x + dx) + (y + dy) * src.width;
                        brightness += brightness(src.pixels[idx]);
                        count++;
                    }
                }
                brightness /= count;
                
                // Map brightness to ASCII character
                int charIdx = int(map(brightness, 0, 255, asciiChars.length() - 1, 0));
                charIdx = constrain(charIdx, 0, asciiChars.length() - 1);
                char asciiChar = asciiChars.charAt(charIdx);
                
                pg.fill(255, 255);
                pg.text(asciiChar, x, y + asciiCharSize);
            }
        }
    }
    
    pg.endDraw();
    
    // Combine ASCII graphics with the original image
    target.loadPixels();
    PImage asciiImg = pg.get();
    asciiImg.loadPixels();
    
    for (int i = 0; i < target.pixels.length; i++) {
        int x = i % target.width;
        int y = i / target.width;
        float d = dist(x, y, gazeX, gazeY);
        
        if (d < asciiRadius) {
            target.pixels[i] = asciiImg.pixels[i];
        }
    }
    
    target.updatePixels();
    return target;
}
