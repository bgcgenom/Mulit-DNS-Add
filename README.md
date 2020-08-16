# Mulit-DNS-Add
This script will add batch DNS entries into the DNS server.  Reverse lookup zones must be created for new subnets.  After run it will test both forward and reverse lookups with PowerShell's test-connection command, which sends ICMP echo request packets to the computer using WMI.  A failure report is then generated if there are any failures.

## Requirements - CSV file with Headders, reverse lookup zone defined as below
*Headder Name Column 1 - Name (Name of server)

*Headder Name Column 2 - IP  (IPv4 address of server)

$list - Path to CSV file

$DNSServer - IP address of DNS server

$DNSZone - DNS Zone "inegomontoya.com"  
