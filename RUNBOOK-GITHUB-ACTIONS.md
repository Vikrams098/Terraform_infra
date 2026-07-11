CI/CD Flow: VSCode to GitHub Actions to AWS
=============================================

This is a plain step-by-step reference for an alternative to the Jenkins
flow, using GitHub Actions instead. GitHub Actions runs entirely inside
GitHub itself, so there is no separate server or webhook to maintain.

PART A: ONE-TIME SETUP

Step 1. Keep the same AWS backend resources as the Jenkins setup. The S3
bucket named terraform-infra-resources still stores the state files, one per
environment, and the DynamoDB table named infra_table still handles state
locking in the ap-south-1 region, with a partition key named LockID of type
String. Each environment's main.tf keeps pointing at this same bucket, key,
region, and table, exactly as it does today.

Step 2. Store AWS credentials as GitHub Actions secrets instead of Jenkins
credentials. In the repository settings, under Secrets and variables, then
Actions, add two repository secrets, one named AWS_ACCESS_KEY_ID and one
named AWS_SECRET_ACCESS_KEY, holding the same access key and secret that the
Aws_cred credential holds in Jenkins. These secrets are encrypted by GitHub
and only exposed inside workflow runs.

Step 3. Create a workflow file inside the repository at the path dot
github, workflows, and then a file such as terraform dot yml. This single
file replaces the Jenkinsfile. There is no separate job to configure through
a UI the way Jenkins requires, the workflow file itself is the job
definition, and it lives in version control alongside the rest of the code.

Step 4. Inside that workflow file, define triggers so it runs automatically
whenever a push happens to the dev branch or the main branch. Also add a
manual trigger option so the workflow can be started on demand with an input
parameter, similar to the DESTROY checkbox in Jenkins, letting you choose
between apply and destroy when starting a run by hand.

Step 5. No webhook needs to be configured at all. Because GitHub Actions
already lives inside GitHub, a push to the repository automatically triggers
the workflow with no external notification step required.

Step 6. For a production approval gate equivalent to the Jenkins Main
Approval step, create a GitHub Environment named something like production,
under the repository's Settings, Environments. Configure that environment to
require a reviewer's approval before any job targeting it can proceed. The
workflow's job for the main branch is then tied to that environment, so the
run pauses and waits for a person to approve it before continuing, the same
way Jenkins pauses at its input step.

PART B: DAY TO DAY FLOW, WHAT HAPPENS EVERY TIME YOU SHIP A CHANGE

Step 1. You edit Terraform files in VSCode, the same as before, usually
inside Modules or inside Environments, dev.

Step 2. You commit and push to GitHub, targeting dev or main.

Step 3. GitHub itself detects the push and starts the workflow run
automatically, with no webhook and no separate server involved.

Step 4. The workflow checks out the repository at the pushed commit, then
installs Terraform using a setup action.

Step 5. The workflow authenticates to AWS using the stored secrets, then
changes into the correct environment folder based on which branch triggered
the run.

Step 6. The workflow runs terraform init, then terraform validate, then
terraform plan, saving the plan output the same way Jenkins does, and the
DynamoDB table still provides locking exactly as before.

Step 7. On dev, the workflow proceeds straight to terraform apply. On main,
the job pauses because it is tied to the protected production environment,
and waits for a reviewer to click approve inside the GitHub Actions run page
before it continues to apply.

Step 8. Terraform contacts AWS in ap-south-1 and creates or updates the same
resources as before, such as the VPC, subnets, gateways, and the EC2
instance.

Step 9. The workflow's final steps clean up any temporary plan files, and
the run's overall pass or fail status shows up directly on the commit and on
the pull request if there is one, without needing a separate status check
integration the way Jenkins requires.

Step 10. To destroy resources, either add a manual workflow trigger with a
destroy option you select when starting the run, or maintain a second
workflow file dedicated to destroy. Either approach still respects the
production approval gate on main.

TROUBLESHOOTING NOTES

If AWS authentication fails inside a workflow run, it usually means the
secret names referenced in the workflow file do not match the secret names
actually stored in the repository settings.

If you see a DynamoDB lock error, it still means the infra_table table is
missing in ap-south-1, or the credentials point at the wrong AWS account,
exactly the same cause as in the Jenkins setup.

If a push does not start a run at all, check the Actions tab in the
repository to see whether the workflow file has a syntax error, since a
broken workflow file simply fails to register as a runnable workflow rather
than showing up as a failed build in the list.
