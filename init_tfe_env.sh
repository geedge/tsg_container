#!/bin/bash

NIC=tap0
PEER_IP=172.16.2.1
LOCAL_IP=172.16.2.2
LOCAL_MAC=fe:65:b7:00:00:01
container=tfe-container-v4.4

exposedockernetns ()
{
	pid=`docker inspect -f '{{.State.Pid}}' $1`
	ln -s /proc/$pid/ns/net /var/run/netns/$1
	echo "netns of ${1} exposed as /var/run/netns/${1}"
}

dockerrmf ()
{
	docker kill `docker ps --no-trunc -aq`
	docker rm `docker ps --no-trunc -aq`
}

cp tfe_sysctl.conf /etc/sysctl.d/
sysctl -p /etc/sysctl.d/tfe_sysctl.conf

#dockerrmf
#ip tuntap del dev ${NIC} mode tap
#ip tuntap add dev ${NIC} mode tap one_queue
ip netns list

###############################################################################
# 注意：需要停止 tfe-env 脚本
# cd /home/lwp/tsg_container
# docker-compose up tfe
###############################################################################

rm -Rf /var/run/netns/*
mkdir -p /var/run/netns
exposedockernetns ${container}
ip link set ${NIC} netns ${container}

ip netns exec ${container} ip link set ${NIC} address ${LOCAL_MAC}
ip netns exec ${container} ip link set ${NIC} up

# IPv4 策略路由
ip netns exec ${container} ip addr add ${LOCAL_IP}/24 dev ${NIC}

ip netns exec ${container} ip rule add iif ${NIC} tab 100
ip netns exec ${container} ip route add local default dev lo table 100

ip netns exec ${container} ip rule add fwmark 0x65 lookup 101
ip netns exec ${container} ip route add default dev ${NIC} via ${PEER_IP} table 101

# IPv6 策略路由
ip netns exec ${container} ip addr add fd00::02/64 dev ${NIC}

ip netns exec ${container} ip -6 route add default via fd00::01

ip netns exec ${container} ip -6 rule add iif ${NIC} tab 102
ip netns exec ${container} ip -6 route add local default dev lo table 102

# iptables
ip netns exec ${container} iptables -A INPUT -i ${NIC} -m bpf \
	--bytecode '14,48 0 0 0,84 0 0 240,21 0 10 64,48 0 0 9,21 0 8 6,40 0 0 6,69 6 0 8191,177 0 0 0,80 0 0 20,21 0 3 88,80 0 0 21,21 0 1 4,6 0 0 65535,6 0 0 0' \
	-j NFQUEUE --queue-num 1

echo "================ run 'ip addr list'  in container ================"
ip netns exec ${container} ip addr list

echo "================ run 'ip rule list'  in container ================"
ip netns exec ${container} ip rule list

echo "================ run 'ip route list' in container ================"
ip netns exec ${container} ip route list

echo "================ run 'iptables'      in container ================"
ip netns exec ${container} iptables -L

echo "================ run 'ping'          in container ================"
ip netns exec ${container} ping -c10 ${PEER_IP}
