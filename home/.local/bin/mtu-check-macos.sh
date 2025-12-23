#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

pingtarget="8.8.4.4"
currentMtu=$(networksetup -getMTU en0 |sed 's/.*Current Setting: \([0-9]*\).*/\1/')

for ((mtu=1500; $mtu>=1200; mtu--)); do
  if ping -o -D -c 2 -W 2 -s $((mtu - 28)) $pingtarget > /dev/null 2> /dev/null ; then
    echo "A MTU of $mtu is OK."
    echo
    echo "Current MTU is $currentMtu optimal MTU for current network is $mtu"
    exit 0
  else
    defaultInterface=$(route -n get default | grep interface | cut -d: -f 2)
    echo "A MTU of $mtu is to big"
    echo "To update the MTU run the following command:"
    echo "networksetup -setMTU $defaultInterface $mtu"
  fi
done

echo "Failed to find working MTU. Can you ping $pingtarget ?"
exit 1
