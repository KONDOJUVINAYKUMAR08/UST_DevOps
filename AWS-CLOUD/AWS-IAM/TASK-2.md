# AWS IAM Task 2— Access Key Rotation Automation

# Enterprise Hands-On Guide (DevOps / Cloud Security Focus)

---

# Lab Objective

This lab demonstrates how organizations automate:

* IAM access key rotation
* secure credential lifecycle management
* secrets storage
* temporary credential governance
* operational security automation

using:

* AWS IAM
* AWS Lambda
* AWS Secrets Manager
* AWS EventBridge

---

# REAL-WORLD SCENARIO

An organization has:

* CI/CD systems
* automation scripts
* legacy integrations

still using IAM access keys.

Security team policy requires:

```text
Rotate all IAM access keys every 30 days
```

Manually rotating keys is:

* error-prone
* insecure
* difficult to audit

So DevOps team builds:

```text
automated key rotation system
```

---

# MAIN CONCEPTS COVERED

| Concept                  | Purpose                        |
| ------------------------ | ------------------------------ |
| IAM Access Key Lifecycle | Secure credential management   |
| Lambda Automation        | Serverless security operations |
| Secrets Manager          | Secure secret storage          |
| EventBridge Scheduler    | Automated rotation             |
| Least Privilege IAM      | Secure automation role         |
| Access Key Rotation      | Compliance & security          |
| CloudWatch Logs          | Auditing and troubleshooting   |

---

# FINAL LAB ARCHITECTURE

```text
EventBridge Scheduler
        ↓
Lambda Function
        ↓
IAM APIs
        ↓
Create New Access Key
Disable Old Key
        ↓
Store New Key
        ↓
AWS Secrets Manager
```

---

# IMPORTANT ENTERPRISE LEARNING

Modern cloud systems SHOULD use:

* IAM Roles
* STS Temporary Credentials

instead of long-term access keys.

But many enterprises still have:

* legacy systems
* Jenkins servers
* external integrations
* third-party tools

using access keys.

This lab teaches:

```text
How enterprises safely manage unavoidable long-term credentials.
```

---

# ==========================================================

# STEP 1 — CREATE TEST IAM USER

# ==========================================================

Go to:

```text
IAM → Users → Create User
```

Create:

```text
rotation-test-user
```

Attach:

```text
AmazonS3ReadOnlyAccess
```

Create user.

---

# WHY THIS USER?

This simulates:

* CI/CD user
* automation account
* external integration

using access keys.

---

# ==========================================================

# STEP 2 — CREATE INITIAL ACCESS KEY

# ==========================================================

Open:

```text
rotation-test-user
```

Go to:

```text
Security Credentials
```

Click:

```text
Create Access Key
```

Choose:

```text
CLI
```

Download credentials CSV file.

---

# IMPORTANT LEARNING

IAM user can have:

```text
Maximum 2 active access keys
```

Rotation process works by:

1. creating new key
2. updating applications
3. disabling old key

---

# ==========================================================

# STEP 3 — CREATE SECRETS MANAGER SECRET

# ==========================================================

Go to:

```text
AWS Secrets Manager → Store new secret
```

Choose:

```text
Other type of secret
```

Add:

| Key        | Value                               |
| ---------- | ----------------------------------- |
| access_key | Original Access Key ID from CSV     |
| secret_key | Original Secret Access Key from CSV |

Secret Name:

```text
rotation-test-user-credentials
```

---

# IMPORTANT

Do NOT enable:

```text
Automatic Rotation
```

because this lab uses custom Lambda-based rotation.

Click:

```text
Next → Review → Store Secret
```

---

# IMPORTANT LEARNING

Secrets Manager:

* encrypts secrets
* integrates with KMS
* supports rotation workflows
* centralizes credential management

Applications should:

* retrieve credentials dynamically
* NEVER hardcode secrets
* NEVER store credentials in GitHub

---

# ==========================================================

# STEP 4 — CREATE LAMBDA EXECUTION ROLE

# ==========================================================

Go to:

```text
IAM → Roles → Create Role
```

Choose:

```text
AWS Service → Lambda
```

Attach:

```text
AWSLambdaBasicExecutionRole
```

Create role name:

```text
AccessKeyRotationLambdaRole
```

Create role.

---

# ==========================================================

# STEP 5 — ADD CUSTOM INLINE POLICY TO ROLE

# ==========================================================

Open role:

```text
AccessKeyRotationLambdaRole
```

Click:

```text
Add Permissions → Create Inline Policy
```

Choose:

```text
JSON
```

Paste:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessKeyManagement",
            "Effect": "Allow",
            "Action": [
                "iam:CreateAccessKey",
                "iam:ListAccessKeys",
                "iam:UpdateAccessKey",
                "iam:DeleteAccessKey"
            ],
            "Resource": "arn:aws:iam::*:user/rotation-test-user"
        },
        {
            "Sid": "AllowSecretsManagerUpdate",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:PutSecretValue",
                "secretsmanager:GetSecretValue",
                "secretsmanager:UpdateSecret"
            ],
            "Resource": "*"
        }
    ]
}
```

Policy Name:

```text
AccessKeyRotationPolicy
```

Create policy.

---

# EXPLANATION OF POLICY

---

# STATEMENT 1 — IAM Access Key Management

```json
"iam:CreateAccessKey"
```

Allows Lambda to create new access keys.

---

```json
"iam:ListAccessKeys"
```

Allows checking existing keys.

---

```json
"iam:UpdateAccessKey"
```

Allows disabling old keys.

---

```json
"iam:DeleteAccessKey"
```

Allows cleanup of old keys.

---

# WHY RESOURCE IS RESTRICTED?

```json
"arn:aws:iam::*:user/rotation-test-user"
```

Lambda can manage ONLY:

```text
rotation-test-user
```

This follows:

```text
Least Privilege Principle
```

---

# STATEMENT 2 — Secrets Manager Access

Allows Lambda to:

* read existing secret
* update new credentials
* store rotated keys securely

---

# ==========================================================

# STEP 6 — CREATE LAMBDA FUNCTION

# ==========================================================

Go to:

```text
Lambda → Create Function
```

Choose:

```text
Author from Scratch
```

Function Name:

```text
RotateAccessKeysFunction
```

Runtime:

```text
Python 3.12
```

Execution Role:

```text
Use Existing Role
```

Select:

```text
AccessKeyRotationLambdaRole
```

Create function.

---

# ==========================================================

# STEP 7 — ADD LAMBDA CODE

# ==========================================================

Replace existing code with:

```python
import boto3
import json

iam = boto3.client('iam')
secretsmanager = boto3.client('secretsmanager')

USERNAME = 'rotation-test-user'
SECRET_NAME = 'rotation-test-user-credentials'

def lambda_handler(event, context):

    existing_keys = iam.list_access_keys(UserName=USERNAME)['AccessKeyMetadata']

    if len(existing_keys) >= 2:
        oldest_key = sorted(existing_keys, key=lambda x: x['CreateDate'])[0]

        iam.update_access_key(
            UserName=USERNAME,
            AccessKeyId=oldest_key['AccessKeyId'],
            Status='Inactive'
        )

        iam.delete_access_key(
            UserName=USERNAME,
            AccessKeyId=oldest_key['AccessKeyId']
        )

    new_key = iam.create_access_key(UserName=USERNAME)['AccessKey']

    secret_payload = {
        "access_key": new_key['AccessKeyId'],
        "secret_key": new_key['SecretAccessKey']
    }

    secretsmanager.put_secret_value(
        SecretId=SECRET_NAME,
        SecretString=json.dumps(secret_payload)
    )

    return {
        'statusCode': 200,
        'body': 'Access key rotated successfully'
    }
```

Click:

```text
Deploy
```

---

# EXPLANATION OF CODE

---

# List Existing Keys

```python
iam.list_access_keys()
```

Checks current access keys.

---

# Delete Oldest Key

```python
iam.delete_access_key()
```

Removes old credentials when limit exceeds.

---

# Create New Key

```python
iam.create_access_key()
```

Generates fresh credentials.

---

# Store in Secrets Manager

```python
secretsmanager.put_secret_value()
```

Securely stores rotated credentials.

---

# IMPORTANT ENTERPRISE LEARNING

This implementation follows:

```text
Graceful Credential Rotation
```

meaning:

* new key created first
* applications can migrate safely
* old key deleted later

This avoids:

* CI/CD failures
* downtime
* application outages

---

# ==========================================================

# STEP 8 — TEST LAMBDA MANUALLY

# ==========================================================

Open:

```text
Lambda → RotateAccessKeysFunction
```

Click:

```text
Test
```

Create:

| Field      | Value        |
| ---------- | ------------ |
| Event Name | TestRotation |
| Event JSON | {}           |

Click:

```text
Save
```

Then click:

```text
Test
```

again.

---

# EXPECTED RESPONSE

```json
{
  "statusCode": 200,
  "body": "Access key rotated successfully"
}
```

---

# ==========================================================

# STEP 9 — VERIFY ROTATION

# ==========================================================

Go to:

```text
IAM → Users → rotation-test-user → Security Credentials
```

Depending on current key count:

* new key created
* old key may still remain active temporarily

This is expected behavior.

---

# WHY OLD KEY MAY STILL EXIST

AWS IAM allows:

```text
Maximum 2 access keys per IAM user
```

The original Lambda logic deletes old keys ONLY when:

* 2 keys already exist

This follows enterprise-safe:

```text
Graceful Rotation Strategy
```

---

# VERIFY SECRET UPDATE

Go to:

```text
Secrets Manager → rotation-test-user-credentials
```

Click:

```text
Retrieve Secret Value
```

Verify:

* updated access_key
* updated secret_key

---

# ==========================================================

# STEP 10 — VERIFY CLOUDWATCH LOGS

# ==========================================================

Go to:

```text
Lambda → Monitor → View CloudWatch Logs
```

Verify:

* successful execution
* IAM API calls
* troubleshooting logs

---

# ==========================================================

# STEP 11 — AUTOMATE USING EVENTBRIDGE

# ==========================================================

Go to:

```text
Amazon EventBridge → Rules → Create Rule
```

Rule Name:

```text
RotateAccessKeysSchedule
```

Choose:

```text
Schedule
```

Rate Expression:

```text
rate(30 days)
```

Target:

```text
RotateAccessKeysFunction
```

Create rule.

---

# IMPORTANT ENTERPRISE LEARNING

This creates:

```text
Fully automated credential rotation
```

used in:

* SOC2
* ISO27001
* enterprise governance
* security compliance

---

# ==========================================================

# IMPORTANT UPDATE — UNDERSTANDING ACCESS KEY ROTATION BEHAVIOR

# ==========================================================

During testing, an important IAM behavior was observed:

After Lambda execution:

* Secrets Manager updated successfully
* New access key created
* BUT old access key remained active

This is expected with the original logic.

---

# WHY THIS HAPPENS

AWS IAM allows:

```text
Maximum 2 active access keys per IAM user
```

Original Lambda logic:

```text
IF keys >= 2:
    delete oldest key
ELSE:
    create new key only
```

So if initially:

* only 1 key exists

then Lambda:

* creates second key
* keeps old key active

This is intentional enterprise-safe behavior.

---

# ENTERPRISE LEARNING — GRACEFUL ROTATION

Production systems usually:

1. Create new key
2. Update applications
3. Wait for migration
4. Disable old key
5. Delete old key

This prevents:

* outages
* CI/CD failures
* automation breakage

---

# ==========================================================

# OPTIONAL UPDATED LAMBDA IMPLEMENTATION (STRICT ROTATION)

# ==========================================================

The following alternative implementation performs:

```text
Immediate Rotation
```

Behavior:

1. Disable old keys
2. Delete old keys
3. Create one fresh key
4. Update Secrets Manager

This is better for:

* labs
* demos
* testing
* validation

---

# OPTIONAL UPDATED LAMBDA CODE

```python
import boto3
import json

iam = boto3.client('iam')
secretsmanager = boto3.client('secretsmanager')

USERNAME = 'rotation-test-user'
SECRET_NAME = 'rotation-test-user-credentials'

def lambda_handler(event, context):

    existing_keys = iam.list_access_keys(UserName=USERNAME)['AccessKeyMetadata']

    # Disable and delete all existing keys
    for key in existing_keys:

        iam.update_access_key(
            UserName=USERNAME,
            AccessKeyId=key['AccessKeyId'],
            Status='Inactive'
        )

        iam.delete_access_key(
            UserName=USERNAME,
            AccessKeyId=key['AccessKeyId']
        )

    # Create new access key
    new_key = iam.create_access_key(UserName=USERNAME)['AccessKey']

    # Prepare secret payload
    secret_payload = {
        "access_key": new_key['AccessKeyId'],
        "secret_key": new_key['SecretAccessKey']
    }

    # Update Secrets Manager
    secretsmanager.put_secret_value(
        SecretId=SECRET_NAME,
        SecretString=json.dumps(secret_payload)
    )

    return {
        'statusCode': 200,
        'body': 'Access key rotated successfully'
    }
```

---

# HOW UPDATED VERSION WORKS

| Step | Action                 |
| ---- | ---------------------- |
| 1    | List all keys          |
| 2    | Disable old keys       |
| 3    | Delete old keys        |
| 4    | Create fresh key       |
| 5    | Update Secrets Manager |

---

# EXPECTED RESULT WITH UPDATED CODE

After every Lambda execution:

| Validation                              | Result  |
| --------------------------------------- | ------- |
| Only one active access key exists       | SUCCESS |
| Old keys removed                        | SUCCESS |
| Secrets Manager updated                 | SUCCESS |
| Credential rotation visible immediately | SUCCESS |

---

# ==========================================================

# FINAL VALIDATION CHECKLIST

# ==========================================================

| Validation                          | Expected |
| ----------------------------------- | -------- |
| Lambda creates new access key       | SUCCESS  |
| Secret updated                      | SUCCESS  |
| EventBridge schedule created        | SUCCESS  |
| CloudWatch logs generated           | SUCCESS  |
| No hardcoded credentials            | SUCCESS  |
| Automated credential rotation works | SUCCESS  |

---

# ==========================================================

# SECURITY BEST PRACTICES LEARNED

# ==========================================================

| Best Practice                           | Why Important             |
| --------------------------------------- | ------------------------- |
| Rotate access keys                      | Reduce compromise window  |
| Use Secrets Manager                     | Secure secret storage     |
| Use least privilege                     | Minimize blast radius     |
| Automate rotation                       | Eliminate manual mistakes |
| Avoid hardcoded keys                    | Prevent secret leakage    |
| Use temporary credentials when possible | Strongest security model  |

---

# ==========================================================

# ENTERPRISE LEARNING OUTCOMES

# ==========================================================

After completing this lab, you now understand:

* IAM Access Key Lifecycle
* Automated Credential Rotation
* Graceful Credential Rotation
* Immediate Credential Rotation
* Lambda Security Automation
* Secrets Management
* Least Privilege IAM
* Security Compliance Automation
* Event-Driven Security Operations
* CloudWatch Auditing
* Enterprise Credential Governance
* Cloud-Native Security Automation
* Why AWS allows 2 access keys
* Production-safe secret migration strategy

These are advanced IAM and cloud security automation concepts heavily used in enterprise AWS environments.
