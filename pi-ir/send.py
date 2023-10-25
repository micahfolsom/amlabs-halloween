#!/usr/bin/env python
import piir
import time

remote = piir.Remote('test.json', 17)

while True:
    remote.send_data('CC', repeat=10)
    print("Sending data: CC")

    time.sleep(1)
