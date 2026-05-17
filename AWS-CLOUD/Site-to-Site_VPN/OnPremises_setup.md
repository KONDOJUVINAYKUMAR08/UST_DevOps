# Complete pfSense + Ubuntu Server Lab Setup Guide using VMware Workstation

## Objective

This guide explains how to build a complete virtual networking lab using:

- VMware Workstation
- pfSense Firewall
- Ubuntu Server

This setup simulates a real enterprise firewall environment where:

Internet → pfSense Firewall → Internal Ubuntu Server

This guide is beginner-friendly and contains:
- Every installation step
- VMware configuration
- pfSense setup
- Ubuntu Server setup
- Networking setup
- Common troubleshooting issues faced during installation

---

# LAB ARCHITECTURE

                INTERNET
                    │
             VMware NAT (VMnet8)
                    │
              pfSense Firewall
         WAN ───────────── LAN
          │                  │
       VMnet8             VMnet2
                              │
                        Ubuntu Server

---

# SOFTWARE REQUIRED

## 1. VMware Workstation
Download:
https://www.vmware.com/products/workstation-pro.html

Install VMware Workstation normally using:
- Next
- Next
- Install

No special configuration required.

---

# 2. Download pfSense ISO

Download:
https://www.pfsense.org/download/

## IMPORTANT

Use:

- Architecture: AMD64
- Installer Type: ISO Installer
- NOT memstick installer
- Console: VGA

Downloaded file example:
netgate-installer-v1.2-RELEASE-amd64.iso

---

# 3. Download Ubuntu Server ISO

Download:
https://ubuntu.com/download/server

Recommended:
Ubuntu Server LTS

Example:
ubuntu-24.04-live-server-amd64.iso

---

# STEP 1 — CONFIGURE VMWARE NETWORKS

Open:

Edit → Virtual Network Editor

Create:

## VMnet8
Type:
- NAT

Subnet:
192.168.100.0/24

Purpose:
Internet access for WAN interface

---

## VMnet2
Type:
- Host-only

Subnet:
192.168.1.0/24

Purpose:
Internal LAN network

---

# STEP 2 — CREATE pfSense VM

## Create New Virtual Machine

Select:
- Typical

Select:
- Installer disc image file (ISO)

Choose:
- pfSense Netgate ISO Installer

Guest OS:
- Other
- FreeBSD 14 or later (64-bit)

VM Name:
pfSense-Firewall

Location:
Choose desired location

Disk:
20 GB

Finish.

---

# STEP 3 — CONFIGURE pfSense NETWORK ADAPTERS

Open:
VM Settings

## Adapter 1
Set:
- NAT
- VMnet8

Purpose:
WAN

---

## Adapter 2
Set:
- Custom → VMnet2

Purpose:
LAN

---

# STEP 4 — INSTALL pfSense

Start VM.

Installer loads.

---

## Interface Assignment Screen

Detected:
VMware Virtual Machine

Interfaces:
- WAN → em0
- LAN → em1

Select:
Continue

---

## LAN Network Setup

Default:
- IP: 192.168.1.1/24
- DHCP Enabled: true
- DHCP Range:
  192.168.1.100 – 192.168.1.199

Keep defaults.

Select:
Continue

---

## Subscription Validation

Message:
No active pfSense Plus subscription

Select:
Install CE

Reason:
Community Edition is free.

---

## Installation Options

Keep defaults:

- File System: ZFS
- Partition Scheme: GPT

Select:
Continue

---

## ZFS Configuration

Select:
Stripe – No Redundancy

Reason:
Single virtual disk.

---

## Disk Selection

Select:
da0 20GB VMware Virtual Disk

Select:
OK

---

## Confirmation

Select:
Yes

---

## pfSense Version

Choose:
2.8.1 Current Stable Version

---

# IMPORTANT ISSUE FACED DURING INSTALLATION

## ISSUE:
Installation failed while downloading packages.

Error example:
pkg-static: Failed to fetch

### REASON

Internet was disconnected because:
CD/DVD ISO was disconnected too early.

---

# SOLUTION

DO NOT uncheck:
- Connected
- Connect at power on

until installation fully completes.

Keep ISO connected during entire installation.

---

# AFTER INSTALLATION

Installer finishes.

Then:
- Go to VMware Settings
- CD/DVD
- Uncheck:
  - Connected
  - Connect at power on

This prevents installer boot loop.

---

# STEP 5 — FIRST pfSense BOOT

pfSense boots successfully.

Console shows:

WAN:
192.168.100.x

LAN:
192.168.1.1

---

# STEP 6 — ACCESS pfSense WEB GUI

Open browser on Windows host.

Access:
https://192.168.1.1

Accept SSL warning.

Login:

Username:
admin

Password:
pfsense

---

# STEP 7 — COMPLETE pfSense SETUP WIZARD

Wizard opens.

Configure:
- Hostname
- DNS
- Timezone
- Password

Keep most defaults.

Finish wizard.

---

# STEP 8 — CREATE UBUNTU SERVER VM

Create New VM.

Select:
- Ubuntu Server ISO

Guest OS:
Linux → Ubuntu 64-bit

VM Name:
Ubuntu-Server

Disk:
20 GB

RAM:
2 GB minimum

CPU:
2 cores recommended

---

# STEP 9 — CONFIGURE UBUNTU NETWORK

Open VM Settings.

Network Adapter:
- Custom → VMnet2

IMPORTANT:
Ubuntu must connect to LAN network.

NOT VMnet8.

---

# STEP 10 — INSTALL UBUNTU SERVER

Start VM.

---

## Storage Configuration

Keep defaults:
- Use entire disk
- LVM enabled

Select:
Done

---

## Confirmation Screen

Select:
Continue

Reason:
Formats only virtual disk.

---

## Ubuntu Pro Screen

Select:
Skip for now

---

## SSH Configuration

Enable:
- Install OpenSSH Server
- Allow password authentication over SSH

Reason:
Allows remote access and real-world server management.

---

## Featured Server Snaps

Do not select anything.

Select:
Done

---

# STEP 11 — UBUNTU INSTALLATION COMPLETE

When installation completes:

Select:
Reboot Now

---

# IMPORTANT

If Ubuntu asks:

"Remove installation medium and press ENTER"

Then:

VMware → Settings → CD/DVD

Uncheck:
- Connected
- Connect at power on

Press Enter.

---

# STEP 12 — LOGIN TO UBUNTU

Login using created username/password.

---

# STEP 13 — VERIFY NETWORK CONNECTIVITY

Check IP:

```bash
ip a

Expected:
192.168.1.x

Test pfSense connectivity
ping 192.168.1.1

Should work.

Test internet connectivity
ping google.com

Should work.

This confirms:

pfSense routing works
NAT works
Ubuntu internet works
