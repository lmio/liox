#!/usr/bin/env python
# -*- coding: utf-8 -*-

ifaces_dhcp = '''
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp
'''

ifaces_static = '''
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet static
    address {{ipaddr}}
    netmask 255.255.255.0
    gateway 192.168.1.1
'''

addrlist = {
    'd0:50:99:40:90:cd': '192.168.1.140',
    'd0:50:99:40:8f:22': '192.168.1.141',
    'd0:50:99:40:8f:1a': '192.168.1.142',
    'd0:50:99:40:8f:38': '192.168.1.143',
    'd0:50:99:40:8f:32': '192.168.1.144',
    'd0:50:99:40:8f:3c': '192.168.1.145',
    'd0:50:99:40:91:c3': '192.168.1.146',
    'd0:50:99:40:8f:30': '192.168.1.147',
    'd0:50:99:39:aa:5e': '192.168.1.148',
    'd0:50:99:40:8f:2c': '192.168.1.149',
    '78:24:af:3b:71:10': '192.168.1.160',
    'e0:3f:49:b5:2b:b7': '192.168.1.161',
    'e0:3f:49:b5:2b:a4': '192.168.1.162',
    'e0:3f:49:b5:2a:ab': '192.168.1.163',
    'e0:3f:49:b5:2b:b5': '192.168.1.164',
    'e0:3f:49:b5:2b:b3': '192.168.1.165',
    'e0:3f:49:b5:2b:ad': '192.168.1.166',
    'e0:3f:49:b5:1e:9e': '192.168.1.167',
    '78:24:af:3b:70:d0': '192.168.1.168',
    'e0:3f:49:b5:2b:ae': '192.168.1.169',
}


def main():
    with open('/sys/class/net/eth0/address', 'r') as f:
        mac = f.readline()[:-1].lower()
    print("My MAC is", mac)
    if mac in addrlist:
        ifaces = ifaces_static[1:].replace('{{ipaddr}}', addrlist[mac])
    else:
        ifaces = ifaces_dhcp[1:]
    f = open('/etc/network/interfaces', 'w')
    f.write(ifaces)
    f.close()


if __name__ == '__main__':
    main()
