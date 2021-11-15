# DDoS attack&defense simulation 

### Prerequisites

To launch solutions in project, all listed tools are required:

- Python >= 3.6  
- VirtualBox >= 6.1.18
- Vagrant >= 2.2.18

### Observability Architecture

![private_network_observability_schema](img/private_network_observability_schema.png)

### Set up the environment

1. clone repo & `cd DDoS/`
2. In one terminal run `sudo vagrant up`
3. when command is done run `python3 python_scripts/basic_http_server.py`
4. Done. You should see POST headers coming from Vagrant's VMs.


### Run Syn-Flood attack (WIP)

1. Set up environment
2. While vagrant is up check if every bot(i) VM has "netwox" installed `sudo install netwox`
3. If not wait for it to install, otherwise see pt 4.
4. Run `sudo netwox 76 -i 192.168.27.XX -p Y -s raw`, change XX with last two digits of target ip addr and Y with port number (def. 53)
5. While other VM's are Syn-flooding, on the attacked VM run `sudo tcpdump -i enp0s8 -c 15 tcp` to see how many packets were rejected and/or run `sudo tshark -i enp0s8` to see the live flood
6. Enjoy
