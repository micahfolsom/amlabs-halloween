#!/usr/bin/env python
import pygame
import time
import random

class Timer:
    def __init__(self, duration):
        # ms
        self.start_time = 0
        # ms
        self.duration = duration

    def start(self, offset = 0):
        self.start_time = get_time_ms() - offset

    def finished(self) -> bool:
        elapsed = get_time_ms() - self.start_time
        if (elapsed >= self.duration):
            return True
        else:
            return False

RED_GHOST = 0
PINK_GHOST = 1
YELLOW_GHOST = 2
STATE_RISING = 0
STATE_FLOATING = 1
STATE_DYING = 2
class GhostAnim:
    def __init__(self, which_ghost):
        # Set this equal to the highest number file
        self.NFRAMES = 169
        # Ending frame # for the different parts of the animation
        self.END_FRAMES = [80, 151]
        self.rising_frames = []
        self.floating_frames = []
        self.dying_frames = []
        self.iframe = 0
        # How long he stays dead, in ms
        self.kill_cooldown = Timer(get_rand_respawn())
        self.kill_cooldown.start()
        self.this_ghost = which_ghost
        self.state = STATE_RISING
        # Sounds
        pygame.mixer.init()
        pygame.music.load('ghost_shot.mp3')

        prefix = ""
        if self.this_ghost == RED_GHOST:
            prefix = "/home/ghost/repos/amlabs-halloween/pi-ir/red_frames/frame"
        elif self.this_ghost == PINK_GHOST:
            prefix = "/home/ghost/repos/amlabs-halloween/pi-ir/pink_frames/frame"
        else:
            prefix = "/home/ghost/repos/amlabs-halloween/pi-ir/yellow_frames/frame"

        for i in range(1, self.NFRAMES):
            if i <= self.END_FRAMES[0]:
                self.rising_frames.append(pygame.image.load(f"{prefix}{i + 1}.png"))
            elif i <= self.END_FRAMES[1]:
                self.floating_frames.append(pygame.image.load(f"{prefix}{i + 1}.png"))
            else:
                self.dying_frames.append(pygame.image.load(f"{prefix}{i + 1}.png"))

    def kill(self):
        if self.kill_cooldown.finished() and self.state == STATE_FLOATING:
            self.state = STATE_DYING
            self.iframe = 0
            self.kill_cooldown.duration = get_rand_respawn()
            self.kill_cooldown.start()
            pygame.mixer.music.play()

    def reset(self):
        self.state = STATE_RISING
        self.iframe = 0

    def next_frame(self, window):
        if self.state == STATE_RISING:
            window.blit(source=self.rising_frames[self.iframe], dest=(0, 0))
            self.iframe = self.iframe + 1
            if self.iframe >= (self.END_FRAMES[STATE_RISING] - 1):
                self.state = STATE_FLOATING
                self.iframe = 0
        elif self.state == STATE_FLOATING:
            window.blit(source=self.floating_frames[self.iframe], dest=(0, 0))
            self.iframe = self.iframe + 1
            if self.iframe >= ((self.END_FRAMES[STATE_FLOATING] - self.END_FRAMES[STATE_RISING]) - 1):
                self.iframe = 0
        else:
            window.blit(source=self.dying_frames[self.iframe], dest=(0, 0))
            self.iframe = self.iframe + 1
            if self.iframe >= ((self.NFRAMES - self.END_FRAMES[STATE_FLOATING]) - 1):
                if self.kill_cooldown.finished():
                    self.state = STATE_RISING
                    self.iframe = 0
                else:
                    self.iframe = self.iframe - 1

def get_time_ms():
    return time.time() * 1000

# Returns a random respawn time in ms
def get_rand_respawn() -> float:
    return random.uniform(10000.0, 20000.0)
