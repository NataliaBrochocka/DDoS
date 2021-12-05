import pandas as pd
from scapy.layers.inet import IP
from scapy.packet import Raw
from scapy.plist import PacketList
from scapy.utils import rdpcap, wrpcap

input_filepath = 'bigFlows.pcap'
number_of_hosts = 20

data = rdpcap(input_filepath)

# 0 - ip
# 1 - icmp
# 6 - tcp
# 17 - udp
allowed_protocols = [0, 1, 6, 17]

df = pd.DataFrame(columns=["src", "dst"])

for pkt in data:
    layer = pkt.getlayer(1)
    if layer.haslayer(Raw) and layer.haslayer(IP):
        df = df.append({'src': layer.src,
                        'dst': layer.dst},
                       ignore_index=True)

src_ips = df["src"].value_counts(sort=True)
first_src = src_ips[:number_of_hosts].index.tolist()

address_mapping = {}

i = 0
for addr in first_src:
    address_mapping[addr] = f"192.168.27.{10 + i}"
    i = i + 1

packets_to_save = PacketList()
for pkt in data:
    layer = pkt.getlayer(1)
    if layer.haslayer(Raw) and layer.haslayer(IP):
        if layer.src in first_src and layer.dst in first_src and layer.proto in allowed_protocols:
            layer.src = address_mapping[layer.src]
            layer.dst = address_mapping[layer.dst]
            packets_to_save += PacketList([pkt])

wrpcap('traffic_data.pcap', packets_to_save, append=True)
