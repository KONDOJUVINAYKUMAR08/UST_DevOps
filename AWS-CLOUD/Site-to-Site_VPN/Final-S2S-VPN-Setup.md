# AWS Site-to-Site VPN using pfSense + VMware + Ubuntu Server
# Complete Step-by-Step Hybrid Cloud Networking Lab Guide

Author: Vinay Kumar

---

# OBJECTIVE

Build a real enterprise-style Hybrid Cloud Architecture where:

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

---

# WHAT STUDENTS WILL LEARN

| Concept | Understanding |
|---|---|
| Hybrid Cloud | Connecting On-Prem to AWS |
| IPSec VPN | Secure encrypted communication |
| Routing | Network traffic flow |
| AWS Networking | VPC, VGW, CGW |
| Firewalls | pfSense enterprise firewall |
| Private Connectivity | Access without public IP |
| Security Groups | AWS firewalling |
| Troubleshooting | Real-world VPN debugging |

---

# FINAL ARCHITECTURE

                    AWS CLOUD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

Example:
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

VMware → Create New Virtual Machine

Select:
- Typical

Choose:
- pfSense ISO Installer

Guest OS:
- Other
- FreeBSD 14 64-bit

VM Name:
pfSense-Firewall

Disk:
20 GB

---

# STEP 5 — Configure Hardware

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

# STEP 14 — Access pfSense Web GUI

Open browser on Windows host:

https://192.168.1.1

You will see SSL warning.

Click:
- Advanced
- Proceed

---

# STEP 15 — Login to pfSense

Default Credentials:

Username:
admin

Password:
pfsense

Click:
Sign In

Setup Wizard opens automatically.

---

# STEP 16 — Welcome Screen

Click:
Next

---

# STEP 17 — General Information

Configure:

Hostname:
pfsense

Domain:
localdomain

Primary DNS:
8.8.8.8

Secondary DNS:
8.8.4.4

Click:
Next

---

# STEP 18 — Time Server Configuration

Keep defaults.

Timezone:
Asia/Kolkata

Click:
Next

---

# STEP 19 — WAN Configuration

Keep:
- WAN Type: DHCP

Do NOT enable PPPoE.

IMPORTANT:
Scroll down and UNCHECK:

Block private networks and loopback addresses

Reason:
VMware NAT uses private IP range:
192.168.100.x

If enabled:
pfSense blocks internet traffic.

Click:
Next

---

# STEP 20 — LAN Configuration

Keep default:

LAN IP:
192.168.1.1/24

Click:
Next

---

# STEP 21 — Admin Password

Set strong password.

Example:
Vinay@123

Click:
Next

---

# STEP 22 — Reload Configuration

Click:
Reload

Wait:
30–60 seconds.

---

# STEP 23 — Finish Setup

Click:
Finish

Dashboard opens.

---

# STEP 24 — Verify Interfaces

Dashboard should show:

WAN:
192.168.100.x

LAN:
192.168.1.1

Status:
Online

---

# PHASE 3 — CREATE UBUNTU SERVER VM

# STEP 25 — Create Ubuntu VM

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

# STEP 26 — Configure Ubuntu Network

Network Adapter:
- Custom → VMnet2

IMPORTANT:
Ubuntu must connect to pfSense LAN.

---

# STEP 27 — Install Ubuntu Server

Keep default installation settings.

Storage:
Use entire disk

Ubuntu Pro:
Skip for now

---

# STEP 28 — Enable OpenSSH

Enable:
- Install OpenSSH Server
- Allow password authentication over SSH

---

# STEP 29 — Complete Installation

Disconnect Ubuntu ISO before reboot.

---

# STEP 30 — Verify Connectivity

Login to Ubuntu.

Check IP:

```bash
ip a

Expected:
192.168.1.x

Ping pfSense
ping 192.168.1.1
Ping Internet
ping google.com

If successful:
pfSense routing works correctly.

PHASE 4 — FIND PUBLIC IP
STEP 31 — Find Public IP

Run:

curl ifconfig.me

Example:
223.188.100.106

IMPORTANT:
AWS uses this IP to create VPN tunnel.

IMPORTANT CGNAT CHECK

Reconnect hotspot and verify IP remains same.

If IP changes:
VPN may break after reconnect.

PHASE 5 — AWS NETWORK SETUP
STEP 32 — Login to AWS Console

https://console.aws.amazon.com

Select Region:
ap-south-1 (Mumbai)

STEP 33 — Create VPC

VPC → Your VPCs → Create VPC

Settings:

Name: demo-vpc
CIDR: 10.10.0.0/16
STEP 34 — Create Public Subnet

CIDR:
10.10.1.0/24

Name:
public-subnet

STEP 35 — Create Private Subnet

CIDR:
10.10.2.0/24

Name:
private-subnet

STEP 36 — Create Internet Gateway

Name:
demo-igw

Attach to:
demo-vpc

STEP 37 — Create Public Route Table

Name:
public-rt

Add Route:
0.0.0.0/0 → Internet Gateway

Associate:
public-subnet

PHASE 6 — CREATE AWS VPN COMPONENTS
STEP 38 — Create Virtual Private Gateway

VPC → Virtual Private Gateways

Name:
demo-vgw

Attach to:
demo-vpc

STEP 39 — Create Customer Gateway

VPC → Customer Gateways

Settings:

Name: demo-cgw
Routing: Static
IP Address: YOUR PUBLIC IP

Example:
223.188.100.106

STEP 40 — Create Site-to-Site VPN

VPC → Site-to-Site VPN Connections

Settings:

Name: demo-vpn
Target Gateway: demo-vgw
Customer Gateway: demo-cgw
Routing: Static

Static Route:
192.168.1.0/24

IMPORTANT:
Without this route:
Tunnel may come UP but traffic fails.

STEP 41 — Download VPN Configuration

Select:

Vendor: pfSense
Platform: pfSense
Software: pfSense 2.2.5+ (GUI)

Download configuration file.

IMPORTANT:
This file contains:

Tunnel IPs
PSK keys
Encryption settings
PHASE 7 — CREATE PRIVATE EC2 INSTANCE
STEP 42 — Launch EC2

EC2 → Launch Instance

Settings:

Name: private-ec2
AMI: Amazon Linux 2023
Instance Type: t2.micro
STEP 43 — Create Key Pair

Create:

Name: demo-key
Type: RSA
Format: .pem

Download safely.

STEP 44 — Network Configuration

Settings:

VPC: demo-vpc
Subnet: private-subnet
Auto Public IP: DISABLE

IMPORTANT:
EC2 must NOT have public IP.

STEP 45 — Create Security Group

Name:
private-ec2-sg

Inbound Rules:

ICMP
Source:
192.168.1.0/24
SSH
Port:
22

Source:
192.168.1.0/24

STEP 46 — Note EC2 Private IP

Example:
10.10.2.80

You will ping this from Ubuntu VM.

PHASE 8 — CONFIGURE IPSec IN pfSense
STEP 47 — Enable NAT Traversal

pfSense:
VPN → IPsec → Advanced Settings

Set:
NAT Traversal → Auto

Save.

IMPORTANT:
Required because:

VMware NAT
Mobile hotspot
Double NAT environment
STEP 48 — Configure Phase 1

pfSense:
VPN → IPsec → Add P1

General:

Key Exchange: IKEv1
Interface: WAN
Remote Gateway:
Tunnel 1 Outside IP from AWS config

Authentication:

Mutual PSK
PSK:
Copy from AWS config

Algorithms:

AES128
SHA1
DH Group 2

Save.

STEP 49 — Configure Phase 2

Add P2.

Local Network:
192.168.1.0/24

Remote Network:
10.10.0.0/16

Algorithms:

ESP
AES128
SHA1

Save.
Apply Changes.

PHASE 9 — FIREWALL RULES
STEP 50 — Add IPsec Rule

Firewall → Rules → IPsec

Add:

Action: Pass
Protocol: Any
Source: Any
Destination: Any

Save.
Apply Changes.

PHASE 10 — AWS ROUTING
STEP 51 — Create Private Route Table

Name:
private-rt

Associate:
private-subnet

STEP 52 — Add VPN Route

Destination:
192.168.1.0/24

Target:
demo-vgw

IMPORTANT:
Without this route:
Traffic fails.

STEP 53 — Enable Route Propagation

Route Table → Route Propagation

Enable:
demo-vgw

PHASE 11 — BRING UP VPN TUNNEL
STEP 54 — Connect Tunnel

pfSense:
Status → IPsec

Click:
Connect

Wait:
30–60 seconds.

Expected:
Tunnel Status = ESTABLISHED

STEP 55 — Verify AWS Tunnel

AWS:
VPN Connections → Tunnel Details

Expected:
Tunnel 1 = UP

PHASE 12 — TEST CONNECTIVITY
STEP 56 — Ping EC2 from Ubuntu
ping 10.10.2.80

Expected:
Successful replies.

STEP 57 — SSH into EC2
ssh -i demo-key.pem ec2-user@10.10.2.80

IMPORTANT:
.pem file must exist in Ubuntu VM.

SUCCESSFUL TRAFFIC FLOW

Ubuntu VM
↓
pfSense Firewall
↓
Encrypted IPSec Tunnel
↓
AWS Virtual Private Gateway
↓
AWS Route Table
↓
Private EC2

WHAT STUDENTS LEARN
Hybrid Cloud Networking
AWS Site-to-Site VPN
IPSec
Routing
Firewalls
AWS Networking
Security Groups
Route Tables
VPN Troubleshooting
Enterprise Architecture
ISSUES FACED DURING SETUP
1. pfSense Installation Failed

Error:
pkg-static failed to fetch

Reason:
ISO disconnected during installation.

Solution:
Keep ISO connected until installation completes.

2. pfSense Boot Loop

Reason:
ISO still connected after installation.

Solution:
Disconnect CD/DVD after installation.

3. Ubuntu Internet Not Working

Reason:
Wrong network adapter selected.

Solution:
Connect Ubuntu VM to VMnet2.

4. Tunnel UP But Ping Failed

Reason:
Missing static route:
192.168.1.0/24

Solution:
Add:

Static route in VPN Connection
Route in private route table
5. VPN Tunnel Failed Initially

Possible causes:

Wrong PSK
Wrong tunnel IP
NAT Traversal disabled
Mobile hotspot NAT

Solution:
Enable NAT Traversal = Auto

6. Security Group Blocking Traffic

Reason:
ICMP and SSH not allowed.

Solution:
Allow:

ICMP
SSH
from:
192.168.1.0/24
FINAL RESULT

Successfully implemented:
AWS Site-to-Site VPN using pfSense firewall
connecting on-prem VMware infrastructure
with AWS VPC through encrypted IPSec tunnel.

Achieved:

Secure Hybrid Cloud Connectivity
Private Communication
Enterprise Networking
End-to-End Routing
Real-world VPN Architecture
