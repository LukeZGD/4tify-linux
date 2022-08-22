#!/bin/bash
set -e
ps -fA | grep 2022 | grep -v grep | awk '{print $2}' | xargs kill
cd support_files/7.1.2/Ramdisk
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
    log_user 0
    set timeout -1
    spawn -noecho ./irecovery2 -s
    expect "iRecovery>"
    send "/send DeviceTree.n90ap.img3\r"
    expect "iRecovery>"
    send "devicetree\r"
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
) && break

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
cd ../Jailbreak
echo "Establishing Jailbreak Environment (8s)..."
sleep 8

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "mount_hfs /dev/disk0s1 /mnt1 \r"
    expect "sh-4.0#"
    send "mount_hfs /dev/disk0s2s1 /mnt1/private/var \r"
    expect "sh-4.0#"
    send "exit \r"
    expect eof
EOD
)
echo "Waiting For Filesystem (5s)..."
sleep 5
echo "Sending Tar and DD..."
sleep 2

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 tar dd root@localhost:/bin
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Waiting For Filesystem (5s)..."
sleep 5
echo "Sending Jailbreak Files 1/5..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 panguaxe.tar root@localhost:/mnt1/private/var
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Sending Jailbreak Files 2/5..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 Cydia.tar root@localhost:/mnt1/private/var
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Sending Jailbreak Files 3/5..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 APT.tar root@localhost:/mnt1/private/var
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Sending Jailbreak Files 4/5..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 panguaxe-APT.tar root@localhost:/mnt1/private/var
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Sending Jailbreak Files 5/5..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 panguaxe root@localhost:/mnt1/private/var
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Sending Tar and DD..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 tar dd root@localhost:/bin
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
echo "Jailbreaking..."
sleep 2

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "tar -x --no-overwrite-dir -f /mnt1/private/var/panguaxe.tar -C /mnt1 \r"
    expect "sh-4.0#"
    send "tar -x --no-overwrite-dir -f /mnt1/private/var/Cydia.tar -C /mnt1 \r"
    expect "sh-4.0#"
    send "tar -x --no-overwrite-dir -f /mnt1/private/var/APT.tar -C /mnt1 \r"
    expect "sh-4.0#"
    send "tar -x --no-overwrite-dir -f /mnt1/private/var/panguaxe-APT.tar -C /mnt1 \r"
    expect "sh-4.0#"
    send "rm -rf /mnt1/panguaxe \r"
    expect "sh-4.0#"
    send "cp -a /mnt1/private/var/panguaxe /mnt1 \r"
    expect "sh-4.0#"
    send "touch /mnt1/panguaxe.installed \r"
    expect "sh-4.0#"
    send "touch /mnt1/private/var/mobile/Media/panguaxe.installed \r"
    expect "sh-4.0#"
    send "mkdir -p /mnt1/private/var/root/Media/Cydia/AutoInstall \r"
    expect "sh-4.0#"
    send "exit \r"
    expect eof
EOD
)
echo "Sending Debs..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 org.thebigboss.repo.icons_1.0.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 com.nyansatan.dualbootstuff_1.0.7a.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    spawn scp -P 2022 cydia_1.1.9_iphoneos-arm.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)
/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 cydia-lproj_1.1.12_iphoneos-arm.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 openssl_0.9.8zg-13_iphoneos-arm.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 openssh_6.7p1-13_iphoneos-arm.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 coreutils_8.12-13_iphoneos-arm.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 bigbosshackertools_1.3.2-2.deb root@localhost:/mnt1/private/var/root/Media/Cydia/AutoInstall
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Sending patched Springboard"

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 com.apple.springboard.plist root@localhost:/mnt1/var/mobile/Library/Preferences
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD
)

echo "Patching Fstab..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn scp -P 2022 fstab root@localhost:/mnt1/etc
    expect "root@localhost's password:"
    send "alpine\r"
    expect eof
EOD    
)
echo ""

echo "Rebooting..."

/usr/bin/expect <(cat << 'EOD'
    log_user 0
    set timeout -1
    spawn ssh -p 2022 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "sh-4.0#"
    send "reboot_bak\r"
    expect eof
EOD
)
echo "Done!"
