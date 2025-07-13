# Runbook: Azure Sentinel SIEM & Incident Response

## 1. Onboarding a New Microservice

1. Enable diagnostic logging in Azure Monitor for the service.
2. Install and configure Azure Monitor Agent (AMA) to send logs to Sentinel's Log Analytics Workspace.
3. Tag the log data with the service name (using custom fields or log analytics tagging).
4. Validate log arrival in the workspace.
5. Clone baseline detection rules and dashboards for the service.

---

## 2. Incident Response Scenarios

### Scenario A: Data Exfiltration Detected

**Trigger:** Rule detects large outbound data transfer from storage account.

**Actions:**
- Logic App triggered.
- Slack alert sent to Security channel with logs.
- IP address blocked at Azure NSG or Firewall.
- Keys to the storage account rotated.
- Incident ticket created for investigation.

### Scenario B: Compromised API Key

**Trigger:** Rule detects abnormal use of service principal/API key.

**Actions:**
- Logic App sends alert with user info and timestamps.
- KeyVault secret or key is rotated automatically.
- Access permissions for service principal disabled.
- Team notified to review logs and revalidate access.

---

## 3. Tuning Rules Over Time

- Regularly review false positives and update rule thresholds.
- Use watchlists or allowlists to reduce noise.
- Monitor alert effectiveness using Sentinel Metrics.
- Update dashboards as new services are onboarded.

---

**Maintainer Note:** Ensure access to Slack, Logic App, KeyVault, and NSG automation permissions for automated actions to succeed.