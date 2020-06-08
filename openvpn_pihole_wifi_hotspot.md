# Setting up OpenVPN (PrivateInternetAccess) and using it through a Wifi Hotspot
### Description
The goal is to have the RPi itself aswell as any devices connecting through the RPi Wifi hotspot use the PIA VPN and PiHole for adblocking.

Because trying to patch this together broke my previous build, I started from fresh. So this is a good starting point
# OpenVPN
## Preparation
If you have all of the following already set up you can skip this: Ethernet connection with Static IP, openvpn, proftpd, desktop, dnsmasq, openresolv installed. If not follow these steps:

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
       
(Optional) At this point I made a backup using 'dietpi-backup' because we start editing config files and stuff.

## Editing config files and stuff
### Download VPN Files
If you want to get the files freshly from their source to make sure they are up to date and safe, contunue. I also uploaded my files [here](/Files/PIA-VPN) which you can use as they are not personalized. If you use my files you can skip to [Push](#push)

Download and unpack the [DEFAULT](https://www.privateinternetaccess.com/openvpn/openvpn.zip) or [STRONG](https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip) Configuration Files from PIA. I used the strong 4096-bit files. If you want to use the default files replace every instance of 4096 in the code with 2048. 

Download 'update-resolv-conf.sh' from [here](https://github.com/alfredopalhares/openvpn-update-resolv-conf).

### Editing the VPN files
Pick the server that you want to use. For this I will use the US East server. Rename the ovpn file of the server you chose to change the file extension from '.ovpn' to '.conf' and replace any spaces with underscores. So 'US East.ovpn' becomes 'US_East.conf'

Open the file with a text editor. There should be a line saying 'auth-user-pass' and there may be lines saying 'ca' and 'crl-verify' but there may not be. Just make sure these lines are added/edited to say:
```
ca /etc/openvpn/ca.rsa.4096.crt
auth-user-pass /etc/openvpn/login
crl-verify /etc/openvpn/crl.rsa.4096.pem
```
also add these lines to the very end of the file:
```
script-security 2
up /etc/openvpn/update-resolv-conf.sh
down /etc/openvpn/update-resolv-conf.sh
down-pre
```
### Push files to the Pi
This is where FTP comes into play. You should already have proftpd installed on the Pi and a FTP client as FileZilla installed on your PC. Connect the FTP client to your Pi (using root can make things easier here).

We need to copy 4 files in total to /etc/openvpn/ on the Pi:

- ca.rsa.4096.crt
- crl.rsa.4096.pem 
- US_East.conf
- update-resolv-conf.sh

Now we need to create a file with your login files from PIA for OpenVPN to use.
```
nano /etc/openvpn/login
```
enter your username (p*******) and your password in the line below. Ctrl+X to Exit, confirm with Y and Enter to save. This file should only be readable by root, so set permissions accordingly
```
sudo chmod 600 /etc/openvpn/login
```

### Editing configs
Told you this was coming. We need to edit the Client Config files from OpenVPN. The config file is named 'DietPi_OpenVPN_Client.ovpn' and located in two direcories. So first:
```
nano /boot/DietPi_OpenVPN_Client.ovpn
```
and remove the following lines:
```
user nobody
group nogroup
```
Again, exit, save, confirm and onto the second location:
```
nano /mnt/dietpi_userdata/DietPi_OpenVPN_Client.ovpn
```
remove the same lines, exit and save. Now we need to make sure the update-resolv-conf.sh file that we copied earlier is accessible by openvpn. So set the permissions accordingly:
```
chmod 755 /etc/openvpn/update-resolv-conf.sh
```
Final edit is enabling port forwarding with this:
```
echo -e '\n#Enable IP Routing\nnet.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
sysctl -p
```
     This is just an easier way of adding the line *net.ipv4.ip_forward = 1* to /etc/sysctl.conf than doing it manually.

Now we enable VPN at boot
```
systemctl enable openvpn@US_East
```
and we should be done

## Testing (optional, but satisfying)
### Test 1
Still in the console, enter
```
openvpn --config /etc/openvpn/US_East.conf
```
should output something along these lines:
```
Mon Jun  8 20:38:35 2020 OpenVPN 2.4.7 arm-unknown-linux-gnueabihf [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Feb 20 2019
Mon Jun  8 20:38:35 2020 library versions: OpenSSL 1.1.1d  10 Sep 2019, LZO 2.10
Mon Jun  8 20:38:35 2020 NOTE: the current --script-security setting may allow this configuration to call user-defined scripts
Mon Jun  8 20:38:36 2020 TCP/UDP: Preserving recently used remote address: [AF_INET]194.59.251.166:1197
Mon Jun  8 20:38:36 2020 UDP link local: (not bound)
Mon Jun  8 20:38:36 2020 UDP link remote: [AF_INET]194.59.251.166:1197
Mon Jun  8 20:38:36 2020 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
Mon Jun  8 20:38:36 2020 [5022e095491f6d1120dd1323fcb890bf] Peer Connection Initiated with [AF_INET]194.59.251.166:1197
Mon Jun  8 20:38:37 2020 TUN/TAP device tun1 opened
Mon Jun  8 20:38:37 2020 /sbin/ip link set dev tun1 up mtu 1500
Mon Jun  8 20:38:37 2020 /sbin/ip addr add dev tun1 local 10.25.10.6 peer 10.25.10.5
Mon Jun  8 20:38:37 2020 /etc/openvpn/update-resolv-conf.sh tun1 1500 1570 10.25.10.6 10.25.10.5 init
Mon Jun  8 20:38:38 2020 Initialization Sequence Completed
```
What you are looking for here is the IP after [AF_INET]. If you put that into something like ipleak.net you'll see if the VPN is working. To exit the test and get back to the console: Ctrl+C
### Test 2
Back in the console, enter:
```
systemctl status openvpn@US_East
```
It *should* look something like this. 
![OpenVPN active](https://i.imgur.com/hDEcpOr.png)
Also, again further down you'll find an [AF_INET] IP that you can input into ipleak.net. You should also see two DNS adresses:
```
209.222.18.222
209.222.18.218
```
These are the PIA DNS adresses. If that's all there you're good.
### Final test
Let's test this through the desktop we installed earlier. To enable it, go to 'dietpi-autostart' and choose 'Automatic Login' under 'Desktops' (Should Option 2). Select root, confirm, exit out of the autostart menu and 'reboot'.

Now we open up our VNC Viewer of choice and connect to the Pi. If it's not working and showing "Cannot currently show the desktop", don't cry just yet. Instead, run
```
apt-get update -qq
apt-get upgrade -qq
reboot
```
if it still doesn't work

```
cp /DietPi/config.txt /DietPi/config.txt.backup
nano /DietPi/config.txt
```
find
```
#hdmi_force_hotplug=0
...
#hdmi_group=1
#hdmi_mode=1
```
remove the # and change to look like this
```
hdmi_force_hotplug=2
...
hdmi_group=2
hdmi_mode=82
```
Now we should be on de Pi Desktop. Start up your web browser and go to ipleak.net. If it looks like this, everything is perfect!
![greatsuccess](https://i.imgur.com/LlEFakw.png)

You can now change the dietpi-autostart back to Automatic Login in Local Terminal.

# Wifi Hotpot
Now comes the second part of our Triwizard Tournament. Again, I made a backup at this point.

### Installing the access point
Through 'dietpi-software' select 'WiFi Hotspot'. It does two checks for ethernet connection and wifi adapter. If you FAIL the wifi adapter check, make sure wifi onboard is enabled in 'dietpi-config'. Then you can install.

test with
```
systemctl status hostapd.service
```
If it spurts errors, check if you have a hostapd.conf in /etc/hostapd. If not, download it from [here](/Files/hostapd.conf) and push it there with FileZilla. Also, if there's a file there, back it up and replace it. Then reboot and try again. We want it to look like this

![hostapd running](https://i.imgur.com/w8TP89x.png)

### Configuring static IP for the wlan0 interface
```
nano /etc/dhcpcd.conf
```
enter
```
interface wlan0
static ip_address=192.168.0.10/24
denyinterfaces tun0
denyinterfaces wlan0
```
(Replace 192.168.0.10 with your desired wifi IP)

#### Configure DNSmasq
First, let's backup the config
```
mv /etc/dnsmasq.conf /etc.dnsmasq/conf.backup
```
now let's create a new one
```
nano /etc/dnsmasq.conf
```
and enter:
```
interface=wlan0
  dhcp-range=192.168.0.11,192.168.0.30,255.255.255.0,24h
```
The two IPs define the range of IPs for the wlon0 interface.

#### Add new iptables rule
Next, we’re going to add IP masquerading for outbound traffic on eth0 using iptables:
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
…and save the new iptables rule:
```
sh -c "iptables-save > /etc/iptables.ipv4.nat"
```
To load the rule on boot, we need to edit the file /etc/rc.local and add the following
line just above the line exit 0:
```
iptables-restore < /etc/iptables.ipv4.nat
```

#### Bridge our VPN connection to the hotspot
installing the bridge service
```
apt-get install bridge-utils -y
```
creating our bridge
```
brctl addbr br0
```
If there's an error, run 'brctl delbr br0' and try again. Then:
```
brctl addif br0 eth0





## Sources
   - https://gist.github.com/superjamie/ac55b6d2c080582a3e64
   - https://github.com/alfredopalhares/openvpn-update-resolv-conf
   - https://forums.openvpn.net/viewtopic.php?t=26388
   - https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point/
   - https://gist.github.com/renaudcerrato/db053d96991aba152cc17d71e7e0f63c
   - https://www.cyberciti.biz/faq/ubuntu-linux-install-pi-hole-with-a-openvpn/
