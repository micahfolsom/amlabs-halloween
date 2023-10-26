#!/usr/bin/env python
import pygame
import RPi.GPIO as gpio
import time
from .utility import Timer, GhostAnim, get_time_ms

# Ghost settings
RED_GHOST = 0
PINK_GHOST = 1
YELLOW_GHOST = 2
THIS_GHOST = RED_GHOST
STATE_RISING = 1
STATE_FLOATING = 2
STATE_DYING = 3
state = STATE_RISING

# GPIO pin numbers
TRIGGER_PIN = 5
RESET_PIN = 6
# Use GPIO pin numbering, not raw header locations
gpio.setmode(gpio.BCM)
gpio.setup(TRIGGER_PIN, gpio.IN)
gpio.setup(RESET_PIN, gpio.IN)

# Init window, etc
pygame.init()
window = pygame.display.set_mode((1280, 720), pygame.FULLSCREEN)
pygame.display.set_caption("Spooky")
clock = pygame.time.Clock()

frame_timer = Timer(30)
frame_timer.start()
ghost_anim = GhostAnim()
running = True
while running:
    try:
        # Check for window close
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    print("ESC pressed. Exiting.")
                    running = False

        if gpio.input(TRIGGER_PIN):
            ghost_anim.kill()
        if gpio.input(RESET_PIN):
            ghost_anim.reset()

        if frame_timer.finished():
            ghost_anim.next_frame(window)
            pygame.display.update()
            frame_timer.start = time.time() * 1000
            # 20 fps max
            #clock.tick(20)

    # Check for CTRL+C
    except KeyboardInterrupt:
        running = False

pygame.quit()
