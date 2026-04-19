import time
import socket
import pygame
from gazefollower import GazeFollower

UDP_IP = "127.0.0.1"
UDP_PORT = 5005

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

gf = GazeFollower()

pygame.init()
info = pygame.display.Info()
window = pygame.display.set_mode((info.current_w, info.current_h), pygame.FULLSCREEN)

gf.preview(win=window)
gf.calibrate(win=window)

pygame.display.iconify()
pygame.event.pump()

gf.start_sampling()
time.sleep(0.1)

try:
    while True:
        info = gf.get_gaze_info()
        if info and info.status:
            x, y = info.filtered_gaze_coordinates
            if x != -65536 and y != -65536:
                sock.sendto(f"{int(x)},{int(y)}".encode(), (UDP_IP, UDP_PORT))
        time.sleep(0.016)  # ~60hz
except KeyboardInterrupt:
    print("\nStopped.")
finally:
    gf.stop_sampling()
    gf.release()
    sock.close()
