# 4tify - v0.1_beta
iOS 4 Dualbooting Made Simple By [zzanehip](https://github.com/zzanehip) and ported to linux by [alesx2io](https://github.com/alesx2io)


## Important Note 
* This is still very much an early phase project, use it at *your own risk.* If you have any issues, or find any bugs please report them.

## What's Supported
* iPhone 4 (3,1)
	* iOS 4.3
* Tested on x86_64 Ubuntu 22.04 

## Soon to Come 
* Nothing at the moment

#  Instructions:

- Before starting, ensure your phone is Jailbroken with a tfp0 exploit, and OpenSSH + Core Utilities + Core Utilities (/bin) Installed, if it's not you can follow the Restore and Jailbreak section.
- While conducting the process, keep your phone plugged into your computer (obviously).
- Keep your root password as alpine throughout the process. 
- Lastly, don't be dismayed if you see errors with pwnedDFU_linux when loading into Ramdisk.
- If one of the scripts refuses to run (permission denied) just run chmod +x on it.

## Restore and Jailbreak:
We need to get our device onto a modified version of iOS 7.1.2 with lwvm patched out and replaced with GPT. Afterwards, we need to jailbreak it. Before you start, make sure you are jailbroken, have Core Utilities and OpenSSH installed.

1. First, build a patched IPSW and grab blobs (omit < > when entering):

`./Create-Restore.sh <Decimal-ECID> 

2. Restore the Custom IPSW (Enter the root password, when asked, the default one is alpine. If the restore process doesn't start after e.g. fish: storing file 65536 (65536) just click your home button or power button, or even unplug and replug the device):		

`./Restore.sh <ip-address>`

3. Set up your device.

4. We need to use an SSH Ramdisk to Jailbreak, before starting make sure your device is in DFU, if the script fails just try again.

`./Jailbreak.sh`	

5. Done, you should see Cydia on your Springboard, open it, and let it do its thing. Reopen it, click upgrade essential (you might have to open and close it a few times)

##  2. iOS 4 and the Second Partition:
Now, we'll partition our device, install iOS 4, and patch it. Once this is done, you'll be good to go!

1. Fix Known_Host issues by running:

`sudo rm ~/.ssh/known_hosts`

2. First, we'll partition the device (It will ask for your root password to confirm, as always, enter alpine):

`./Partition.sh localhost`

3. Next, we'll boot into SSH Ramdisk and patch our new partition. (It might take a few tries to get this going):

`./Patch-Partition.sh`

4. Lastly, we'll initalize our partition, build our filesystem, restore it, and patch it. This step generally takes about an hour, so just be patient:

`./ios4.sh <ip-address>`

5. That's it, your done, and your device will respring. To boot into iOS 4, lauch the 4tify app. Once your screen goes black wait a sec, then tap your homebutton, and should see your device start to verbose boot within 10-15 seconds.

6. If you delete the 4tify app, or it doesn't seem to be working, you can always run:

`./Reinstall-App.sh <ip-address>`

## Thanks to:
* [verygenericname](https://github.com/verygenericname) for helping me with some scripting
* [zzanehip](https://github.com/zzanehip) for the original project
* [winocm](https://github.com/winocm) and [xerub](https://github.com/xerub) for kloader and the modified version of iRecovery.
* [msft_guy](https://github.com/msftguy) for ssh ramdisk.
* [axi0mx](https://github.com/axi0mX) for ipwndfu tools such as tcp_relay.py.
* [Billy-Ellis](https://github.com/Billy-Ellis) for runasroot.
* [LukeZGD](https://github.com/LukeZGD) for pre-compiled Binaries. (xpwntool_linux, ipsw_linux)
