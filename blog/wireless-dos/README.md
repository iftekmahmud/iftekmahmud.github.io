# Securing Wireless Networks from DoS Vulnerabilities

Wireless networks are all over the place, powering everything from home Wi-Fi to enterprise systems. However, their accessibility makes them prime targets for Denial-of-Service (DoS) attacks, which aim to disrupt network availability and performance. As a security researcher, I've seen how these attacks exploit vulnerabilities in wireless Access Points (APs) or client devices, causing crashes, unresponsiveness, or disconnection of legitimate users.

## What Are Wireless DoS Attacks?

A wireless DoS attack seeks to overwhelm or disrupt a wireless network, rendering it inaccessible to authorized users. Unlike wired networks, wireless networks are particularly vulnerable due to their open medium, where attackers can interfere with radio signals or exploit protocol weaknesses without physical access. Common types include:

- **Deauthentication Attacks:** Disconnect clients from an AP by sending spoofed deauthentication frames.
- **Beacon Flood Attacks:** Overwhelm clients with fake beacon frames, advertising nonexistent APs, causing confusion or resource exhaustion.
- **Jamming Attacks:** Emit radio signals to interfere with legitimate wireless communications, effectively blocking network access.

These attacks exploit the IEEE 802.11 protocol's management frames, which are often unencrypted and unauthenticated, making them easy to spoof. Let's dive into the most prevalent type, which is the deauthentication attack, to understand its mechanics and impact.

## Deauthentication Attacks

Deauthentication attacks are a go-to for attackers due to their simplicity and effectiveness. By sending forged deauthentication frames, an attacker tricks an AP or client into believing the connection is terminated, forcing disconnection. Below, I outline the steps to execute such an attack using tools like `aireplay-ng` (for educational purposes only, in controlled environments with explicit permission).

In my test, I targeted my own AP and used the MAC address for my wireless adapter to simulate the attack on my "Bravo 6" network.

### 1. Setting Up the Environment

To perform a deauthentication attack, you need a wireless adapter capable of monitor mode. Monitor mode allows the adapter to capture all wireless traffic, including management frames, without associating with any network.

1. Enable Monitor Mode:

    - Use a compatible Wi-Fi adapter (e.g., one supporting the `ath9k` or `rt2800usb` chipset).

    - Run the following commands to enable monitor mode:

        <div style="text-align: center;">
            <img src="assets/images/1.png" width="570">
        </div>

        This creates a virtual interface (e.g., `wlan0`) in monitor mode.

    - Verify monitor mode:

        <div style="text-align: center;">
            <img src="assets/images/2.png" width="530">
        </div>

2. Identify the Target AP and Clients:

    Use `airodump-ng` to scan for nearby APs and their connected clients:

     <div style="text-align: center;">
        <img src="assets/images/3.png" width="650">
      </div>

    This displays a list of APs, including their BSSID (MAC address), channel, and connected clients.

     <div style="text-align: center;">
        <img src="assets/images/3b.png" width="650">
      </div>

    In my test, I noted my AP's BSSID (`E8:65:D4:xx:xx:xx`) for my "Bravo 6" network, which I used for the target AP, while my adapter's MAC address was `00:13:EF:xx:xx:xx`.

### 2. Launching the Deauthentication Attack

With the target identified, you can launch the attack using `aireplay-ng`, a tool from the Aircrack-ng suite designed to inject frames into wireless networks.

 <div style="text-align: center;">
    <img src="assets/images/4.png" width="630">
  </div>

- `aireplay-ng`: The tool for injecting frames.
- `-deauth 1000`: Sends 1000 deauthentication packets to the target AP, disconnecting clients.
- `a E8:65:D4:xx:xx:xx`: Specifies the target AP's MAC address.
- `h 00:13:EF:xx:xx:xx`: Specifies the attacker's wireless adapter MAC address.
- `wlan0`: The interface in monitor mode.

**Execution:**

- Run the command to flood the AP with deauthentication frames. The AP interprets these as legitimate requests from clients to disconnect, causing clients to lose connectivity.

- In my test on the "Bravo 6" network, the attack was successful, and all devices connected to my Wi-Fi lost their connection while the attack was running.

- The output showed continuous "Sending DeAuth" messages, confirming the attack's effectiveness. 

 <div style="text-align: center;">
    <img src="assets/images/5.png" width="100">
  </div>

- Monitor the attack's impact using `airodump-ng` to observe the client list diminishing as devices are forcibly disconnected.

### 3. Observing the Impact

As the attack progresses, clients will struggle to maintain a connection with the AP. The client list in `airodump-ng` will show fewer connected devices, and users may experience dropped connections or inability to reconnect. This disruption can lead to significant productivity losses, communication breakdowns, or even financial and reputational damage in enterprise environments.

In my experiment, the client list showed no connected devices on "Bravo 6" as the deauthentication frames overwhelmed the AP. 

**Note:** Performing such attacks without permission is illegal and unethical. My test was conducted on my own network with my own equipment, ensuring no unauthorized impact. Always conduct tests in a lab environment or with explicit authorization.

## Impact of Wireless DoS Attacks

The consequences of wireless DoS attacks extend beyond mere inconvenience:

- **Productivity Loss:** Disrupted connectivity halts workflows, especially in environments reliant on real-time communication.
- **Communication Breakdowns:** VoIP calls, video conferences, or IoT device operations may fail.
- **Financial Implications:** Downtime in commercial settings can lead to lost revenue or operational costs.
- **Reputational Damage:** Repeated disruptions erode trust in an organization's network reliability.
- **Compromised Trust:** Users may question the security of a network that fails to protect against such attacks.

## Mitigating Wireless DoS Attacks

Defending against wireless DoS attacks requires a multi-layered approach.

1. **Enable Management Frame Protection (MFP)**

    - MFP (IEEE 802.11w) encrypts and authenticates management frames, preventing spoofed deauthentication attacks.

    - Configure APs and clients to support MFP:
        - On enterprise-grade APs (e.g., Cisco, Aruba), enable 802.11w in the wireless settings.
        - Ensure client devices support MFP, as older devices may not.

    - Limitation: MFP is not universally supported, and enabling it may exclude legacy devices.

2. **Traffic Filtering and Rate Limiting**

    - Deploy Wireless Intrusion Detection/Prevention Systems (WIDS/WIPS) to detect and block suspicious management frames.
    - Example tools: Aruba's RFProtect, Cisco's Adaptive Wireless IPS.
    - Rate-limit management frames to reduce the impact of flooding attacks.

3. **Access Control**

    - Use MAC address filtering to restrict connections to known devices, though this is less effective against spoofing.
    - Implement strong authentication (e.g., WPA3-Enterprise) to ensure only authorized users access the network.

4. **Channel and Frequency Management**

    - Mitigate jamming by switching to less congested channels or using 5 GHz bands, which are harder to jam due to shorter range.
    - Use Dynamic Frequency Selection (DFS) to automatically switch channels when interference is detected.

5. **Network Segmentation**

    - Segment critical devices into separate VLANs or SSIDs to limit the blast radius of an attack.
    - Prioritize bandwidth for essential services using Quality of Service (QoS) policies.

6. **Monitoring and Alerts**

    - Deploy real-time monitoring tools to detect anomalies, such as sudden client disconnections or excessive management frames.
    - Set up alerts to notify administrators of potential DoS activity.

7. **Physical Security**

    - Reduce the AP's signal range to minimize exposure to external attackers.
    - Use directional antennas to focus coverage on intended areas.
Disclaimer: The techniques described are for educational purposes only. Unauthorized attacks on networks are illegal and unethical. Always obtain explicit permission before conducting security tests.
