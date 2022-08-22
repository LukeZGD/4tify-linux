#!/bin/bash
set -e
ps -fA | grep 2022 | grep -v grep | awk '{print $2}' | xargs kill
cd support_files/4.3/File_System
srcdirs=$(find . -name '*TwistedMind2-*')
cd ../../7.1.2/Ramdisk
echo "Please Put Your Device Into DFU Mode"
while !(lsusb 2> /dev/null | grep "Apple, Inc. Mobile Device" 2> /dev/null); do
    sleep 1
done
./pwnedDFU_linux -p
echo "Sending iBSS and iBEC"
./irecovery -f iBSS.n90ap.RELEASE.dfu
./irecovery -f iBEC.n90ap.RELEASE.dfu
echo "Waiting for Connection, This Might Take Some Time..."
while !(lsusb 2> /dev/null | grep "Apple, Inc. Apple Mobile Device" 2> /dev/null); do
    sleep 1
done
n=0
until [ $n -ge 5 ]
do
    /usr/bin/expect <(cat << 'EOD'
    set timeout -1
    log_user 0
    spawn -noecho ./irecovery2 -s
    expect "iRecovery>"
    send "/send devicetree\r"
    expect "iRecovery>"
    send "DeviceTree.n90ap.img3\r"
    expect "iRecovery>"
    send "/send 058-1056-002.dmg\r"
    expect "iRecovery>"
    send "ramdisk\r"
    expect "iRecovery>"
    send "/send kernelcache.release.n90\r"
    expect "iRecovery>"
    send "bootx\r"
    expect "iRecovery>"
    send "/exit\r"
    expect eof
EOD
)&& break
    n=$[$n+1]
    echo "Retrying iRecovery (This Might Take A Few Tries)"
    sleep 3
done
echo "Booting..."
sleep 2
while !(lsusb 2> /dev/null | grep "iPhone" 2> /dev/null); do
    sleep 1
done
echo "Establishing Connection (5s)..."
sleep 5
python2 ./tcprelay.py > /dev/null 2>&1 -t 22:2022 &
cd ../../4.3/File_System
echo "Establishing Patching Environment (8s)..."
sleep 8
echo "Sending Patch..."
sleep 2

scp -P 2022 -o StrictHostKeyChecking=no ${srcdirs:2} root@localhost:/;

echo "Sending dd..."
sleep 2

scp -P 2022 -o StrictHostKeyChecking=no dd root@localhost:/bin;

echo "Patching..."
sleep 2

ssh root@localhost -p 2022 dd if=${srcdirs:1} of=/dev/rdisk0 bs=8192;

 /usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "ls -la /dev/disk* \r"
    expect "sh-4.0#"
    send "reboot_bak\r"
    expect eof
EOD
)
    
echo "Done!"
