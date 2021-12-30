#!/usr/bin/python3
 
import sys
import socket
import pyshark
import argparse
import concurrent.futures
import subprocess
import re
from datetime import datetime


INTERFACE = 'enp0s8'
INTERVAL = 30
PORT_RANGE = 65535
TARGET = socket.gethostbyname("localhost")

def port_scanner() -> list:
    port_list = []
    try:
        for port in range(1,PORT_RANGE):
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            socket.setdefaulttimeout(1)
            result = s.connect_ex((TARGET,port))
            if result == 0:
                port_list.append(port)
                print(f"Port {port} is open")
            s.close()

    except KeyboardInterrupt:
        print("[ERROR] Keyboard Interrupt")
        sys.exit()
    except socket.gaierror:
        print("[ERROR] Invalid hostname")
        sys.exit()
    except socket.error:
        print("[ERROR] Cannot create socket")
        sys.exit()
    print("[INFO] Port scanning finished")

    return port_list

def get_syn_limit() -> int:
    output = subprocess.Popen(['sysctl', '-q', 'net.ipv4.tcp_max_syn_backlog'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    stdout,stderr = output.communicate()
    if (stderr):
        print("Cannot read max syn backlog value,{stderr}")
        raise ValueError
    syn_limit = re.search(r' \d+', str(stdout))[0]
    print(f"Max syn backlog:{syn_limit}")
    return int(syn_limit)

def capture_syn(port) -> int:
    capture = pyshark.LiveCapture(interface=INTERFACE,\
            bpf_filter=f'tcp dst port {port} and tcp[tcpflags] & (tcp-syn|tcp-ack)!= 0')
    capture.sniff(timeout=INTERVAL)
    syn_numb = len(capture)
    return syn_numb, port


def syn_prevent(port_list):
    syncookies_cmd="echo 'net.ipv4.tcp_syncookies = 1' > /etc/syncookies.conf; sysctl -p /etc/syncookies.conf"
    output_syncookies = subprocess.call(syncookies_cmd, shell=True)
    if(output_syncookies != 0):
        print(f"Enabling syncookies failed with exit code: {output_syncookies}")

    port_chain=','.join(str(x) for x in port_list)
    iptables_cmd = f'''
    iptables -N syn_flood
    iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
    iptables -A INPUT -p tcp --match multiport --dport {port_chain} --syn -j syn_flood
    '''
    iptables_exit_code = subprocess.call(iptables_cmd, shell=True)
    if (iptables_exit_code != 0):
        print(f'iptables failed wit exit code:{iptables_exit_code}')
        sys.exit()

def port_monitor():
    syn_limit = get_syn_limit()
    port_list = port_scanner()
    attacked_port_list = []
    with concurrent.futures.ProcessPoolExecutor() as executor:
        syn_numb = [executor.submit(capture_syn, port) for port in port_list]

        for f in concurrent.futures.as_completed(syn_numb):
            print(f'Number of SYN connections: {f.result()[0]}')
            if (f.result()[0] >= syn_limit):
                attacked_port_list.append(f.result()[1])

    if(attacked_port_list):
        syn_prevent(attacked_port_list)

def main():
    parser = argparse.ArgumentParser(description='Parse arguments for SYN Flood detection & prevention script.')
    parser.add_argument('-i', '--interface', type=str, default="enp0s8", help='Select interface to monitor')
    parser.add_argument('-t', '--interval', type=int, default=30, help='Specify interval time to monitor traffic on each port')
    parser.add_argument('-r', '--port-range', type=int, default=65535, help='Specify port range')

    args = parser.parse_args()

    global INTERFACE
    global INTERVAL
    global PORT_RANGE
    INTERFACE = args.interface
    INTERVAL = args.interval
    PORT_RANGE = args.port_range

    port_monitor()

if __name__ == '__main__':
    main()