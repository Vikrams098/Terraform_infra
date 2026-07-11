# CI/CD Flow: VSCode → GitHub → Jenkins → AWS

End-to-end reference for how a Terraform change goes from your editor to real AWS resources.

## Overview

```
VSCode (edit .tf files)
   │  git commit + push
   ▼
GitHub (Vikrams098/Terraform_infra, branch dev/main)
   │  push event → webhook
   ▼
Jenkins (job: Terraform_resources_dev, driven by Jenkinsfile)
   │  terraform init/validate/plan/apply
   ▼
AWS (VPC, subnets, EC2, etc. in ap-south-1)
```

---

## Part A — One-time setup (already done on this project, kept here for reference)

### 1. AWS backend resources
Terraform state is stored remotely so Jenkins and any teammate share the same state.

- **S3 bucket**: `terraform-infra-resources` — stores `terraform.tfstate` per environment
  (key: `Environments/dev/terraform.tfstate`, `Environments/main/terraform.tfstate`)
- **DynamoDB table**: `infra_table` — used for state locking
  - Region: `ap-south-1`
  - Partition key: `LockID` (String)
  - Billing mode: Pay-per-request
  - Create with:
    ```
    aws dynamodb create-table \
      --table-name infra_table \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --billing-mode PAY_PER_REQUEST \
      --region ap-south-1
    ```

Configured in each environment's `main.tf`:
```hcl
backend "s3" {
  bucket         = "terraform-infra-resources"
  key            = "Environments/dev/terraform.tfstate"
  region         = "ap-south-1"
  dynamodb_table = "infra_table"
  encrypt        = true
}
```

### 2. Jenkins credentials
Manage Jenkins → Credentials → System → Global credentials:

| Credential ID  | Kind                                | Used for                          |
|----------------|--------------------------------------|------------------------------------|
| `github_cred`  | Username + Password / PAT           | Cloning the GitHub repo            |
| `Aws_cred`     | AWS Credentials (access key/secret) | `AmazonWebServicesCredentialsBinding` in Jenkinsfile, gives Terraform AWS access |

Both IDs must match **exactly** what's referenced in the `Jenkinsfile` (`credentialsId: '...'`).

### 3. Jenkins job
- Type: Pipeline job (or Multibranch Pipeline) named `Terraform_resources_dev`
- Pipeline definition: "Pipeline script from SCM" → Git → repo URL
  `https://github.com/Vikrams098/Terraform_infra.git`
- Script Path: `Jenkinsfile` (at repo root)
- Branches built: `dev` and `main` (the Jenkinsfile has `when { branch '...' }` guards for each)

### 4. GitHub webhook
GitHub repo → Settings → Webhooks → Add webhook:
- **Payload URL**: `http://<your-jenkins-host>/github-webhook/`
- **Content type**: `application/json`
- **Events**: "Just the push event"
- Requires Jenkins to be reachable from GitHub (public IP/domain, or a tunnel like ngrok for local Jenkins)
- In the Jenkins job config, enable "GitHub hook trigger for GITScm polling" under Build Triggers

---

## Part B — Day-to-day flow (what happens every time you ship a change)

1. **Edit Terraform code in VSCode**
   - Modules: [Modules/vpc](Modules/vpc), [Modules/ec2](Modules/ec2)
   - Environment config: [Environments/dev](Environments/dev) (variables, tfvars, main.tf)

2. **Commit and push**
   ```
   git add <files>
   git commit -m "describe the change"
   git push origin dev
   ```

3. **GitHub fires the webhook** to Jenkins the instant the push lands on `dev` or `main`.

4. **Jenkins starts the job** automatically (`Terraform_resources_dev`):
   - `Checkout` — clones the repo at the pushed commit
   - `Dev: Init` — `terraform init -reconfigure` in `Environments/dev` (configures S3 backend)
   - `Dev: Validate` — `terraform validate`
   - `Dev: Plan` — `terraform plan -out=tfplan` (acquires the DynamoDB lock)
   - `Dev: Apply` — `terraform apply -auto-approve tfplan` (skipped if `DESTROY` param is checked)
   - Same pattern for `main`, but Apply requires a manual **`Main: Approval`** input step first (production gate)

5. **Terraform creates/updates AWS resources** — VPC, subnets, IGW, NAT gateway, route tables (`Modules/vpc`), EC2 instance + security group (`Modules/ec2`) — in `ap-south-1`.

6. **Pipeline post-actions** clean up the local `tfplan` file and report success/failure back to GitHub (commit status check).

### Destroying resources
Trigger the job manually with the `DESTROY` boolean parameter checked:
- `dev` branch → destroys immediately after a confirmation `input` step
- `main` branch → same, with its own confirmation step

---

## Quick troubleshooting checklist
- **`Could not find credentials entry with ID '...'`** → credential ID in Jenkinsfile doesn't match Jenkins' Credentials store.
- **DynamoDB `ResourceNotFoundException` during plan** → `infra_table` doesn't exist yet in `ap-south-1`, or wrong AWS account — verify with `aws dynamodb describe-table --table-name infra_table --region ap-south-1`.
- **Stages "skipped due to earlier failure(s)"** → look at the *first* failed stage in the log; everything after it is a knock-on effect, not a separate bug.
- **Webhook not triggering Jenkins** → check GitHub webhook "Recent Deliveries" tab for the response code; confirm Jenkins is reachable from the internet and the job has "GitHub hook trigger" enabled.
