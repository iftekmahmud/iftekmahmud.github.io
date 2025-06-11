# Exploiting WPS with Reaver

As wireless networks remain a cornerstone of modern connectivity, their security is a critical concern for organizations and individuals alike. Advanced wireless attacks, particularly those targeting Wi-Fi Protected Setup (WPS) vulnerabilities using tools like Reaver, pose significant risks to network integrity. In this blog, I aim to provide a detailed, practical guide for security researchers, penetration testers, and network administrators, covering the technical execution of a Reaver-based attack, its implications, and robust defensive strategies. 

## Understanding WPS and Its Vulnerabilities

Wi-Fi Protected Setup (WPS) was introduced to simplify the process of connecting devices to wireless networks. By allowing users to enter an 8-digit PIN or press a physical button on the router, WPS bypasses the need to input complex WPA/WPA2 passphrases. However, this convenience comes at a cost: a design flaw in the WPS protocol makes it susceptible to brute-force attacks.
The WPS PIN is validated in two halves (four digits each), reducing the effective keyspace to approximately 11,000 possible combinations (10^4 for the first half, plus 10^3 for the second, accounting for a checksum digit). Tools like Reaver exploit this flaw by systematically guessing PINs until the correct one is found, at which point the router discloses the WPA/WPA2 passphrase. This vulnerability affects many routers, even those with strong passphrases, unless WPS is disabled or properly secured.
Reaver: A Tool for WPS Exploitation
Reaver is an open-source tool designed to automate WPS PIN brute-forcing. By targeting the WPS protocol, Reaver can recover the WPA/WPA2 passphrase in hours or days, depending on the router’s configuration and defenses. While highly effective against vulnerable devices, Reaver’s success is not guaranteed, as modern routers may implement rate-limiting or disable WPS entirely. Below, we outline the technical steps to perform a Reaver attack, followed by mitigation strategies.
Prerequisites
Before executing a Reaver attack, ensure you have the following:

A Linux-based system: Kali Linux is recommended, as it comes pre-installed with Reaver and other wireless auditing tools.
A compatible wireless adapter: The adapter must support monitor mode and packet injection. Popular choices include the Alfa AWUS036NHA (Atheros AR9271 chipset) or Panda PAU05.
Administrative privileges: Root access is required to run Reaver and related tools.
Legal authorization: Only perform attacks on networks you own or have explicit permission to test. Unauthorized access is illegal and unethical.

Step-by-Step Guide to Attacking with Reaver
1. Set Up Your Wireless Adapter
Ensure your wireless adapter is configured for monitor mode, which allows it to capture and inject packets.
# Check available interfaces
iwconfig

# Enable monitor mode on wlan0
sudo airmon-ng start wlan0

This creates a monitor interface (e.g., wlan0mon). Confirm the interface is in monitor mode:
iwconfig wlan0mon

2. Identify the Target Router
Use airodump-ng to scan for nearby wireless networks and identify the target router’s BSSID (MAC address), channel, and WPS status.
sudo airodump-ng wlan0mon

Look for the target network in the output. Note the BSSID (e.g., 00:14:BF:12:34:56), channel (e.g., 6), and whether WPS is enabled (indicated in the WPS column). To focus on the target, run a targeted scan:
sudo airodump-ng --bssid 00:14:BF:12:34:56 --channel 6 --wps wlan0mon

3. Verify WPS Vulnerability
Use wash to confirm that the target router has WPS enabled and is not locked (some routers lock WPS after repeated failed attempts).
sudo wash -i wlan0mon

In the output, check the WPS Locked column. If it says No, the router is vulnerable. If Yes, Reaver may still work, but success is less likely due to rate-limiting.
4. Launch the Reaver Attack
Execute Reaver to brute-force the WPS PIN. The following command targets the router’s BSSID and channel, with verbose output (-vv) and the Pixie-Dust attack (-K 1) for faster PIN recovery on supported routers:
sudo reaver -i wlan0mon -b 00:14:BF:12:34:56 -c 6 -vv -K 1


-i: Specifies the monitor interface.
-b: Specifies the target BSSID.
-c: Specifies the channel.
-vv: Enables verbose output for debugging.
-K 1: Attempts the Pixie-Dust attack, which exploits weak WPS implementations to recover the PIN faster.

Reaver will begin guessing PINs, displaying progress and any errors. If successful, it will output the WPS PIN and the WPA/WPA2 passphrase.
5. Connect to the Network
Using the recovered passphrase, connect to the network via your wireless manager or command line:
# Example using nmcli
nmcli device wifi connect "Target_SSID" password "Recovered_Passphrase"

You now have access to the wireless network, simulating a successful attack.
Challenges and Limitations

Time-Consuming: Brute-forcing the WPS PIN can take hours or days, depending on the router’s response time and PIN complexity.
Rate-Limiting: Some routers lock WPS after multiple failed attempts, requiring you to wait or adjust Reaver’s timing parameters (e.g., --delay or --lock-delay).
False Positives: Not all routers with WPS enabled are vulnerable. Firmware updates or custom configurations may mitigate the attack.
Interference: Other wireless devices or networks can disrupt the attack, requiring a stable environment.

To improve success, experiment with Reaver’s advanced options, such as --pin to specify a starting PIN or --no-nacks to ignore negative acknowledgments.
Defending Against Reaver Attacks
Network administrators must proactively secure their wireless networks to mitigate Reaver and similar attacks. Here are evidence-based recommendations:

Disable WPS: The most effective defense is to disable WPS in the router’s admin panel. Log in to the router (typically via 192.168.0.1 or 192.168.1.1), navigate to the wireless settings, and turn off WPS. Note that some routers may not fully disable WPS despite the setting—verify with wash.

Use a Strong Passphrase: While Reaver bypasses the passphrase, a strong WPA2/WPA3 passphrase (at least 16 characters, mixing letters, numbers, and symbols) protects against secondary attacks if WPS is compromised.

Update Firmware: Manufacturers often release firmware updates to patch WPS vulnerabilities or implement rate-limiting. Regularly check the router’s admin panel or manufacturer’s website for updates.

Monitor for Suspicious Activity: Use intrusion detection systems (IDS) or network monitoring tools to detect repeated WPS authentication attempts, which may indicate a Reaver attack.

Segment Networks: Isolate critical devices on a separate VLAN or guest network to limit the impact of a breach.

Replace Vulnerable Hardware: If the router does not support disabling WPS or receiving firmware updates, consider upgrading to a modern, secure model.


Ethical Considerations
Wireless attacks like Reaver are powerful tools for penetration testers, but they carry significant ethical and legal responsibilities. Always obtain written permission from the network owner before conducting tests. Unauthorized access violates laws such as the U.S. Computer Fraud and Abuse Act (CFAA) or the UK Computer Misuse Act, with severe penalties. As security researchers, our goal is to improve network security, not exploit it maliciously.
Conclusion
Reaver’s ability to exploit WPS vulnerabilities underscores the importance of robust wireless security practices. By understanding and simulating these attacks, security professionals can better protect networks against real-world threats. For beginners, mastering tools like Reaver provides a foundation in wireless penetration testing, while advanced practitioners can leverage its nuances to assess complex environments. Network administrators, meanwhile, must prioritize disabling WPS and implementing layered defenses to safeguard their infrastructure.
To deepen your knowledge, experiment with Reaver in a controlled lab environment, explore other wireless attack tools (e.g., Aircrack-ng, Bully), and stay updated on emerging vulnerabilities. Wireless security is a dynamic field—staying ahead requires continuous learning and vigilance.
