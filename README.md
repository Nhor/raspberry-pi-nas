# raspberry-pi-nas

This guide explains how to create your own NAS (Network Attached Storage) on a Raspberry Pi with USB flash drive(s) attached.

## Table of contents

1. [Prerequisites](#prerequisites)
2. [Initial setup](#initial-setup)
3. [Build](#build)
4. [License](#license)

## Prerequisites

Before starting make sure you have everything from the list below:

1. Raspberry Pi
2. Raspberry Pi power supply
3. microSD card
4. USB flash drive(s) (at least one, more can be used for backups)
5. RJ45 cable (more commonly known as Ethernet or LAN cable)
6. Memory card reader
7. HDMI display, mouse and keyboard
8. Network router or switch with at least one unoccupied Ethernet port

## Initial setup


You just need to make sure you're able to connect to Raspberry Pi through SSH. In case you aren't you can use this short guide:

1. Prepare a microSD card with [Raspbian](https://raspbian.org/) installed on it (e.g. through [balenaEtcher](https://www.balena.io/etcher/))
2. Put the microSD card into Raspberry Pi's microSD card slot
3. Plug the USB flash drive(s) into Raspberry Pi's USB ports
4. Connect Raspberry Pi to a HDMI display
5. Connect mouse and keybord to Raspberry Pi
6. Boot Raspberry Pi by plugging it to a power supply and setup the system
7. Enable SSH in Raspbian preferences and make it boot to CLI as booting to desktop will no longer be required
8. Shutdown Raspberry Pi
9. Unplug all the peripherals, leave only microSD card and USB flash drive(s)
10. Connect Raspberry Pi to the network through a RJ45 cable
11. Place the Raspberry Pi wherever you want, it won't be moved anywhere anymore
12. Plug Raspberry Pi to a power supply

## Build

You can either follow this scripted approach or a manual guide.

## License

The MIT License

Copyright (c) 2019 Norbert Mieczkowski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
