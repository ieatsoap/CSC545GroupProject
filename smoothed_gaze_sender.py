# has smoothing, outlier rejection, fallback behavior, and a mouse test mode
# exponential moving average reduces jitter
# outlier rejection helps with removing sudden spikes
# fallback behavior helps with the snapping when tracking is lost
# mouse test mode is just to help with debugging
import time
import socket
import pygame
from gazefollower import GazeFollower

# config
UDP_IP = "127.0.0.1"
UDP_PORT = 5005

USE_MOUSE_TEST_MODE = False  # toggle this

ALPHA = 0.2          # smoothing factor (0.1 = smooth, 0.4 = more responsive)
MAX_JUMP = 150       # max allowed jump in pixels
SEND_RATE = 1 / 60   # 60Hz

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

pygame.init()
info = pygame.display.Info()
window = pygame.display.set_mode(
    (info.current_w, info.current_h), pygame.FULLSCREEN
)

clock = pygame.time.Clock()

gf = None
if not USE_MOUSE_TEST_MODE:
    gf = GazeFollower()
    gf.preview(win=window)
    gf.calibrate(win=window)

# minimize pygame window (mac workaround)
pygame.display.iconify()
pygame.event.pump()

if gf:
    gf.start_sampling()
    time.sleep(0.1)


smoothed_x, smoothed_y = None, None
last_valid_x, last_valid_y = info.current_w // 2, info.current_h // 2

try:
    while True:
        pygame.event.pump()

        # get input (gaze or mouse)
        valid = False

        if USE_MOUSE_TEST_MODE:
            x, y = pygame.mouse.get_pos()
            valid = True
        else:
            gaze_info = gf.get_gaze_info()
            if gaze_info and gaze_info.status:
                x, y = gaze_info.filtered_gaze_coordinates

                if x != -65536 and y != -65536:
                    valid = True

        # handle valid/invalid
        if valid:
            # initialize smoothing
            if smoothed_x is None:
                smoothed_x, smoothed_y = x, y

            # outlier rejection
            if (
                abs(x - smoothed_x) < MAX_JUMP
                and abs(y - smoothed_y) < MAX_JUMP
            ):
                # EMA smoothing
                smoothed_x = ALPHA * x + (1 - ALPHA) * smoothed_x
                smoothed_y = ALPHA * y + (1 - ALPHA) * smoothed_y

                last_valid_x, last_valid_y = smoothed_x, smoothed_y

        else:
            # fallback to last known position
            smoothed_x, smoothed_y = last_valid_x, last_valid_y

        # send data
        if smoothed_x is not None and smoothed_y is not None:
            msg = f"{int(smoothed_x)},{int(smoothed_y)}"
            sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))

        
        clock.tick(60)

# exit
except KeyboardInterrupt:
    print("\nStopped.")

finally:
    if gf:
        gf.stop_sampling()
        gf.release()

    sock.close()
    pygame.quit()
