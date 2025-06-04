# Creating Encrypted Access Points in Wireless Man-in-the-Middle Attacks

As a security researcher, I often explore wireless network vulnerabilities to understand how attackers exploit them and how we can defend against such threats. One powerful technique involves setting up a rogue access point (AP) to simulate man-in-the-middle (MITM) attacks. While tools like `airbase-ng` from the Aircrack-ng suite are excellent for creating unencrypted APs, modern devices—particularly those running Android 10 and above—reject open networks due to enhanced security features. This is where `hostapd` shines, offering the ability to create an encrypted AP with WPA2 or WPA3 protocols. In this blog, I’ll provide a practical, hands-on guide to setting up an encrypted AP using `hostapd` on Kali Linux, tailored for ethical security testing in controlled environments.

**Disclaimer:** This guide is for educational purposes only. Creating and using rogue APs on networks or devices without explicit permission is illegal and unethical. Conduct all experiments in a lab environment with devices you own or have authorization to test.

## Why Use an Encrypted AP?

Modern operating systems, such as Android and iOS, enforce strict Wi-Fi security policies. Unencrypted APs (like those created by `airbase-ng`) are often flagged as insecure, leading to connection refusals or warnings like “No Internet.” An encrypted AP, secured with WPA2 or WPA3, mimics legitimate networks more convincingly, allowing you to test client behavior, intercept encrypted traffic (with proper tools), or simulate advanced MITM scenarios. `hostapd` is the go-to tool for this, as it supports robust encryption and is well-integrated with Kali Linux.

## Prerequisites

To follow this guide, ensure you have:

- A Kali Linux machine (physical or virtual, e.g., in VMware).
- A Wi-Fi adapter that supports Access Point (AP) mode (e.g., TP-Link WN722N with Atheros AR9271 chipset). Verify compatibility with `iw list | grep -A 10 "Supported interface modes"`.
- Basic Linux terminal skills.
- Administrative (root) access on Kali Linux.
- A controlled lab environment with devices you own or have permission to test.

## Step-by-Step Guide

### 1. Prepare Your Wi-Fi Adapter

Before creating the AP, ensure your Wi-Fi adapter is ready and supports the necessary modes.

1. **Connect the Adapter**:
   - Plug your external Wi-Fi adapter into your Kali Linux machine.

2. **Verify Adapter Recognition**:
   - Check the available interfaces:
     ```bash
     iwconfig
