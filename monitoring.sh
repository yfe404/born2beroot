#Architecture: Linux wil 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64 GNU/Linux
#CPU physical : 1
#vCPU : 1
#Memory Usage: 74/987MB (7.50%)
#Disk Usage: 1009/2Gb (49%)
#CPU load: 6.7%
#Last boot: 2021-04-25 14:45
#LVM use: yes
#Connections TCP : 1 ESTABLISHED
#User log: 1
#Network: IP 10.0.2.15 (08:00:27:51:9b:a5)
#Sudo : 42 cmd

n_cpu=$(grep 'physical id' /proc/cpuinfo | sort -u | wc -l)
n_vcpu=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
ip4=$(ip -4 a show enp0s3 | grep inet | tr -s ' ' | cut -d' ' -f 3 | cut -d '/' -f 1)
mac=$(ip a show enp0s3 | grep ether | tr -s ' ' | cut -d' ' -f 3 | cut -d '/' -f 1)
mem_use=$(free -m  | tr -s ' ' | head -n 2 | tail -n 1 | cut -d" " -f 3)
mem_avai=$(free -m  | tr -s ' ' | head -n 2 | tail -n 1 | cut -d" " -f 2)
mem_perc=$(echo "scale=2; 100*$mem_use / $mem_avai" | bc)
cpu_usage=$(top -bn 2 -d 0.1 | grep '^%Cpu' | tail -n 1 | awk '{print $2+$4+$6}')
disk_usage=$(df -h --total | grep mapper | awk '{printf "\t-%s: Available: %s Usage: %s\n", $1, $4, $5}')
lvm_in_use="no"
if /usr/sbin/pvdisplay 2>/dev/null | grep -q UUID; then
    lvm_in_use="yes"
fi
num_tcp_conn=$(ss -tn state established | tail -n +2 | wc -l)
user_log=$(who | cut -d" " -f1 | sort -u | wc -l)
nb_sudo=$(echo "ibase=36; $(cat /var/log/sudo/seq)" | bc)

echo "Architecture: $(uname -a)"
echo "CPU physical: $n_cpu"
echo "vCPU: $n_vcpu"
echo "Memory Usage: ${mem_use}/${mem_avai}MB (${mem_perc}%)"
echo "Disk Usage: "
echo "${disk_usage}"
echo "CPU load: ${cpu_usage}"
echo "Last boot: $(who -b | tr -s ' ' | cut -d' ' -f4-5)"
echo "LVM use: ${lvm_in_use}"
echo "Connections TCP: ${num_tcp_conn} ESTABLISHED"
echo "User log: ${user_log}"
echo "Network: IP $ip4 ($mac)"
echo "Sudo: ${nb_sudo} cmd"










