#!/usr/bin/env python
#import pygame
import time

def get_time_ms():
    return time.time() * 1000

class Timer:
    def __init__(self, duration):
        # ms
        self.start = 0
        # ms
        self.duration = duration

    def start(self, offset = 0):
        self.start = get_time_ms() - offset

    def finished(self) -> bool:
        elapsed = get_time_ms() - self.start
        if (elapsed >= self.duration):
            return True
        else:
            return False

class GhostAnim:
    def __init__(self):
        self.NFRAMES = 168
        # Ending frame # for the different parts of the animation
        self.END_FRAMES = [80, 135]
        self.rising_frames = []
        self.floating_frames = []
        self.dying_frames = []
        self.iframe = 0
        self.kill_cooldown = Timer()
        self.kill_cooldown.start(10000)

        prefix = ""
        if THIS_GHOST == RED_GHOST:
            prefix = "red_frames/frame"
        elif THIS_GHOST == PINK_GHOST:
            prefix = "pink_frames/frame"
        else:
            prefix = "yellow_frames/frame"

        for i in range(1, self.NFRAMES):
            if i <= self.END_FRAMES[0]:
                self.rising_red_frames.append(pygame.image.load(f"{prefix}{i + 1}.png"))
            elif i <= self.END_FRAMES[1]:
                self.floating_red_frames.append(pygame.image.load(f"{prefix}frame{i + 1}.png"))
            else:
                self.dying_red_frames.append(pygame.image.load(f"{prefix}frame{i + 1}.png"))

    def kill(self):
        if self.kill_cooldown.finished():
            self.state = STATE_DYING
            self.iframe = 0
            self.kill_cooldown.start()

    def reset(self):
        self.state = STATE_RISING
        self.iframe = 0

    def next_frame(self, window):
        if state == STATE_RISING:
            window.blit(source=self.rising_frames[iframe], dest=(0, 0))
            self.iframe = self.iframe + 1
            if self.iframe >= (self.END_FRAMES[0] - 1):
                state = STATE_FLOATING
                self.iframe = 0
        elif state == STATE_FLOATING:
            window.blit(source=self.floating_frames[self.iframe], dest=(0, 0))
            self.iframe = self.iframe + 1
            if self.iframe >= ((self.END_FRAMES[1] - self.END_FRAMES[0]) - 1):
                self.iframe = 0
        else:
            window.blit(source=self.dying_frames[self.iframe], dest=(0, 0))
            self.iframe = self.iframe + 1
            if self.iframe >= ((self.NFRAMES - self.END_FRAMES[1]) - 1):
                state = STATE_RISING
                self.iframe = 0
