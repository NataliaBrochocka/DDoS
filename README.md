# DDoS attack&defense simulation 

### Prerequisites

To launch solutions in project, all listed tools are required:

- Python >= 3.6  
- VirtualBox >= 6.1.18
- Vagrant >= 2.2.18

#### Additional Prerequisites for developers 

- QtDesigner

### Observability Architecture

![private_network_observability_schema](img/private_network_observability_schema.png)

### Set up the environment

1. clone repo & `cd DDoS/`
2. In one terminal run `sudo vagrant up`
3. when command is done run `python3 python_scripts/basic_http_server.py`
4. Done. You should see POST headers coming from Vagrant's VMs.