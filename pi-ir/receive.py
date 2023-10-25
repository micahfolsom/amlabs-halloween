#!/usr/bin/env python
import piir
import time

while True:
    print("Checking for data")
    data = piir.decode(piir.io.receive(23))
    print(data)
    if data:
        print("Receive data: " + str(data))
