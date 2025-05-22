# Nessus Unleashed for Advanced Penetration Testing

Vulnerability scanning is a cornerstone of penetration testing and cybersecurity assessments, enabling security professionals to identify weaknesses in systems before they can be exploited. Among the many tools available, **Nessus**, developed by Tenable, stands out as one of the most widely used vulnerability scanners, boasting over 67,000 CVEs and 168,000 plugins. This blog provides a detailed guide to using Nessus, from installation to advanced plugin configuration, tailored for both beginners and seasoned security researchers. 

## 1. Introduction to Nessus
Nessus is a powerful vulnerability scanner designed to identify security weaknesses in networks, systems, and applications. It is available in two primary versions: **Nessus Essentials** (free, with limitations such as scanning only 16 IP addresses) and **Nessus Professional** (a paid version with advanced features). This guide focuses on Nessus Essentials, which is sufficient for learning the core concepts of vulnerability scanning and is applicable to most commercial scanners.

Nessus leverages a vast database of plugins—scripts written in the Nessus Attack Scripting Language (NASL)—to detect vulnerabilities across various systems, including web servers, databases, and operating systems. These plugins are organized into families, such as Ubuntu Local Security Checks or Web Servers, and are regularly updated to address new vulnerabilities.

### Why Use Nessus?

- **Comprehensive Coverage:** With over 168,000 plugins, Nessus can detect a wide range of vulnerabilities, from missing patches to misconfigurations.
- **Ease of Use:** Its intuitive web interface simplifies scan configuration and result analysis.
- **Flexibility:** Supports both unauthenticated and authenticated scans, allowing for deeper system insights.
- **Reporting:** Offers detailed reports in formats like PDF, aiding in remediation and compliance.

This guide assumes you are using a Kali Linux virtual machine (VM) to run Nessus and scan a Metasploitable 2 VM, which is designed for security training and contains numerous vulnerabilities.

## 2. Installing Nessus on Kali Linux

### Prerequisites

- **System Requirements:** Tenable recommends 4 CPU cores and 8GB of RAM, but 2 CPU cores and 4GB of RAM suffice for Nessus Essentials in a lab environment.
- **Internet Connection:** Required for downloading the installer and activating Nessus.
- **Email Address:** Needed to register for an activation code.
- **Metasploitable 2:** A vulnerable Linux VM, downloadable from SourceForge.

### Installation

1. **Download Nessus:**

- Visit the Tenable downloads page.
- Select **Linux - Debian - amd64** as the platform and download the `.deb` installer (e.g., Nessus-10.8.4-debian10_amd64.deb).

![](assets/images/1.png)

- Copy the provided SHA256 checksum for verification.

2. **Verify the Installer:**

- Navigate to the download directory.
- Create a checksum file with the copied SHA256 value and the filename:

![](assets/images/2.png)

- Verify the checksum

![](assets/images/3.png)

- Expected output: `Nessus-10.8.4-debian10_amd64.deb: OK`. If the checksum does not match, re-download the installer to ensure integrity.

3. **Install Nessus:**

- Install the `.deb` package using `apt`:

![](assets/images/4.png)

- The installation process will unpack and configure Nessus core components.

4. **Start the Nessus Service:**

- Start the `nessusd` service

![](assets/images/5.png)

- Verify the service is running

![](assets/images/6.png)

5. **Access the Nessus Web Interface:**

- Open a browser and navigate to `https://127.0.0.1:8834`.
- You’ll encounter a certificate warning due to Nessus using a self-signed certificate. Click **Advanced** and **Accept the Risk and Continue**.

![](assets/images/7.png)

6. **Activate Nessus:**

- Select **Nessus Essentials** and click **Continue**.

![](assets/images/8.png)

- Register with your email to receive an activation code.
- Enter the activation code to proceed.
- Create a local Nessus user account (e.g., username: `admin`, with a strong password).

![](assets/images/9.png)

- Nessus will download and compile plugins, which may take several minutes.

![](assets/images/10.png)

**Pro Tip:** Always verify the installer’s checksum to prevent installing compromised software. If you encounter issues, ensure your Kali VM has sufficient resources and an active internet connection.

## 3. Setting Up Metasploitable 2

For installing Metasploitable 2 in the VM, check ![Building a Safe Hacking Lab with Metasploitable 2](https://iftekmahmud.github.io/blog/metasploitable-2/).

## 4. Understanding Nessus Components

Before diving into scanning, let’s explore Nessus’s core components, which are critical for effective use.

### Nessus Dashboard

Upon logging in, the Nessus dashboard displays two main tabs in the Essentials version:

- **Scans:** Where you create, manage, and view scan results.
- **Settings:** For configuring global settings, such as SMTP for email notifications or advanced performance options.

![](assets/images/11.png)

The **About** menu in the Settings tab provides details on your license and the number of remaining hosts you can scan (16 IPs for Essentials).

### Policies and Templates

- **Policies:** Predefined configurations for scans, which can be saved as templates for reuse.
- **Templates:** Nessus offers templates grouped into three categories:
  - **Discovery:** Includes **Host Discovery** for identifying live hosts and open ports.
  - **Vulnerabilities:** Templates like **Basic Network Scan** (preconfigured for broad scans), **Advanced Scan** (fully customizable), and **Advanced Dynamic Scan** (uses dynamic plugin filters).
  - **Compliance:** Available in the Professional version for compliance checks.

### Plugins

Plugins are the heart of Nessus, written in NASL to detect specific vulnerabilities. Each plugin belongs to a **plugin family** (e.g., Web Servers, Ubuntu Local Security Checks) and checks for vulnerabilities in a particular context. Nessus Essentials automatically enables relevant plugins based on the selected template, but advanced users can customize plugin selection.

## 5. Configuring and Performing a Vulnerability Scan

Let’s perform an unauthenticated vulnerability scan on Metasploitable 2 using the **Basic Network Scan** template, which is ideal for beginners due to its preconfigured settings.

### Configuration

1. **Create a New Scan:**

- From the **Scans** tab, click **New Scan**.
- Select **Basic Network Scan**.

![](assets/images/12.png)

2. **Configure Basic Settings:**

- **Name:** Enter a descriptive name, e.g., `Metasploitable Scan`.
- **Targets:** Specify the IP address of your Metasploitable 2 VM (e.g., `192.168.19.128`). Nessus supports single IPs, ranges, or FQDNs.

![](assets/images/13.png)

3. **Customize Discovery Settings:**

- Navigate to the **Discovery** tab and select **Custom** from the dropdown.

![](assets/images/14.png)

- In the **Port Scanning** section, set **Port scan range** to **80,443** to focus on web ports, as Metasploitable 2 hosts vulnerable web services like Apache.

![](assets/images/15.png)

- Enable **Consider unscanned ports as closed** to treat all other ports as closed.

![](assets/images/15.png)

- Disable **Host Discovery** by toggling **Ping the remote host** to **Off**, since you’ve confirmed the VM is live.

![](assets/images/16.png)

4. **Review Other Settings:**

- The **Assessment**, **Report**, and **Advanced** tabs contain default settings suitable for most scans. For now, leave them unchanged.
- Note that this scan is unauthenticated (no credentials provided), which may limit visibility into system-level vulnerabilities.

5. **Launch the Scan:**

- Click the arrow next to **Save** and select **Launch**.

![](assets/images/17.png)

- The scan status will appear as **Running** in the **My Scans** dashboard. You can pause or stop it if needed.

![](assets/images/18.png)

**Note:** Unauthenticated scans generate significant network traffic and may be detected by intrusion detection systems. In a lab like Metasploitable 2, this is not a concern, but exercise caution in production environments.

## 6. Analyzing Scan Results

OOnce the scan completes, Nessus provides a detailed results dashboard for analyzing Metasploitable 2’s vulnerabilities.

![](assets/images/19.png)

### Navigating the Results

1. **Hosts Page:**

- Click on the scan in the **My Scans** list to view the **Hosts** page.
- This page lists the Metasploitable 2 host (e.g., `192.168.19.128`) with a visual representation of vulnerabilities by severity (Critical, High, Medium, Low, Info).
- You might see multiple findings due to Metasploitable’s outdated Apache and other services.

![](assets/images/19.png)

2. **Vulnerabilities Page:**

- Click on the Metasploitable IP to view its vulnerabilities. You may find grouped findings like **HTTP (Multiple Issues)** in the Web Servers family.

![](assets/images/20.png)

- Drill down into a finding (e.g., **Canonical Ubuntu Linux SEoL (8.04.x)**) for details, including:
  - **Description:** Explains the vulnerability (e.g., outdated Canonical Ubuntu Linux version).
  - **Risk Information:** Includes Risk Factor and CVSS score.
  - **Solution:** Provides mitigation strategies, such as upgrading to a version of Canonical Ubuntu Linux that is currently supported.

3. **VPR (Vulnerability Priority Rating) Top Threats:**

Navigate to the VPR Top Threats tab (if available) to see a prioritized list of the top vulnerabilities on Metasploitable 2, based on Tenable’s Vulnerability Priority Rating.

5. **History:**

The History tab logs all scans run with this configuration, useful for tracking changes over time.

![](assets/images/23.png)

### Generating a Report

![](assets/images/23.png)

- From the results dashboard, click Report.
- Select the Detailed Vulnerabilities By Host template and choose PDF as the format.
- Click Generate Report to download a comprehensive PDF summarizing findings for each host.
- For a high-level overview, use the Complete List of Vulnerabilities by Host template.

**Pro Tip:** Regularly review the Audit Trail feature to understand plugin behavior and reduce false negatives, especially in complex environments.

6. Performing an Authenticated Vulnerability Scan
Authenticated scans provide deeper insights by accessing system internals, reducing false positives, and identifying issues like missing patches or outdated software. Let’s configure an authenticated scan against a Linux target named DESKTOP.
Step-by-Step Configuration

Create a New Scan:

Click New Scan and select Credentialed Patch Audit. This template focuses on local security checks, ideal for authenticated scans.


Configure Basic Settings:

Name: Authenticated Scan - DESKTOP.
Target: Enter the IP address of DESKTOP (e.g., 192.168.50.128).


Add Credentials:

Navigate to the Credentials tab and select SSH under the Host category.
Set Authentication method to password.
Enter:
Username: offsec
Password: lab
Elevate privileges with: sudo
Sudo user: root
Sudo password: lab


For Windows targets, use SMB or WMI credentials, ensuring compatibility with the target’s configuration.


Consider Environmental Factors:

Ensure no firewall blocks the scanner’s connection.
Check for antivirus (AV) interference. Add an exception for Nessus or temporarily disable AV, if possible.
For Windows, configure User Account Control (UAC) to allow Nessus or disable it temporarily (consult Tenable’s documentation).


Launch the Scan:

Click the arrow next to Save and select Launch.



Analyzing Authenticated Scan Results

Navigate to the Vulnerabilities tab after the scan completes.
Disable grouped results for clarity:
Click the settings wheel and select Disable Groups.


Review findings, such as vulnerabilities from the Ubuntu Local Security Checks plugin family, which may identify outdated software like Firefox or cURL.
Each finding includes:
Severity: E.g., High, Medium.
Description: Details the vulnerability and affected software version.
Patch Information: Specifies the patch or update required.



Security Note: Authenticated scans generate significant system and network noise (e.g., log entries, AV alerts). Use them judiciously and ensure proper permissions in real-world engagements.

7. Working with Nessus Plugins
For advanced users, Nessus’s plugin system allows precise vulnerability detection. Let’s configure a scan to check for CVE-2021-3156, a privilege escalation vulnerability in sudo, using the Advanced Dynamic Scan template.
Step-by-Step Plugin Configuration

Create a New Scan:

Click New Scan and select Advanced Dynamic Scan.


Configure Basic Settings:

Name: CVE-2021-3156 Scan.
Target: 192.168.50.128 (DESKTOP).


Add Credentials:

Use the same SSH and sudo credentials as in the authenticated scan.


Configure Dynamic Plugin Filter:

Navigate to the Dynamic Plugins tab.
Add a filter:
Left Dropdown: Select CVE.
Middle Dropdown: Choose is equal to.
Right Dropdown: Enter CVE-2021-3156.


Click Preview Plugins to list matching plugins (this may take a few minutes).
Add a second filter for precision:
Click the plus button to add a new filter.
Left Dropdown: Select Plugin Family.
Right Dropdown: Choose Ubuntu Local Security Checks.


Click Preview Plugins again to refine the list.


Review Plugin Details:

Select the Ubuntu Local Security Checks plugin family from the dropdown.
Click on the plugin (e.g., Plugin ID 145463) for details, including affected Ubuntu versions and patch information.


Launch the Scan:

Click the arrow next to Save and select Launch.


Analyze Results:

After the scan completes, navigate to the Vulnerabilities tab.
Check for a HIGH severity finding confirming CVE-2021-3156.
Review the plugin output, which may note that Nessus detected the vulnerability based on version checks without attempting exploitation.



Advanced Tip: Combine multiple filters (e.g., CVE and Plugin Family) to reduce scan time and focus on specific vulnerabilities. Always verify critical findings manually, as Nessus may rely on version checks rather than active exploitation.

8. Best Practices and Considerations

Minimize Noise: Unauthenticated scans are noisy and may trigger intrusion detection systems. Authenticated scans create additional system logs and AV alerts. Always coordinate with system owners in production environments.
Optimize Scan Scope: Use specific port ranges and disable unnecessary features (e.g., Host Discovery) to reduce scan duration and impact.
Validate Findings: Nessus may report false positives, especially in unauthenticated scans. Manually verify critical vulnerabilities, particularly those requiring exploitation.
Stay Updated: Nessus plugins are frequently updated. Ensure your instance is connected to the internet for the latest plugin updates.
Secure Credentials: Protect credentials used in authenticated scans, as they are sensitive and could be targeted by attackers if mishandled.
Consult Documentation: Refer to Tenable’s documentation for advanced configuration options and troubleshooting.


9. Conclusion
Nessus is a versatile and powerful tool for vulnerability scanning, suitable for both beginners and advanced security researchers. By following this guide, you’ve learned how to:

Install and configure Nessus on Kali Linux.
Understand its core components, including policies, templates, and plugins.
Perform unauthenticated and authenticated scans.
Analyze results and generate reports.
Leverage dynamic plugin filters for targeted vulnerability detection.

For beginners, start with the Basic Network Scan template and gradually explore customizations. Advanced users can harness the Advanced Dynamic Scan and plugin filters to focus on specific vulnerabilities like CVE-2021-3156. As you gain experience, experiment with different templates and configurations to tailor scans to your environment.
Next Steps:

Practice in a lab environment, such as Offensive Security’s PEN-200 labs, to refine your skills.
Explore Nessus Professional for advanced features like compliance checks.
Stay informed about new vulnerabilities by monitoring Tenable’s plugin updates and CVE databases.

Vulnerability scanning is only one part of a comprehensive security assessment. Combine Nessus with manual testing and other tools to build a robust penetration testing workflow.
Disclaimer: Always obtain proper authorization before scanning systems in a production environment to avoid legal and ethical issues.
