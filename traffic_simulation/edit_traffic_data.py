import pandas as pd
from scapy.layers.dns import DNS
from scapy.layers.inet import IP
from scapy.packet import Raw
from scapy.plist import PacketList
from scapy.utils import rdpcap, wrpcap

input_filepath = 'bigFlows.pcap'
number_of_hosts = 15

data = rdpcap(input_filepath)

# 0 - ip
# 1 - icmp
# 6 - tcp
# 17 - udp
allowed_protocols = [0, 1, 6, 17]
dns_ips = ("8.8.8.8", "8.8.4.4")

df = pd.DataFrame(columns=["src", "dst"])

for pkt in data:
    layer = pkt.getlayer(1)
    if (layer.haslayer(Raw) and layer.haslayer(IP)) or layer.haslayer(DNS):
        df = df.append({'src': layer.src,
                        'dst': layer.dst},
                       ignore_index=True)

src_ips = df["src"].value_counts(sort=True)
ips = src_ips[:number_of_hosts].index.tolist()

address_mapping = {}

i = 0
for addr in ips:
    if addr not in dns_ips:
        address_mapping[addr] = f"192.168.27.{10 + i}"
        i = i + 1

packets_to_save = PacketList()
for pkt in data:
    layer = pkt.getlayer(1)
    if layer.haslayer(Raw) and layer.haslayer(IP):
        if layer.proto in allowed_protocols:
            if layer.src in ips and layer.dst in ips:
                layer.src = address_mapping[layer.src]
                layer.dst = address_mapping[layer.dst]
                packets_to_save += PacketList([pkt])
    elif layer.haslayer(DNS):
        if layer.src in dns_ips:
            layer.src = "192.168.27.9"
            layer.dst = "192.168.27.10"
            packets_to_save += PacketList([pkt])
        elif layer.dst in dns_ips:
            layer.dst = "192.168.27.9"
            layer.src = "192.168.27.10"
            packets_to_save += PacketList([pkt])

wrpcap('traffic_data.pcap', packets_to_save, append=False)
