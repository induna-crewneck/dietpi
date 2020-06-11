**CAUTION! Some of the stuff in this Repo is still WIP. Use at your own caution. Probably don't use any of it**

# DietPi setup collection
This is primarily for myself to keep track of how I did things. I'm learning all this as I go along and chances are if I need to redo something I'll have to start researching again. So this way I can just redo what I did the last time that worked.
But as a byproduct this might be useful to others trying to do the stuff I did.

## Used hardware and tools
I'm running DietPi ([Download](https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Buster.7z)) on a Raspberry Pi 4 Modell B with 4GB RAM and a 128GB SanDisk Ultra microSDXC A1.

### Software
- SSH software: [KiTTY](https://dietpi.com/downloads/binaries/all/Kitty_Portable_DietPi.7z) (logged in as root)
- FTP software: [FileZilla Client](https://filezilla-project.org/) (usually logged in as dietpi, not as root)
- VNC software: [RealVNC VNC Viewer](https://www.realvnc.com/de/connect/download/viewer/) (logged in as root)

## Usefull stuff

####  Useful apps
Zip and Unzip
```
apt-get install zip && apt-get install unzip 
```
#### FTP setup
Install proftpd through the 'dietpi-software' GUI
##### FTP with root permissions:
```
nano  /etc/proftpd/proftpd.conf
```
Find 'RootLogin' and change 'off' to 'on'.
##### change FTP start folder
In the same file (proftpd.conf) look for 'Default Root' (should be /mnt/dietpi_userdata). Just change it to '/'
![Should look like this](https://i.imgur.com/X1P8eL5.png)
Exit and save with Ctrl+X and confirm with Y and then Enter.
