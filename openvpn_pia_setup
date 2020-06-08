# Setting up OpenVPN with PrivateInternetAccess on DietPi
### Description
I spent two days trying to set this up correctly and wanted to share this to TTmaybe save someone else some work.
I used [KiTTY](https://dietpi.com/downloads/binaries/all/Kitty_Portable_DietPi.7z) (logged in as root) to control the Pi's console and [FileZilla Client](https://filezilla-project.org/) (logged in as dietpi, not root) to push/pull files. Also I'm using [RealVNC VNC Viewer](https://www.realvnc.com/de/connect/download/viewer/) (logged in as root) in the end, but any VNC Viewer should work fine. If you're unsure how to use SHH, FTP or VNC look that up first, we will need to access files and enter commands so figure out a way to do that before proceeding.

### Necessary Software
Make sure you have openvpn, resolvconf and dnsmasq installed and running
```
apt-get install openvpn
apt-get install dnsmasq
apt-get install proftpd
apt-get install openresolv
```
If you're asked if you want to uninstall something, answer n 

![Softwareinstall](https://i.imgur.com/s4NZBIw.png)

Also check 'dietpi-services'. You should see 'proftpd', 'dnsmasq', 'openvpn', 'vncserver'.

### Download, edit and push necessary files
#### Download
If you want to get the files freshly from their source to make sure they are up to date and safe, contunue. I also uploaded my files [here](/Files) which you can use as they are not personalized. If you use my files you can skip to [Push](#push)

Download and unpack the [DEFAULT](https://www.privateinternetaccess.com/openvpn/openvpn.zip) or [STRONG](https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip) Configuration Files from PIA. I used PIA's 4096-bit OpenVPN configuration files. If you want to use the default files replace every instance of 4096 in the code with 2048. 

Download 'update-resolv-conf.sh' from [here](https://github.com/alfredopalhares/openvpn-update-resolv-conf).


#### Edit
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
#### Push/edit files to/on the Pi
We need to copy 4 files in total to /etc/openvpn/ on the Pi:
```
ca.rsa.4096.crt
crl.rsa.4096.pem 
US_East.conf
update-resolv-conf.sh
```
Not sure how necessary this is, but I set the permission for this folder to read-write for everyone
```
chmod 777 /etc/openvpn/
```
Now we need to create a file with your login files from PIA for OpenVPN to use.
```
nano /etc/openvpn/login
```
enter your username (p*******) and your password in the line below. Ctrl+X to Exit, confirm with Y and Enter to save. This file should only be readable by root, so set permissions accordingly
```
sudo chmod 600 /etc/openvpn/login
```
The openvpn folder look like this now:
![openvpnfoldercontent](https://i.imgur.com/lr3hK75.png)

Now we need to edit the Client Config files from OpenVPN (this is what ultimately fixed my DNS leaks). The config file is named 'DietPi_OpenVPN_Client.ovpn' and located in two direcories: '/boot/' and '/mnt/dietpi_userdata/'. So pull and edit them; The following to lined need to be deleted:
```
user nobody
group nogroup
```
### First Test (optional)
```
sudo openvpn --config /etc/openvpn/US_East.conf
```
This command tests the VPN. If all is well, you'll see something like:
```
$ sudo openvpn --config /etc/openvpn/Japan.conf 
Sat Oct 24 12:10:54 2015 OpenVPN 2.3.4 arm-unknown-linux-gnueabihf [SSL (OpenSSL)] [LZO] [EPOLL] [PKCS11] [MH] [IPv6] built on Dec  5 2014
Sat Oct 24 12:10:54 2015 library versions: OpenSSL 1.0.1k 8 Jan 2015, LZO 2.08
Sat Oct 24 12:10:54 2015 UDPv4 link local: [undef]
Sat Oct 24 12:10:54 2015 UDPv4 link remote: [AF_INET]123.123.123.123:1194
Sat Oct 24 12:10:54 2015 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
Sat Oct 24 12:10:56 2015 [Private Internet Access] Peer Connection Initiated with [AF_INET]123.123.123.123:1194
Sat Oct 24 12:10:58 2015 TUN/TAP device tun0 opened
Sat Oct 24 12:10:58 2015 do_ifconfig, tt->ipv6=0, tt->did_ifconfig_ipv6_setup=0
Sat Oct 24 12:10:58 2015 /sbin/ip link set dev tun0 up mtu 1500
Sat Oct 24 12:10:58 2015 /sbin/ip addr add dev tun0 local 10.10.10.6 peer 10.10.10.5
Sat Oct 24 12:10:59 2015 Initialization Sequence Completed
```
Exit this with Ctrl+

Enable port forwarding
```
echo -e '\n#Enable IP Routing\nnet.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Finishing up
Enable VPN at boot
```
sudo systemctl enable openvpn@US_East
```
#### Second test (optional)
```
sudo systemctl status openvpn@US_East
sudo journalctl -u openvpn@US_East
```
### Test in browser (optional)
Depending on what your autostart settings are you should install a desktop and set it to autostart. I used LXDE and auto-login as root. These can be done in 'dietpi-software' (installing) and 'dietpi-autostart'. If you've never used vnc on your Pi, you need to set a resolution. For this go to 'dietpi-config' > 'Display Options' > 'Display Resolution' and chose a resolution (I use 720p). Now exit out of the config (3xEsc, then Confirm 'OK')

Reboot with 'reboot' command.

Now we connect to the Pi using our VNC Viewer. Open Firefox and navigate to ipleak.net. If everything worked, this is what you should see:

![Great success!](https://i.imgur.com/F6WtmdD.png)

If you see DNS addresses that are located in your home country you have a DNS leak.





#### Credits
https://gist.github.com/superjamie/ac55b6d2c080582a3e64

https://github.com/alfredopalhares/openvpn-update-resolv-conf

https://forums.openvpn.net/viewtopic.php?t=26388
