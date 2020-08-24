#############################################################
###                   DNS Batch Entry                     ###
###                Patrick Benoit - 3/18/20               ###
###                 pbenoitnv@outlook.com                 ###
###                                                       ###
###  This script will add batch DNS entries into the DNS  ###
###  server.  Reverse lookup zones must be created for    ###
###  new subnets.  After run it will test both forward    ###
###  and reverse lookups with PowerShell's                ###
###  test-connection command, which sends ICMP echo       ###
###  request packets to the computer using WMI.           ###
###  A failure report is then generated if there are any  ###
###  failures.                                            ###
###                                                       ###
###  Requirements - CSV file with Headders,               ###
###                 reverse lookup zone defined as below  ###
###  Headder Name Column 1 - Name (Name of server)        ###
###  Headder Name Column 2 - IP  (IPv4 address of server) ###
###                                                       ###
###  $list - Path to CSV file                             ###
###  $DNSServer - IP address of DNS server                ###
###  $DNSZone - DNS Zone "inegomontoya.com"               ###
###                                                       ###
#############################################################

# Load required assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Import CSV file
$list = Import-Csv -Path "C:\DNS_IP_List.csv"

# Define local DNS servers and DNS zones as strings for easy swapatude
$DNSServer = "Your DNS Server's IP Here"
$DNSZone = "Your DNS Zone Name Here"

# Present a list of items to be added to DNS from the CSV to also add as the start of success and failure tracking
$list | Out-GridView -Title "Verify these new DNS addditions" -PassThru
$continue = [System.Windows.Forms.MessageBox]::Show("Continue with additions?" , "Proceed" , 1)
if ($continue -eq "cancel") {
    exit
    }
write-host "Adding DNS entries"

# Loop to take each line in CSV and add DNS A record along with pointer record
foreach ($item in $list) {
    Add-DnsServerResourceRecord -computername $DNSServer -ZoneName $DNSZone -A -Name $item.Name -IPv4Address $item.IP -CreatePtr
    }

# Flush DNS Cache
Clear-DnsClientCache

# Test each forward lookup entry
Write-host "Testing added DNS forward lookup."
$forwardfail = ""
foreach ($forward in $list) {
    $testforward = Test-Connection $forward.Name -count 1 -Quiet
    write-host $forward.Name
        if ($testforward -like 'False') {
            $forwardfail = $forwardfail + $forward.Name + ","
        }
    }

# Test each reverse lookup entry
Write-host "Testing added DNS reverse lookup."
$reversefail = ""
foreach ($reverse in $list) {
    $testreverse = Test-Connection $reverse.Name -count 1 -Quiet
    write-host $reverse.IP
        if ($testreverse -like 'False') {
            $reversefail = $reversefail + $reverse.IP + ","
        }
    }

# Generate report data
if ($forwardfail -ne "") {
    Write-host "Some forward lookup entries may have failed.  Check report."
    } else {
        write-host "Forward lookups for new DNS entries successful."
        }
if ($reversefail -ne "") {
    Write-host "Some reverse lookup entries may have failed.  Check report."
    } else {
        write-host "Reverse lookups for new DNS entries successful."
        }

# Present report
write-host `n`n" Forward lookup failures:`n"$forwardfail.split(",")`n`n, "Reverse lookup failures:`n"$reversefail.split(",")`n
