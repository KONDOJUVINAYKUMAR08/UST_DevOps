# AWS IAM Task 1— Permission Boundaries for Developers

# Final Enterprise-Grade Hands-On Guide

---

# Lab Objective

This lab demonstrates how organizations safely allow developers to:

* Create IAM roles
* Launch EC2 workloads
* Use automation securely

WITHOUT allowing:

* privilege escalation
* unrestricted IAM administration
* passing sensitive existing roles
* modifying trust relationships

This is one of the most important IAM governance patterns used in enterprise AWS environments.

---

# Real-World Scenario

A Platform Engineering team wants developers to:

* create workloads independently
* use IAM roles for applications
* deploy infrastructure faster

BUT security teams must ensure:

* developers cannot gain admin access
* existing production roles cannot be abused
* IAM permissions remain controlled
* workload access is auditable

---

# IAM Concepts Covered

| Concept                         | Purpose                            |
| ------------------------------- | ---------------------------------- |
| Permission Boundaries           | Define maximum allowed permissions |
| Least Privilege                 | Restrict excessive access          |
| iam:PassRole                    | Secure workload role delegation    |
| IAM Conditions                  | Governance enforcement             |
| Instance Profiles               | EC2 IAM integration                |
| STS                             | Temporary credential generation    |
| Trust Policies                  | Define who can assume role         |
| Privilege Escalation Prevention | Enterprise IAM security            |

---

# HOW AWS EVALUATES PERMISSIONS

AWS calculates permissions like this:

```text id="f1"
Effective Permissions =
Identity Policies
INTERSECTED WITH
Permission Boundary
```

Meaning:

Even if:

```text id="f2"
AdministratorAccess
```

is attached,

the Permission Boundary still limits the maximum permissions.

---

# LAB ARCHITECTURE

```text id="f3"
developer-user
      ↓
Creates IAM Roles
      ↓
Roles MUST use Permission Boundary
      ↓
Only DevBoundary-* roles allowed
      ↓
EC2 uses Instance Profile
      ↓
STS issues temporary credentials
      ↓
Boundary restricts permissions
```

---

# ==========================================================

# STEP 1 — CREATE PERMISSION BOUNDARY POLICY

# ==========================================================

Go to:

```text id="f4"
IAM → Policies → Create Policy
```

Choose:

```text id="f5"
JSON
```

Paste:

```json id="f6"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowBasicServices",
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "ec2:Describe*",
                "cloudwatch:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "DenyIAMModification",
            "Effect": "Deny",
            "Action": [
                "iam:*"
            ],
            "Resource": "*"
        }
    ]
}
```

Policy Name:

```text id="f7"
DeveloperBoundaryPolicy
```

Click:

```text id="f8"
Create Policy
```

---

# EXPLANATION OF DeveloperBoundaryPolicy

---

## JSON VERSION

```json id="f9"
"Version": "2012-10-17"
```

Defines IAM policy language version.

---

# STATEMENT 1

```json id="f10"
{
    "Sid": "AllowBasicServices",
    "Effect": "Allow",
```

This statement ALLOWS safe non-IAM services.

---

## WHY ALLOW THESE SERVICES?

### S3

```json id="f11"
"s3:*"
```

Allows:

* bucket listing
* object upload/download
* S3 operations

Used for testing workload permissions.

---

### EC2 Describe APIs

```json id="f12"
"ec2:Describe*"
```

Allows:

* viewing instances
* viewing volumes
* networking
* AMIs
* security groups

Without this:
AWS Console throws many errors.

---

### CloudWatch

```json id="f13"
"cloudwatch:*"
```

Allows:

* metrics
* logs
* monitoring operations

Useful for automation testing.

---

# WHY Resource = "*"

```json id="f14"
"Resource": "*"
```

Some AWS APIs:

* do not support resource-level permissions
* especially Describe APIs

This is common in AWS IAM.

---

# STATEMENT 2

```json id="f15"
{
    "Sid": "DenyIAMModification",
    "Effect": "Deny",
    "Action": [
        "iam:*"
    ]
}
```

This is the MOST IMPORTANT part.

It explicitly denies:

* creating users
* modifying policies
* changing roles
* editing trust policies
* privilege escalation

---

# IMPORTANT LEARNING

Explicit DENY always wins in AWS IAM evaluation.

Even if:

```text id="f16"
AdministratorAccess
```

is attached,
IAM actions are still denied.

---

# ==========================================================

# STEP 2 — CREATE FINAL DEVELOPER POLICY

# ==========================================================

Go to:

```text id="f17"
IAM → Policies → Create Policy
```

Replace:

```text id="f18"
ACCOUNT_ID
```

with your AWS account ID.

Paste:

```json id="f19"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCreateRoleWithBoundary",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:PutRolePolicy",
                "iam:AttachRolePolicy",
                "iam:PutRolePermissionsBoundary"
            ],
            "Resource": "arn:aws:iam::ACCOUNT_ID:role/DevBoundary-*",
            "Condition": {
                "StringEquals": {
                    "iam:PermissionsBoundary": "arn:aws:iam::ACCOUNT_ID:policy/DeveloperBoundaryPolicy"
                }
            }
        },
        {
            "Sid": "AllowPassRoleToEC2Only",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::ACCOUNT_ID:role/DevBoundary-*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "ec2.amazonaws.com"
                }
            }
        },
        {
            "Sid": "AllowInstanceProfileManagement",
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:ListInstanceProfiles",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowReadOnlyIAMForConsole",
            "Effect": "Allow",
            "Action": [
                "iam:ListPolicies",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListRoles",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:ListRolePolicies",
                "iam:GetRolePolicy",
                "iam:ListEntitiesForPolicy",
                "iam:ListInstanceProfiles",
                "iam:ListPolicyVersions",
                "iam:GetInstanceProfile"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowEC2ForLabTesting",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:RebootInstances",
                "ec2:CreateTags",

                "ec2:Describe*",

                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",

                "ec2-instance-connect:SendSSHPublicKey"
            ],
            "Resource": "*"
        }
    ]
}
```

Policy Name:

```text id="f20"
DeveloperPolicy
```

Create policy.

---

# EXPLANATION OF DeveloperPolicy

---

# STATEMENT 1 — AllowCreateRoleWithBoundary

```json id="f21"
"iam:CreateRole"
```

Allows developer-user to create IAM roles.

---

## WHY Restrict Role Names?

```json id="f22"
"Resource": "arn:aws:iam::ACCOUNT_ID:role/DevBoundary-*"
```

Allows ONLY roles starting with:

```text id="f23"
DevBoundary-
```

This prevents abuse of:

* existing admin roles
* production roles
* organization roles

This is enterprise governance using naming conventions.

---

## WHY iam:PermissionsBoundary CONDITION?

```json id="f24"
"iam:PermissionsBoundary"
```

Forces developers to attach:

```text id="f25"
DeveloperBoundaryPolicy
```

during role creation.

Without boundary:
role creation fails.

---

# IMPORTANT LEARNING

This prevents privilege escalation.

Without this restriction:

```text id="f26"
developer-user
→ creates admin role
→ launches EC2
→ gains full AWS access
```

---

# STATEMENT 2 — AllowPassRoleToEC2Only

```json id="f27"
"iam:PassRole"
```

Allows passing IAM roles to AWS services.

---

# WHY IS PassRole DANGEROUS?

Because workloads receive AWS credentials.

Without restriction:
developers could attach powerful admin roles to workloads.

---

# WHY Restrict to DevBoundary-* Roles?

```json id="f28"
"arn:aws:iam::ACCOUNT_ID:role/DevBoundary-*"
```

Prevents attaching:

* organization admin roles
* EKS node roles
* production application roles

---

# WHY iam:PassedToService?

```json id="f29"
"iam:PassedToService": "ec2.amazonaws.com"
```

Allows roles to be passed ONLY to EC2.

NOT:

* Lambda
* ECS
* Glue
* CloudFormation

This is important enterprise hardening.

---

# STATEMENT 3 — Instance Profile Management

EC2 cannot directly use IAM roles.

AWS internally creates:

```text id="f30"
Instance Profile
```

This section allows:

* creating instance profiles
* attaching roles to instance profiles
* managing profile mappings

Without this:
EC2 role attachment fails.

---

# STATEMENT 4 — Read-Only IAM APIs

AWS Console internally calls many:

* List APIs
* Get APIs

Without these permissions:
console pages show Access Denied errors.

These are READ-ONLY permissions.

---

# STATEMENT 5 — EC2 Permissions

Allows:

* launching EC2
* stopping/starting instances
* viewing networking
* viewing volumes
* security group management
* EC2 Instance Connect

---

# WHY ec2:Describe* IS IMPORTANT

AWS Console internally calls MANY Describe APIs.

Without this:
you get console errors like:

* DescribeVolumes denied
* DescribeSubnets denied
* DescribeNetworkInterfaces denied

---

# WHY ec2-instance-connect Permission?

```json id="f31"
"ec2-instance-connect:SendSSHPublicKey"
```

Allows browser-based EC2 Instance Connect access.

Without this:
EC2 Connect fails.

---

# ==========================================================

# STEP 3 — CREATE IAM USER

# ==========================================================

Go to:

```text id="f32"
IAM → Users → Create User
```

Create:

```text id="f33"
developer-user
```

Attach:

```text id="f34"
DeveloperPolicy
```

DO NOT attach:

```text id="f35"
AdministratorAccess
```

Create user.

---

# IMPORTANT LEARNING

developer-user is NOT admin.

It only has:

* controlled IAM permissions
* controlled EC2 permissions
* secure role delegation

This follows:

```text id="f36"
Least Privilege Principle
```

---

# ==========================================================

# STEP 4 — LOGIN AS developer-user

# ==========================================================

Logout from admin account.

Login using:

```text id="f37"
developer-user
```

---

# ==========================================================

# STEP 5 — TEST FAILURE WITHOUT BOUNDARY

# ==========================================================

Try creating role WITHOUT boundary.

Expected:

```text id="f38"
ACCESS DENIED
```

---

# IMPORTANT LEARNING

This proves:

```text id="f39"
Boundary enforcement works.
```

---

# ==========================================================

# STEP 6 — CREATE ROLE WITH BOUNDARY

# ==========================================================

Go to:

```text id="f40"
IAM → Roles → Create Role
```

Choose:

```text id="f41"
AWS Service → EC2
```

Attach:

```text id="f42"
AdministratorAccess
```

Expand:

```text id="f43"
Set permissions boundary
```

Choose:

```text id="f44"
DeveloperBoundaryPolicy
```

Role Name:

```text id="f45"
DevBoundary-EC2Role
```

Create role.

---

# IMPORTANT LEARNING

Even though:

```text id="f46"
AdministratorAccess
```

is attached,

boundary still blocks:

```text id="f47"
iam:*
```

---

# ==========================================================

# STEP 7 — LAUNCH EC2 INSTANCE

# ==========================================================

Go to:

```text id="f48"
EC2 → Launch Instance
```

Choose:

```text id="f49"
Ubuntu Server 24.04 LTS
```

Instance Type:

```text id="f50"
t2.micro
```

Under:

```text id="f51"
Advanced Details → IAM Instance Profile
```

Select:

```text id="f52"
DevBoundary-EC2Role
```

Launch instance.

---

# ==========================================================

# STEP 8 — CONNECT TO EC2

# ==========================================================

Use:

```text id="f53"
EC2 Instance Connect
```

Connection should work successfully.

---

# ==========================================================

# STEP 9 — VERIFY ASSUMED ROLE

# ==========================================================

Inside EC2 run:

```bash id="f54"
sudo apt update
sudo apt install awscli -y

check:
aws --version
then 
aws sts get-caller-identity


excpected output:
{
  "UserId": "...",
  "Account": "...",
  "Arn": "arn:aws:sts::ACCOUNT_ID:assumed-role/ROLE_NAME/i-xxxxx"
}
```

Expected:

```text id="f55"
AssumedRole/DevBoundary-EC2Role
```

---

# IMPORTANT LEARNING

EC2 now uses:

```text id="f56"
temporary STS credentials
```

NOT:

* hardcoded keys
* stored passwords

---

# ==========================================================

# STEP 10 — TEST DENIED IAM OPERATION

# ==========================================================

Run:

```bash id="f57"
aws iam create-user --user-name test-user
```

Expected:

```text id="f58"
AccessDenied
```

---

# WHY?

Because boundary explicitly denies:

```json id="f59"
"iam:*"
```

---

# ==========================================================

# STEP 11 — TEST ALLOWED OPERATIONS

# ==========================================================

## S3

```bash id="f60"
aws s3 ls
```

Expected:

```text id="f61"
SUCCESS
```

---

## CloudWatch

```bash id="f62"
aws cloudwatch list-metrics
```

Expected:

```text id="f63"
SUCCESS
```

---

# FINAL VALIDATION CHECKLIST

| Validation                            | Expected |
| ------------------------------------- | -------- |
| Create role without boundary          | FAIL     |
| Create role with boundary             | SUCCESS  |
| Only DevBoundary-* roles manageable   | SUCCESS  |
| Existing admin roles cannot be passed | SUCCESS  |
| Launch Ubuntu EC2                     | SUCCESS  |
| EC2 Instance Connect works            | SUCCESS  |
| IAM operations denied inside EC2      | SUCCESS  |
| S3 access works                       | SUCCESS  |
| CloudWatch access works               | SUCCESS  |

---

# FINAL ENTERPRISE LEARNING

After completing this lab, you now understand:

* Permission Boundaries
* IAM Evaluation Logic
* Least Privilege IAM
* Secure Delegated Administration
* iam:PassRole
* IAM Conditions
* STS Temporary Credentials
* Instance Profiles
* Trust Policies
* EC2 IAM Architecture
* Privilege Escalation Prevention
* Enterprise AWS IAM Governance

These are advanced production IAM concepts heavily used in secure cloud environments built on Amazon Web Services.
