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

echo "Architecture: "
echo "CPU physical: $n_cpu"
echo "vCPU: $n_vcpu"
echo "Memory Usage: "
echo "CPU boot: "
echo "Last boot: "
echo "LVM use: "
echo "Connections TCP: "
echo "User log: "
echo "Network: "
echo "Sudo: "










