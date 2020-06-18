#!/bin/bash

cat << EOF > /etc/sysctl.conf
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.seg6_enabled = 1
net.ipv6.conf.default.seg6_enabled = 1
net.ipv6.conf.eth1.seg6_enabled = 1
net.ipv6.conf.eth2.seg6_enabled = 1
EOF
sysctl -p

cat << EOF > /etc/quagga/zebra.conf
hostname `uname -n`
password zebra
ip forwarding
EOF

cat << EOF > /etc/quagga/ospf6d.conf
hostname `uname -n`
password zebra
interface eth1
 ipv6 ospf6 instance-id 0
interface eth2
 ipv6 ospf6 instance-id 0
router ospf6
 router-id 1.1.1.1
 area 0.0.0.0 range 2001:db1::/64
 area 0.0.0.0 range 2001:db2::/64
 area 0.0.0.0 range 2001:db3::/64
 interface eth1 area 0.0.0.0
 interface eth2 area 0.0.0.0
EOF

systemctl restart zebra
systemctl status zebra

# Encap(srv6-1)
# ip -6 route add 2001:db3::/64 encap seg6 mode encap segs 2001:db2::2 dev eth2
# ip -6 route add 2001:db2::1/128 encap seg6local action End.DX6 nh6 2001:db1::1 dev eth1

# Endpoint(srv6-2)
# ip -6 route add 2001:db1::/64 encap seg6 mode encap segs 2001:db2::1 dev eth1
# ip -6 route add 2001:db2::2/128 encap seg6local action End.DX6 nh6 2001:db3::2 dev eth2
