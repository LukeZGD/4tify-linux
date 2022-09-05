#!/bin/bash
set -e
IP=$1
cd support_files/4.3/File_System
if [[ ! -e iPhone3,1_4.3_8F190_Restore.ipsw ]]; then
    curl -O https://secure-appldnld.apple.com/iPhone4/041-0330.20110311.Cswe3/iPhone3,1_4.3_8F190_Restore.ipsw --progress-bar
fi
unzip -j iPhone3,1_4.3_8F190_Restore.ipsw 038-0688-006.dmg
./dmg extract 038-0688-006.dmg decrypted.dmg -k 34904e749a8c5cfabecc6c3340816d85e7fc4de61c968ca93be621a9b9520d6466a1456a
./dmg build decrypted.dmg UDZO.dmg

echo "Preparing Filesystems..."

iproxy 2222 22 & /usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "mkdir /mnt1\r"
    expect "#"
    send "mkdir /mnt2\r"
    expect "#"
    send "/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3\r"
    expect "#"
    send "/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4\r"
    expect "#"
    send "mount_hfs /dev/disk0s4 /mnt2\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)

echo "Sending Filesystem, This Will Take Long Time..."

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no UDZO.dmg root@localhost:/mnt2
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Restoring Filesystem, This Will Take A Long Time..."

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "asr restore --source /mnt2/UDZO.dmg --target /dev/disk0s3 --erase\r"
    expect ":"
    send "y\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)

echo "Patching Filesystem..."

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "fsck_hfs -f /dev/disk0s3\r"
    expect "#"
    send "umount /mnt1\r"
    expect "#"
    send "umount /mnt2\r"
    expect "#"
    send "mount_hfs /dev/disk0s4 /mnt2\r"
    expect "#"
    send "mount_hfs /dev/disk0s3 /mnt1\r"
    expect "#"
    send "mv -v /mnt1/private/var/* /mnt2\r"
    expect "#"
    send "mkdir /mnt2/keybags\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)
cd ../Patches

echo "Patching Fstab..."

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no fstab root@localhost:/mnt1/etc
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Keybag"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "ttbthingy\r"
    expect "#"
    send "fixkeybag -v2\r"
    expect "#"
    send "cp -a /tmp/systembag.kb /mnt2/keybags\r"
    expect "#"
    send "umount /mnt1\r"
    expect "#"
    send "umount /mnt2\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)

echo "Patching Boot Files (1/6)"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no applelogo root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Boot Files (2/6)"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no devicetree root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Boot Files (3/6)"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no kernelcache root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Boot Files (4/6)"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no ramdisk root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Boot Files (5/6)"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no iBEC.img3 root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Boot Files (6/6)"

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no iBSS.patched root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Sending runasroot "

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no runasroot root@localhost:/usr/bin
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Sending Boot..."

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no boot.sh root@localhost:/
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
cd ../App

echo "Sending App..."

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn scp -P 2222 -o StrictHostKeyChecking=no -r 4tify.app root@localhost:/Applications
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Moving Everything Into Place..."

sleep 2

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "chmod 6755 /Applications/4tify.app/4tify\r"
    expect "#"
    send "chmod 4755 /usr/bin/runasroot\r"
    expect "#"
    send "chown root:wheel /usr/bin/runasroot\r"
    expect "#"
    send "chmod 6755 /usr/bin/runasroot\r"
    expect "#"
    send "chmod 6755  /boot.sh\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)

sleep 2

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 mobile@localhost
    expect "mobile@localhost's password:"
    send "alpine\r"
    expect "mobile"
    send "uicache\r"
    expect "mobile"
    send "exit\r"
    expect eof
EOD
)

sleep 2

/usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "killall -9 SpringBoard\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)
echo "Done!"
