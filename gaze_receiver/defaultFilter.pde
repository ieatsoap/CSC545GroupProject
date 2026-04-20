PImage defaultFilter(PImage src, int gazeX, int gazeY) {
    PImage target = src.copy();
    
    // Create a graphics buffer to draw on
    PGraphics pg = createGraphics(target.width, target.height);
    pg.beginDraw();
    pg.image(target, 0, 0);
    pg.noFill();
    pg.stroke(255, 0, 0); // Red
    pg.strokeWeight(3);
    pg.circle(gazeX, gazeY, 100); 
    pg.endDraw();
    
    return pg.get();
}