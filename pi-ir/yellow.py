#!/usr/bin/env python
import pygame
import RPi.GPIO as gpio
import time
from utility import (
    Timer,
    GhostAnim,
    get_time_ms,
    RED_GHOST, PINK_GHOST, YELLOW_GHOST
)

# Ghost settings
THIS_GHOST = YELLOW_GHOST

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

frame_timer = Timer(20)
frame_timer.start()
ghost_anim = GhostAnim(THIS_GHOST)
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
                if event.key == pygame.K_1:
                    print("1 pressed, killing")
                    ghost_anim.kill()
                if event.key == pygame.K_2:
                    print("2 pressed, resetting")
                    ghost_anim.reset()

        if gpio.input(TRIGGER_PIN):
            ghost_anim.kill()
        if gpio.input(RESET_PIN):
            ghost_anim.reset()

        if frame_timer.finished():
            ghost_anim.next_frame(window)
            pygame.display.update()
            frame_timer.start()
            # 20 fps max
            #clock.tick(20)

    # Check for CTRL+C
    except KeyboardInterrupt:
        running = False

pygame.quit()
