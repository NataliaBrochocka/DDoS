sudo tshark -i enp0s8 -f "udp port 53" -a duration:5 -qz io,stat,0 > tshark_output.txt

result=$(sudo python3 -c '''
limit = 100
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
    echo "operacje z iptables"
fi
