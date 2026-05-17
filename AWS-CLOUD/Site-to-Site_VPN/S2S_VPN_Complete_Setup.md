````md id="awsvpn001"
# AWS Site-to-Site VPN using pfSense and VMware
# Complete Hybrid Cloud Networking Lab Guide

Author: Vinay Kumar  
Environment:
- VMware Workstation
- pfSense Firewall
- Ubuntu Server
- AWS VPC
- AWS Site-to-Site VPN

---

# OBJECTIVE

Build a real enterprise-style hybrid cloud architecture where:

ON-PREM NETWORK (VMware Lab)
        ↓
pfSense Firewall
        ↓
Encrypted IPSec VPN Tunnel
================ INTERNET ================
        ↓
AWS Virtual Private Gateway
        ↓
AWS VPC
        ↓
Private EC2 Instance

This lab demonstrates:
- Hybrid Cloud Networking
- AWS Site-to-Site VPN
- IPSec Tunnels
- Enterprise Routing
- Private Connectivity
- AWS Networking Components

---

# FINAL ARCHITECTURE

                    AWS CLOUD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

         AWS VPC (10.10.0.0/16)
                    │
        ┌───────────┴───────────┐
        │                       │
 Public Subnet           Private Subnet
 10.10.1.0/24             10.10.2.0/24
                                │
                         Private EC2
                           10.10.2.x

                    │
           Virtual Private Gateway
                    │
================ VPN TUNNEL ================
                    │

               INTERNET
                    │

================ ON-PREM ===================

             VMware Workstation
                    │
             pfSense Firewall
        WAN                    LAN
 192.168.100.x             192.168.1.1
                                   │
                             Ubuntu VM
                           192.168.1.x

---

# SOFTWARE REQUIRED

## 1. VMware Workstation
Download:
https://www.vmware.com/products/workstation-pro.html

---

## 2. pfSense ISO Installer

Download:
https://www.pfsense.org/download/

Select:
- Architecture: AMD64
- Installer: ISO Installer
- Console: VGA

IMPORTANT:
Use ISO Installer.
Do NOT use memstick installer.

Downloaded file example:
netgate-installer-v1.2-RELEASE-amd64.iso

---

## 3. Ubuntu Server ISO

Download:
https://ubuntu.com/download/server

Recommended:
Ubuntu Server LTS

Example:
ubuntu-24.04-live-server-amd64.iso

---

# PHASE 1 — VMWARE NETWORK SETUP

# STEP 1 — Open VMware Network Editor

VMware → Edit → Virtual Network Editor

---

# STEP 2 — Configure VMnet8

Settings:
- Type: NAT
- Subnet: 192.168.100.0/24

Purpose:
Internet access for pfSense WAN.

---

# STEP 3 — Configure VMnet2

Settings:
- Type: Host-only
- Subnet: 192.168.1.0/24

Purpose:
Internal LAN network.

---

# PHASE 2 — CREATE pfSense FIREWALL

# STEP 4 — Create pfSense VM

Create New Virtual Machine.

Select:
- Typical

Choose pfSense ISO.

Guest OS:
- Other
- FreeBSD 14 64-bit

VM Name:
pfSense-Firewall

Disk:
20 GB

---

# STEP 5 — Configure VM Hardware

RAM:
2 GB

CPU:
2 cores

---

# STEP 6 — Configure Network Adapters

## Adapter 1
- NAT
Purpose:
WAN

---

## Adapter 2
- Custom → VMnet2
Purpose:
LAN

---

# STEP 7 — Install pfSense

Boot VM.

Select:
Install

---

# STEP 8 — Interface Assignment

WAN:
em0

LAN:
em1

---

# STEP 9 — LAN Configuration

Keep defaults:
- LAN IP: 192.168.1.1/24
- DHCP Enabled

---

# STEP 10 — Install CE Edition

When asked:
Select:
Install CE

---

# STEP 11 — Disk Configuration

Filesystem:
ZFS

Partition:
GPT

Pool Type:
Stripe

Disk:
da0 20GB

---

# STEP 12 — Complete Installation

Wait for installation to finish.

IMPORTANT:
Do NOT disconnect ISO during installation.

---

# STEP 13 — Disconnect ISO AFTER Installation

VMware → Settings → CD/DVD

Uncheck:
- Connected
- Connect at power on

Reboot VM.

---

# STEP 14 — Access pfSense GUI

Open browser:
https://192.168.1.1

Login:
Username: admin
Password: pfsense

Complete setup wizard.

---

# PHASE 3 — CREATE UBUNTU SERVER VM

# STEP 15 — Create Ubuntu VM

Create New Virtual Machine.

Choose Ubuntu Server ISO.

Guest OS:
Linux → Ubuntu 64-bit

Disk:
20 GB

RAM:
2 GB

CPU:
2 cores

---

# STEP 16 — Configure Ubuntu Network

Network Adapter:
- Custom → VMnet2

IMPORTANT:
Ubuntu must connect to pfSense LAN.

---

# STEP 17 — Install Ubuntu Server

Keep default installation settings.

Storage:
Use entire disk

Ubuntu Pro:
Skip for now

---

# STEP 18 — Enable OpenSSH

Select:
- Install OpenSSH Server
- Allow password authentication over SSH

---

# STEP 19 — Complete Installation

After installation:
Disconnect Ubuntu ISO before reboot.

---

# STEP 20 — Verify Connectivity

Login to Ubuntu.

Check IP:
```bash
ip a
````

Expected:
192.168.1.x

---

# Test pfSense Connectivity

```bash
ping 192.168.1.1
```

---

# Test Internet

```bash
ping google.com
```

If successful:
pfSense routing works correctly.

---

# PHASE 4 — FIND PUBLIC IP

# STEP 21 — Find Public IP

Run:

```bash
curl ifconfig.me
```

Example:
223.188.100.106

IMPORTANT:
This is your PUBLIC IP.
AWS uses this to connect VPN tunnel.

---

# IMPORTANT CGNAT CHECK

Reconnect hotspot and check IP again.

If IP remains same:
Good for VPN.

If IP changes:
VPN may break after reconnect.

---

# PHASE 5 — AWS NETWORK SETUP

# STEP 22 — Login to AWS Console

Open:
[https://console.aws.amazon.com](https://console.aws.amazon.com)

Select Region:
ap-south-1 (Mumbai)

---

# STEP 23 — Create VPC

VPC → Your VPCs → Create VPC

Settings:

* Name: demo-vpc
* CIDR: 10.10.0.0/16

---

# STEP 24 — Create Public Subnet

CIDR:
10.10.1.0/24

Name:
public-subnet

---

# STEP 25 — Create Private Subnet

CIDR:
10.10.2.0/24

Name:
private-subnet

---

# STEP 26 — Create Internet Gateway

Name:
demo-igw

Attach to:
demo-vpc

---

# STEP 27 — Create Public Route Table

Name:
public-rt

Add Route:
0.0.0.0/0 → Internet Gateway

Associate:
public-subnet

---

# PHASE 6 — CREATE AWS VPN COMPONENTS

# STEP 28 — Create Virtual Private Gateway

VPC → Virtual Private Gateways

Name:
demo-vgw

Attach to:
demo-vpc

---

# STEP 29 — Create Customer Gateway

VPC → Customer Gateways

Settings:

* Name: demo-cgw
* Routing: Static
* IP Address: YOUR PUBLIC IP

Example:
223.188.100.106

---

# STEP 30 — Create Site-to-Site VPN

VPC → Site-to-Site VPN Connections

Settings:

* Name: demo-vpn
* Target Gateway: demo-vgw
* Customer Gateway: demo-cgw
* Routing: Static
* Static Route:
  192.168.1.0/24

IMPORTANT:
This route is critical.

---

# STEP 31 — Download VPN Configuration

Select:

* Vendor: pfSense
* Platform: pfSense
* Software: pfSense 2.2.5+ (GUI)

Download config file.

IMPORTANT:
Keep this file safe.
It contains:

* Tunnel IPs
* PSK keys
* Encryption settings

---

# PHASE 7 — CREATE PRIVATE EC2 INSTANCE

# STEP 32 — Launch EC2

EC2 → Launch Instance

Settings:

* Name: private-ec2
* AMI: Amazon Linux 2023
* Instance Type: t2.micro

---

# STEP 33 — Create Key Pair

Create:

* Name: demo-key
* Type: RSA
* Format: .pem

Download safely.

---

# STEP 34 — Network Configuration

Settings:

* VPC: demo-vpc
* Subnet: private-subnet
* Auto Public IP: DISABLE

IMPORTANT:
EC2 must NOT have public IP.

---

# STEP 35 — Security Group

Name:
private-ec2-sg

Inbound Rules:

1. ICMP
   Source:
   192.168.1.0/24

2. SSH
   Port:
   22

Source:
192.168.1.0/24

---

# STEP 36 — Note Private EC2 IP

Example:
10.10.2.80

You will ping this from Ubuntu VM.

---

# PHASE 8 — CONFIGURE IPSec IN pfSense

# STEP 37 — Enable NAT Traversal

pfSense:
VPN → IPsec → Advanced Settings

Set:
NAT Traversal → Auto

Save.

IMPORTANT:
Required for VMware NAT + mobile hotspot.

---

# STEP 38 — Configure Phase 1

pfSense:
VPN → IPsec → Add P1

Settings:

General:

* Key Exchange: IKEv1
* Interface: WAN
* Remote Gateway:
  Tunnel 1 Outside IP from AWS config

Authentication:

* Mutual PSK
* PSK:
  Copy from AWS config

Algorithms:

* AES128
* SHA1
* DH Group 2

Save.

---

# STEP 39 — Configure Phase 2

Add P2.

Local Network:
192.168.1.0/24

Remote Network:
10.10.0.0/16

Algorithms:

* ESP
* AES128
* SHA1

Save.
Apply Changes.

---

# PHASE 9 — FIREWALL RULES

# STEP 40 — Add IPsec Rule

Firewall → Rules → IPsec

Add:

* Action: Pass
* Protocol: Any
* Source: Any
* Destination: Any

Save.
Apply Changes.

---

# PHASE 10 — AWS ROUTING

# STEP 41 — Create Private Route Table

Name:
private-rt

Associate:
private-subnet

---

# STEP 42 — Add VPN Route

Destination:
192.168.1.0/24

Target:
demo-vgw

IMPORTANT:
Without this route:
traffic will fail.

---

# STEP 43 — Enable Route Propagation

Route Table → Route Propagation

Enable:
demo-vgw

---

# PHASE 11 — BRING UP VPN TUNNEL

# STEP 44 — Connect Tunnel

pfSense:
Status → IPsec

Click:
Connect

Wait:
30–60 seconds.

Expected:
Tunnel Status = ESTABLISHED

---

# STEP 45 — Verify AWS Tunnel

AWS:
VPN Connections → Tunnel Details

Expected:
Tunnel 1 = UP

---

# PHASE 12 — TEST CONNECTIVITY

# STEP 46 — Ping EC2 from Ubuntu

```bash
ping 10.10.2.x
```

Expected:
Successful replies.

---

# STEP 47 — SSH into EC2

```bash
ssh -i demo-key.pem ec2-user@10.10.2.x
```

IMPORTANT:
.pem file must exist in Ubuntu VM.

---

# SUCCESSFUL TRAFFIC FLOW

Ubuntu VM
↓
pfSense Firewall
↓
IPSec Tunnel
↓
AWS VGW
↓
AWS Route Table
↓
Private EC2

---

# WHAT STUDENTS LEARN

* Hybrid Cloud
* AWS Networking
* Site-to-Site VPN
* IPSec
* Routing
* Virtual Private Gateway
* Customer Gateway
* Route Tables
* Security Groups
* Private Connectivity
* Firewall Configuration
* Enterprise Networking

---

# ISSUES FACED DURING SETUP

# 1. pfSense Installation Failed

Error:
pkg-static failed to fetch

Reason:
ISO disconnected during installation.

Solution:
Keep ISO connected until installation completes.

---

# 2. pfSense Boot Loop

Reason:
ISO still connected after installation.

Solution:
Disconnect CD/DVD after installation.

---

# 3. Ubuntu Internet Not Working

Reason:
Ubuntu connected to wrong network adapter.

Solution:
Connect Ubuntu VM to VMnet2.

---

# 4. VPN Tunnel UP But Ping Failed

Reason:
Missing static route:
192.168.1.0/24

Solution:
Add static route in:
AWS VPN Connection
AND private route table.

---

# 5. VPN Tunnel Failed Initially

Possible causes:

* Wrong PSK
* Wrong Tunnel IP
* NAT Traversal disabled
* Mobile hotspot CGNAT

Solution:
Enable NAT Traversal = Auto

---

# FINAL RESULT

Successfully implemented:
AWS Site-to-Site VPN using pfSense firewall
connecting on-prem VMware infrastructure
with AWS VPC through encrypted IPSec tunnel.

Achieved:

* Private connectivity
* Secure routing
* Enterprise hybrid networking
* End-to-end communication between:
  192.168.1.x ↔ 10.10.2.x

```
```
