#!/usr/bin/env python
import pygame
import RPi.GPIO as gpio

# GPIO pin numbers
TRIGGER_PIN = 5
RESET_PIN = 6
# Use GPIO pin numbering, not raw header locations
gpio.setmode(gpio.BCM)
gpio.setup(TRIGGER_PIN, gpio.IN)
gpio.setup(RESET_PIN, gpio.IN)

# Init window, etc
pygame.init()
window = pygame.display.set_mode(size=(1280, 720))
pygame.display.set_caption("Spooky")
# TODO: fullscreen
clock = pygame.time.Clock()

NFRAMES = 210
# Ending frame # for the different parts of the animation
END_FRAMES = [81, 160]
rising_frames = []
floating_frames = []
dying_frames = []
for i in range(1, NFRAMES):
    if i <= END_FRAMES[0]:
        rising_frames.append(pygame.image.load(f"out{i + 1}.png"))
    elif i <= END_FRAMES[1]:
        floating_frames.append(pygame.image.load(f"out{i + 1}.png"))
    else:
        dying_frames.append(pygame.image.load(f"out{i + 1}.png"))

running = True
iframe = 0
# 0 = rising, 1 = floating, 2 = falling
state = 0
while running:
    try:
        # Check for window close
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_1:
                    state = 1
                    iframe = 0
                if event.key == pygame.K_2:
                    state = 2
                    iframe = 0
                if event.key == pygame.K_3:
                    state = 3
                    iframe = 0

        if gpio.input(TRIGGER_PIN):
            print(f"{TRIGGER_PIN}: HIGH. {val}")
            state = 3
            iframe = 0
        if gpio.input(RESET_PIN):
            print(f"{RESET_PIN}: HIGH. {val}")
            state = 1
            iframe = 0


        if state == 0:
            window.blit(source=rising_frames[iframe], dest=(0, 0))
            iframe = iframe + 1
            if iframe >= (END_FRAMES[0] - 1):
                state = 1
                iframe = 0
        elif state == 1:
            window.blit(source=floating_frames[iframe], dest=(0, 0))
            iframe = iframe + 1
            if iframe >= ((END_FRAMES[1] - END_FRAMES[0]) - 1):
                iframe = 0
        else:
            window.blit(source=dying_frames[iframe], dest=(0, 0))
            iframe = iframe + 1
            if iframe >= ((NFRAMES - END_FRAMES[1]) - 1):
                state = 0
                iframe = 0

        pygame.display.update()
        # 20 fps max
        clock.tick(20)


    # Check for CTRL+C
    except KeyboardInterrupt:
        running = False

pygame.quit()
