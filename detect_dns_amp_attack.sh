while true
do
    sudo tshark -i enp0s8 -f "udp port 53" -a duration:5 -qz io,stat,0 > tshark_output.txt

    result=$(sudo python3 -c '''
limit = 300
is_attacked = False
f = open("tshark_output.txt", "r")
lines = f.readlines()
try:
    number_of_packets = int(lines[-2].split("|")[-3])
    if number_of_packets >= limit:
        is_attacked = True
except ValueError:
    pass
print(is_attacked)	
''')
# echo "result: $result"

    if [ "$result" = "True" ]; then
        echo "Attack - modify iptables"
        sudo iptables -N LOGGING
        sudo iptables -A INPUT -p udp --dport 53 -j LOGGING
        sudo iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
        sudo iptables -A LOGGING -j DROP
        sleep 2m
        echo "Restore iptables"
        sudo iptables -D LOGGING -j DROP
        sudo iptables -D LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
        sudo iptables -D INPUT -p udp --dport 53 -j LOGGING
        sudo iptables -X LOGGING
    fi
done
