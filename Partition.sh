#!/bin/bash
set -e
IP=$1
cd support_files/4.3/File_System

./iproxy 2222 22 & /usr/bin/expect <(cat << 'EOD'
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 2222 root@localhost
    expect "root@localhost's password:"
    send "alpine\r"
    expect "#"
    send "TwistedMind2 -d1 3221225472 -s2 879124480 -d2 max\r"
    expect "#"
    send "exit\r"
    expect eof
EOD
)
sleep 2
echo "Fetching Patch File"

srcdirs=$(ssh -n -p 2222 root@localhost "find / -name '*TwistedMind2-*'")
echo "$srcdirs"

scp -P 2222 -o StrictHostKeyChecking=no root@localhost:$srcdirs $(pwd)
    
echo "Done!"
