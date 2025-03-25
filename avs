# The 2016 Bangladesh Bank Heist: A Technical Analysis

The Bangladesh Bank heist was a meticulously executed cybercrime that resulted in the theft of $81 million, leveraging vulnerabilities in banking systems and the SWIFT payment network. This article delves into the technical aspects of the attack, exploring the methodologies, tools, and preventive measures.

---

# #01 Reconnaissance and Initial Compromise

## **Attack Vector: Spear Phishing**

- The attackers used spear-phishing emails to compromise employee devices. These emails contained malicious attachments masquerading as legitimate documents, likely in PDF or Excel formats.
- The malware embedded in these attachments executed scripts to establish an initial foothold.

## Technical Details of the Malware

- **Type:** Custom RAT (Remote Access Trojan)
- **Variants:** Likely custom variants of **Dridex** and **PlugX**.
- **Capabilities:**
  - Keylogging to capture credentials.
  - Network reconnaissance for SWIFT-connected devices.
  - Exfiltration of sensitive data such as network configurations and authentication details.
  - Remote command execution.

### Malware Delivery

- The attackers likely exploited vulnerabilities in document processing software (e.g., unpatched CVEs in Microsoft Office or Adobe Reader).
- Command-and-Control (C2) servers were hosted on compromised infrastructure in Eastern Europe to reduce attribution risk.

---

# #02 Network Infiltration and Lateral Movement

## Privilege Escalation

- Post-compromise, attackers leveraged unpatched systems and weak access controls to escalate privileges.
- Tools like **Mimikatz** were potentially used to dump credentials from memory.
- **Exploitation:** Targeted weak Windows Server configurations, exploiting vulnerabilities like **CVE-2014-6324**.

## Tactics for Lateral Movement

- **Network Scanning:** Tools such as Nmap or custom scripts helped map the internal network.
- **Protocol Exploitation:** The attackers exploited poorly segmented network design, gaining access to SWIFT-connected systems by pivoting through less critical servers.
- **Pass-the-Hash:** Enabled pivoting across the network.

## Persistence Mechanisms

- The attackers used registry keys and startup folder modifications to maintain persistence.
- Added malicious entries to `HKLM\Software\Microsoft\Windows\CurrentVersion\Run`.
- Created hidden **scheduled tasks** for malware reactivation.
- They also disabled certain security tools, likely using PowerShell scripts or WMIC commands.

---

# #03 Compromise of the SWIFT Payment System

The attackers specifically targeted the **SWIFT Alliance Access system**, used to initiate and manage financial transactions.

## Technical Exploitation

To conceal their tracks, the attackers tampered with SWIFT logs without compromising database integrity.

1. **Custom Malware Deployment:**
   - **Malware:** Custom-written malicious DLLs, such as `evtdiag.dll`, loaded into SWIFT software.
   - **Purpose:**
     - Hook APIs and alter transaction data.
     - Inject fraudulent transactions, intercept outgoing messages, and alter logs.
     - Retain database consistency by mirroring checksum calculations.
   - **Tools Used:**
     - Custom Python scripts for log injection.
     - Database utilities such as **DBANET** for table-specific edits.
2. **Indicators of Compromise:**
   - **File Modifications:** Unauthorized DLLs loaded into the SWIFT terminal's process space.
   - **Log Tampering Scripts:**
     - Likely custom Python or PowerShell scripts.
     - **Purpose:** Delete legitimate transaction logs and replace them with fabricated records.
3. **Manipulated Message Types:**
   - **MT103:** Customer transfer requests, which routed $81 million to intermediary accounts.
   - **MT202:** Bank-to-bank transfer messages, used to obscure transaction origins.
4. **Fields Altered:**
   - **Beneficiary Name:** Modified to match shell companies or Philippine casinos.
   - **Bank Identifier Codes (BICs):** Adjusted to direct payments through specific intermediary banks.

## Example of a Fraudulent SWIFT Message

- **Original:** `Beneficiary: Federal Reserve Bank of New York`
- **Modified:** `Beneficiary: Rizal Commercial Banking Corporation (RCBC), Philippines`

These precise alterations ensured that messages adhered to SWIFT syntax while evading scrutiny.

## Specific Banks and Transfers

- **Federal Reserve Bank of New York:** Targeted to authorize fraudulent requests.
- **Rizal Commercial Banking Corporation (RCBC), Philippines:** Served as the main recipient of the funds.
- **Pan Asia Bank, Sri Lanka:** Used to route part of the funds ($20 million).

---

# #04 Exploiting Time Zones and Holidays

The attackers carefully planned their SWIFT exploitation by leveraging time zone differences and operational off-hours. This sophisticated timing played a crucial role in the success of the heist.

## 1. Planning the Attack

- **Preparation Phase:** Months before February 2016, the attackers studied:
  - **Bangladesh Bank’s operational schedule:** Working hours of 9:00 AM–5:00 PM (BST).
  - **Federal Reserve Bank of New York’s processing window:** 24/7 for SWIFT transactions but primarily staffed during 9:00 AM–5:00 PM (EST).
  - **Intermediary banks’ schedules:** Weekend and off-hour staffing practices in the Philippines and Sri Lanka.

## 2. Launch of Fraudulent SWIFT Requests

- **Local Time in Bangladesh:** February 4, 2016, between **8:00 PM and 3:00 AM (BST)**.
  - During this time, Bangladesh Bank employees were off-duty, creating an optimal window for the attackers to execute undetected.
- **Federal Reserve Bank’s Time:** Corresponded to February 4, **9:00 AM–5:00 PM (EST)**, ensuring that fraudulent SWIFT messages were processed during their peak operational hours.

## 3. Exploiting Regional Holidays

- **Friday in Bangladesh (February 5):** A weekend holiday for the local bank. Staff shortages meant reduced scrutiny of internal transactions.
- **Thursday Night in the U.S. (February 4):** A regular business day for the Federal Reserve Bank of New York, ensuring seamless processing of fraudulent transactions.
- **Philippines Local Weekend (February 5–7):** Limited banking operations over the weekend delayed immediate detection and reporting.

---

# #05 Execution: Fund Transfers

## **Intermediary Bank and Casino Laundering**

- Funds routed to RCBC were withdrawn and converted into casino chips at **Solaire Resort and Casino** and **Midas Hotel and Casino** in Manila, Philippines.
- Since funds arrived during the local weekend (February 6–7), it facilitated immediate conversion into casino chips.
- Casino operations were not subject to the same reporting regulations as traditional banks, further complicating recovery efforts.
- Exploited limited banking oversight during off-hours to move a portion of the funds to Sri Lanka.
- Errors like misspelled names (e.g., “Fandation” instead of “Foundation”) should have triggered red flags but were ignored due to procedural lapses.

## Details of Fraudulent Transactions

- **Number of Requests:** 35 fraudulent SWIFT requests totaling $951 million.
- **Success Rate:** $81 million successfully transferred before detection.

---

# #06 Post-Transaction Exploitation and Cover-Up

## 1. Batch Processing Exploitation

The attackers targeted the SWIFT system's batch processing window:

- **Inclusion in Batches:** Fraudulent SWIFT messages were inserted into legitimate transaction batches.
- **Reconciliation Report Delays:** By deploying malware to delay the generation of reconciliation reports, they concealed discrepancies until after the transactions were processed.

## 2. Concealing Evidence

- **Log Tampering:**
  - Modified or deleted SWIFT transaction logs to hide unauthorized transfers.
  - Replaced legitimate logs with fabricated entries to avoid immediate detection.
- **Alert Suppression:**
  - Internal monitoring tools were disabled or manipulated to delay fraud detection alerts.

---

# #07 Detection and Response

## Discovery

- On **February 6, 2016**, Bangladesh Bank officials identified suspicious transactions during a routine manual reconciliation of SWIFT logs.

## Response Actions

1. **Notification:**
   - Alerted the Federal Reserve Bank of New York about the fraudulent transactions.
2. **Partial Recovery:**
   - Successfully recovered $20 million routed to Sri Lanka.
3. **Irrecoverable Funds:**
   - $81 million laundered through Philippine casinos was never recovered.

---

# #08 Attribution to Lazarus Group

## Key Evidence of Lazarus Group Involvement

The Lazarus Group's involvement was identified through a combination of forensic evidence and tradecraft analysis:

- **Code Reuse:** The malware contained multiple hardcoded C2 servers, cryptographic keys, and strings observed in prior Lazarus operations, such as the **Sony Pictures hack (2014)** and the **WannaCry ransomware (2017)**.
- **Shared Infrastructure:**
  - **Domain Patterns:** Registered domains exhibited patterns consistent with Lazarus campaigns, such as registrar details and similar DNS setups.
  - **IP Addresses:** Attacker IPs and C2 servers were traced to regions in North Korea known for state-sponsored activity.
- **Advanced Techniques:**
  - Use of custom-packed malware binaries to evade signature-based detection.
  - Time-delay tactics to trigger during off-hours and holidays, reducing immediate response likelihood.

## MITRE ATT&CK Techniques

- **T1059:** Command-line interface scripting for automation.
- **T1134:** Privilege escalation using token impersonation.
- **T1027:** Obfuscation of payloads to bypass antivirus.
- **T1071:** Application Layer Protocols exploited to communicate over encrypted C2 channels.
- **T1134:** Privilege escalation using token impersonation.

---

# #09 Attack Simulation Flow

A simplified flow illustrating the SWIFT exploitation:

![Drawing2.jpg](Drawing2.jpg)

---

# #10 Lessons Learned and Recommendations

## Identified Vulnerabilities

- **Weak Email Security:** Employees were susceptible to phishing.
- **Network Segmentation Failure:** Lack of isolation between critical and non-critical systems allowed lateral movement.
- **Insufficient Monitoring:** Real-time transaction anomaly detection was absent.

## Proactive Measures

The heist underscores the importance of proactive defense mechanisms in global financial systems:

1. **Adopt Zero Trust Architecture:**
   - Limit lateral movement through network segmentation.
   - Limit access to critical systems like SWIFT endpoints through role-based access control (RBAC).
   - Use continuous monitoring to detect anomalous access patterns.
2. **Secure SWIFT Infrastructure:**
   - Implement two-factor authentication (2FA) for all SWIFT terminals.
   - Regularly audit SWIFT logs with AI-based anomaly detection systems like **Darktrace** or **Splunk**.
3. **Incident Response Preparedness:**
   - Train staff to identify social engineering attempts.
   - Conduct red team exercises simulating attacks on payment systems.
4. **Advanced Threat Detection:**
   - Use threat intelligence to monitor indicators of compromise (IOCs).
   - Deploy endpoint detection and response (EDR) solutions on critical systems.

These measures ensure resilience against sophisticated attacks targeting financial institutions.

---

# #11 Timeline of the Heist

- **Initial Compromise (Months Before Heist):** Spear-phishing emails delivered malware to the bank's internal network.
- **Lateral Movement (Weeks Before):** Attackers accessed the SWIFT systems.
- **Execution (February 4–5, 2016):** Fraudulent SWIFT messages sent to the Federal Reserve.
- **Detection (February 6, 2016):** Manual log review uncovered the fraud.
- **Attribution (Months After):** Evidence linked the attack to the Lazarus Group.

---

# #12 Final Thoughts

The Bangladesh Bank heist showcased the vulnerabilities in global financial infrastructure and the ingenuity of state-sponsored threat actors.

---

# References

- [SWIFT Payment Systems](https://www.swift.com/)
- Public reports from **Kaspersky Lab**, **Symantec**, and **FireEye**.
- Incident timelines from the **Federal Reserve Bank of New York** and **Bangladesh Financial Intelligence Unit (BFIU)**.

---

# About the Author

Iftekhar Mahmud

- [LinkedIn](https://www.linkedin.com/in/iftekmahmud/)
- [GitHub](https://github.com/iftekmahmud)
- [YouTube](https://www.youtube.com/ArslanSecurity)

---
