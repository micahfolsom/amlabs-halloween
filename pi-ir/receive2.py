# Assumes device already configured with ir-keytable
# Must call "sudo ir-keytable --protocol=nec"
from evdev import *
from vlc import Instance
import os

vlc_player = Instance('--loop --qt-fullscreen-screennumber=0')
path = "/home/micah/repos/amlabs-halloween/pi-ir/videos"
videos = os.listdir(path)
media = vlc_player.media_list_new()
for v in videos:
    media.add_media(vlc_player.media_new(os.path.join(path, v)))
list_player = vlc_player.media_list_player_new()
list_player.set_media_list(media)
media_player = list_player.get_media_player()
media_player.set_fullscreen(True)
list_player.play()

devices = [InputDevice(path) for path in list_devices()]
# Define IR input
irin = None
for device in devices:
    #print(device.path, device.name, device.phys)
    if(device.name=="gpio_ir_recv"):
        irin = device

if(irin == None):
    print("Unable to find IR input device, exiting")
    exit(1)

print("IR input device found at", irin.path)

# Read events and return string
def readInputEvent(device):
    for event in device.read_loop():
        if event.type == ecodes.EV_MSC:
            print("MSC Event received")
            print("Scan code: " + str(event.code))
            data = categorize(event)
            print(data)
            print(data.value)
            list_player.next()
            #print("Key code: " + data.keycode)
        # Event returns sec, usec (combined with .), type, code, value
        # Type 01 or ecodes.EV_KEY is a keypress event
        # a value of  0 is key up, 1 is key down
        # the code is the value of the keypress
        # Full details at https://python-evdev.readthedocs.io/en/latest/apidoc.html

        # However we can use the categorize structure to simplify things
        # .keycode - Text respresentation of the key
        # .keystate - State of the key, may match .key_down or .key_up
        # See https://python-evdev.readthedocs.io/en/latest/apidoc.html#evdev.events.InputEvent
        if event.type == ecodes.EV_KEY:
            print("Event received")
            # Alert about keydown on the 8 key
            if(event.code == ecodes.KEY_8 and event.value==1):
                print("Detected keydown event on the 8")

            # Or use categorize. This is more useful if we want to write a function to
            # return a text representation of the button press on a key down
            #print(categorize(event))
            data = categorize(event)
            if(data.keycode=="KEY_5" and data.keystate==data.key_down):
                print("Detected keydown event on the 5")
            else:
                print(data.keycode, "up/down")
            print()

while True:
    readInputEvent(irin)
