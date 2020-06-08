# Setting up OpenVPN (PrivateInternetAccess) and using it through a Wifi Hotspot
### Description
The goal is to have the RPi itself aswell as any devices connecting through the RPi Wifi hotspot use the PIA VPN and PiHole for adblocking.

Because trying to patch this together broke my previous build, I started from fresh. So this is a good starting point
### Getting ready
0. Connect RPi via Ethernet cable
1. Enabling Onboard WiFi
   - connect to RPi through KiTTY (root)
   ```
   dietpi-config
   ```
   - Network Options: Adapters
   - Onboard WiFi: **On**
   ```
   reboot
   ```
   - (Optional) In the same network menu internet connection can be tested, but should work fine.
2. Make IP static
   - In the same network menu go to the 'Ethernet' settings and change Mode from DHCP (default) to STATIC.
   - Select *Copy current adress to "Static"*
   - Confirm and cancel when asked if you want to purge WiFi stuff.
   - Exit out of Network menu with Esc
3. Make sure you have all the programs we need installed
   - Install ProFTPD, OpenVPN and a desktop environment (I used XFCE) through the 'dietpi-software' GUI
     - For the desktop to work later, go into 'dietpi-config' > 'Display Resolution' and choose a resolution (I chose 1080p)
   - Install dnsmasq and openresolv through the terminal:
   ```
   apt-get install dnsmasq && apt-get install openresolv 
   ```
   - Confirm everything with Y
   ```
   reboot
   ```
   - Check if your stuff is installed
     - 'dietpi-software' > 'uninstall' to see all installed software. Should look like this 
       ![Installed software](https://i.imgur.com/oTHTjHG.png)
     - and 'dietpi-services' should look like this
       ![Installed services](https://i.imgur.com/Ks6OzZ4.png)
   
### Download, edit and push necessary files
#### Download


#### Sources
   - https://gist.github.com/superjamie/ac55b6d2c080582a3e64
   - https://github.com/alfredopalhares/openvpn-update-resolv-conf
   - https://forums.openvpn.net/viewtopic.php?t=26388
