#!/bin/bash

INCOMING_DEVICE=tun_kni

LOCAL_MAC_ADDR=fe:65:b7:00:00:01
PEER_MAC_ADDR=aa:bb:cc:dd:ee:ff

LOCAL_IP_ADDR=172.16.241.2
PEER_IP_ADDR=172.16.241.1

start_fun()
{
	# 创建虚拟网卡
	/usr/sbin/ip tuntap add dev ${INCOMING_DEVICE} mode tun one_queue

	# 设置网卡的 MAC
	/usr/sbin/ip link set ${INCOMING_DEVICE} address ${LOCAL_MAC_ADDR}
	# 设置网卡的状态
	/usr/sbin/ip link set ${INCOMING_DEVICE} up
	/usr/sbin/ip addr flush dev ${INCOMING_DEVICE}

	# 设置网卡的 IPv4 地址
	/usr/sbin/ip addr add ${LOCAL_IP_ADDR}/30 dev ${INCOMING_DEVICE}

	# 刷新网卡的 ARP
	# /usr/sbin/ip neigh flush dev ${INCOMING_DEVICE}
	# 将 PEER 的 IP / MAC 加入到本地设备的 ARP 表中
	#/usr/sbin/ip neigh add ${PEER_IP_ADDR} lladdr ${PEER_MAC_ADDR} dev ${INCOMING_DEVICE} nud permanent

	###########################################################################
	# policy route v4
	###########################################################################

	# 流入的流量走 100 号路由表
	/usr/sbin/ip rule add iif ${INCOMING_DEVICE} tab 100
	/usr/sbin/ip route add local default dev lo table 100
	
	# 流出的带 0x65 的流量走 101 号路由表
	/usr/sbin/ip rule add fwmark 0x65 lookup 101
	/usr/sbin/ip route add default dev ${INCOMING_DEVICE} via ${PEER_IP_ADDR} table 101

	###########################################################################
	# policy route v6
	###########################################################################
	
	# 设置网卡的 IPv6 地址
	/usr/sbin/ip addr add fd00::02/64 dev ${INCOMING_DEVICE}

	/usr/sbin/ip -6 route add default via fd00::01

	# 流入的流量走 102 号路由表
	/usr/sbin/ip -6 rule add iif ${INCOMING_DEVICE} tab 102
	/usr/sbin/ip -6 route add local default dev lo table 102

	# 将 PEER 的 IP / MAC 加入到本地设备的 ARP 表中
	#/usr/sbin/ip -6 neigh add fd00::01 lladdr ${PEER_MAC_ADDR} dev ${INCOMING_DEVICE} nud permanent

	###########################################################################
	# iptables netfilter
	###########################################################################
	iptables -A INPUT -i ${INCOMING_DEVICE} -m bpf --bytecode '14,48 0 0 0,84 0 0 240,21 0 10 64,48 0 0 9,21 0 8 6,40 0 0 6,69 6 0 8191,177 0 0 0,80 0 0 20,21 0 3 88,80 0 0 21,21 0 1 4,6 0 0 65535,6 0 0 0' -j NFQUEUE --queue-num 1
}

stop_fun()
{
	iptables -F

	/usr/sbin/ip rule del iif ${INCOMING_DEVICE} tab 100
	/usr/sbin/ip route del local default dev lo table 100

	/usr/sbin/ip rule del fwmark 0x65 lookup 101
	/usr/sbin/ip route del default dev ${INCOMING_DEVICE} via ${PEER_IP_ADDR} table 101

	/usr/sbin/ip -6 rule del iif ${INCOMING_DEVICE} tab 102
	/usr/sbin/ip -6 route del default via fd00::01
	/usr/sbin/ip -6 route del local default dev lo table 102

	/usr/sbin/ip addr del fd00::02/64 dev ${INCOMING_DEVICE}

	/usr/sbin/ip link set ${INCOMING_DEVICE} down
	
	# 删除虚拟网卡
	/usr/sbin/ip tuntap del dev ${INCOMING_DEVICE} mode tap
}

status_fun()
{
	iptables -L
}

case "$1" in
	start)
		start_fun
		;;
	stop)
		stop_fun
		;;
	restart)
		stop_fun
		start_fun
		;;
	status)
		status_fun
		;;
	*)
	echo "Usage: $0 {start|stop|status|restart}"
esac
exit 0
