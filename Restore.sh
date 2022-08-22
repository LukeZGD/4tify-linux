#!/bin/bash
set -e
IP=$1
cd support_restore/

echo "* Make sure OpenSSH is installed on the device and running!"

echo "Enter the root password of your iOS device when prompted, the default one is \"alpine\""

scp kloader pwnediBSS mobile@${IP}:/var/mobile


ssh root@$IP "/var/mobile/kloader /var/mobile/pwnediBSS" & sleep 5

echo "Entering kDFU Mode... press the Home or Power Button once the screen goes black to proceed" & sleep 3
while !(lsusb 2> /dev/null | grep "Apple, Inc. Mobile Device" 2> /dev/null); do
    sleep 1
done
killall ssh

echo "Done!"

echo "The Custom IPSW will now be restored" & sleep 3
set +e
./idevicerestore -e -y custom.ipsw
echo "Done, if you receive an error about the device not disconnecting, quicly unplug and replug the device after Sending iBSS gets to 100%"