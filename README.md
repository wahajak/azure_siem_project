# 🎥 Azure Sentinel SIEM Project – Full Walkthrough

> This step-by-step guide walks through deploying and testing a cloud-native SIEM & automated incident-response pipeline using **Azure Sentinel**.

---

## 📌 Prerequisites

| Tool/Account           | Description                        |
|------------------------|------------------------------------|
| ✅ Azure Subscription  | For deploying Sentinel & resources |
| ✅ Terraform CLI       | To deploy infra via IaC            |
| ✅ Azure CLI           | To authenticate & manage resources |
| ✅ GitHub              | For CI/CD integration              |

---

## 🎯 Goal

- Centralized logging from microservices
- Detection of suspicious behaviors
- Auto-response via Slack, IP block, key rotation
- CI/CD block if Sentinel finds active threats

---

## 🚀 Step 1: Deploy Azure Sentinel with Terraform

### 🔧 1. Clone or Unzip Project
```bash
cd azure-siem-project
```

### 🔧 2. Initialize Terraform
```bash
az login             # Login to Azure
terraform init       # Initialize Terraform
terraform plan       # Preview changes
terraform apply      # Apply resources
```

This sets up:
- Resource Group
- Log Analytics Workspace
- Azure Sentinel

✅ Confirm in Azure Portal → **Microsoft Sentinel**

---

## 🛠️ Step 2: Connect Logs from Microservices

### 👇 Options:
| Source           | Method                     |
|------------------|----------------------------|
| Azure VM         | Azure Monitor Agent (AMA)  |
| AKS (Kubernetes) | AMA + Data Collection Rule |
| App Logs         | Logstash → Azure Monitor   |

📘 [Tutorial – Connect logs](https://learn.microsoft.com/en-us/azure/sentinel/connect-data-sources)

---

## 🔍 Step 3: Configure Detection Rules

### 📌 Add KQL Rules:
Go to: **Microsoft Sentinel → Analytics → + Create**

Paste queries from `sentinel_detection_rules.kql`, e.g.:
```kql
SigninLogs
| where ResultType != 0
| summarize FailedAttempts = count() by bin(TimeGenerated, 10m), UserPrincipalName
| where FailedAttempts > 5
```

✅ Save & enable each rule.

---

## 🤖 Step 4: Automated Response with Logic App

### 🔧 1. Import Logic App
1. Go to **Sentinel → Automation → Create → Playbook**
2. Import `logic_app_playbook.json`
3. Authorize it to:
   - Post to Slack
   - Update NSG/Firewall
   - Rotate KeyVault secrets

### 🔁 Attach to Analytic Rule
Edit rule → Add automation → Choose your Logic App.

---

## 🔒 Step 5: CI/CD Integration (Optional)

### ✅ GitHub Actions:
Add `sentinel_ci_cd_check.yml` to:
```
.github/workflows/sentinel_check.yml
```

### 🔐 Add Repo Secrets:
```
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_TENANT_ID
LOG_ANALYTICS_WORKSPACE_ID
```

### 🔁 Test It:
```bash
git add .
git commit -m "Trigger CI"
git push
```

❌ If Sentinel sees active high alerts, deploy is blocked.

---

## 🧪 Step 6: Simulate Incidents

| Simulation                       | What Happens                           |
|----------------------------------|----------------------------------------|
| Multiple failed logins (fake)    | Triggers `SigninLogs` rule             |
| Add user to role in AAD          | Triggers `Privilege Escalation` rule   |
| Blob download from same IP       | Triggers `Large Data Transfer` rule    |

✅ Check:
- Sentinel → **Incidents**
- Slack alert received
- IP auto-blocked via NSG
- CI/CD failed due to alert

---

## 📋 Summary Report

- ✅ Logs centralized
- ✅ Detection rules working
- ✅ Automated response triggered
- ✅ CI/CD gate tested

📁 Included Files:
- Terraform: `azure_siem_pipeline.tf`
- Detection: `sentinel_detection_rules.kql`
- Response: `logic_app_playbook.json`
- CI/CD: `sentinel_ci_cd_check.yml`
- Docs: `sentinel_runbook.md` `README.md`