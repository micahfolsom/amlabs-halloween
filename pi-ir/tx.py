#!/usr/bin/env python
import RPi.GPIO as gpio
from vlc import Instance
import time
import os

# GPIO pin numbers
TRIGGER_PIN = 5
RESET_PIN = 6

# Use GPIO pin numbering, not raw header locations
gpio.setmode(gpio.BCM)
gpio.setup(TRIGGER_PIN, gpio.IN)
gpio.setup(RESET_PIN, gpio.IN)

#vlc_player = Instance('--loop --qt-fullscreen-screennumber=0')
vlc_player = Instance()
vlc_player2 = Instance('--loop --qt-fullscreen-screennumber=0')
#path = "/home/micah/repos/amlabs-halloween/pi-ir/videos"
path1 = "/home/micah/repos/amlabs-halloween/pi-ir/videos/Green1.mp4"
path2 = "/home/micah/repos/amlabs-halloween/pi-ir/videos/Green2.mp4"
path3 = "/home/micah/repos/amlabs-halloween/pi-ir/videos/Green3.mp4"
#videos = os.listdir(path)
#media = vlc_player.media_list_new()
#for v in videos:
#    media.add_media(vlc_player.media_new(os.path.join(path, v)))
#list_player = vlc_player.media_list_player_new()
#list_player.set_media_list(media)
#media_player = list_player.get_media_player()
#media_player.set_fullscreen(True)
#list_player.play()
player = vlc_player.media_player_new()
player2 = vlc_player2.media_player_new()
media1 = vlc_player.media_new(path1)
media2 = vlc_player.media_new(path2)
media2.add_option('-repeat')
media3 = vlc_player.media_new(path3)
player.set_media(media1)
player.set_fullscreen(True)
player.play()
time.sleep(4)
player.set_media(media2)
#player.set_fullscreen(True)
vlc_player.vlm_set_loop("Green2", True)
player.play()

class Timer:
    def __init__(self):
        self.start = 0
        self.duration = 100
        self.running = False

rec_timer = Timer()
rec_timer.start = time.time()
signal_received = False

try:
    while True:
        # Check for IR received
        val = gpio.input(TRIGGER_PIN);
        if val == 1:
            print(f"{TRIGGER_PIN}: HIGH. {val}")
            player.set_media(media3)
            player.play()
            time.sleep(1)

        val = gpio.input(RESET_PIN)
        if val == 1:
            print(f"{RESET_PIN}: HIGH. {val}")
            player.set_media(media1)
            player.play()
            time.sleep(4)
            player.set_media(media2)
            player.play()


except KeyboardInterrupt:
    pass

finally:
    gpio.cleanup()
