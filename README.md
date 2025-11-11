# Spacelift configuration

## Step 1 – Set up GitHub integration (VCS)
[Spacelift doc](https://docs.spacelift.io/integrations/source-control/github)

1. In Spacelift UI, go to **Settings → Integrations → VCS** and add a GitHub integration. 
2. Spacelift walks you through creating a GitHub App:
    - Give it a name (e.g. spacelift-ealebed).
    - Note the **webhook URL** and **secret** Spacelift generates.
    - In GitHub, configure the App with that webhook + secret.
3. Install the GitHub App on your org (or specific repo with the Terraform code).
4. Make sure the App has:
    - **Read** access to Administration, Checks, Commit statuses, Contents, Deployments, Issues, Metadata (mandatory), Pull requests.
    - **Write** access to Checks, Commit statuses, Deployments, Pull requests (to update PRs).

Result: Spacelift can now:
    - Watch your repo for pushes and PRs,
    - Run plans,
    - Report back to PRs using GitHub Checks and/or comments.

## Step 2 – Set up AWS integration for Spacelift
[Spacelift doc](https://docs.spacelift.io/getting-started/integrate-cloud/AWS)

1. In AWS, create an IAM Role (e.g. `spacelift-dev-role`) with:
    - Trust policy allowing Spacelift’s AWS account and external ID to assume it (Spacelift doc shows exact JSON). 
    - Permissions to:
        - Manage resources for that env (EC2, S3, etc).
2. Repeat for PROD (e.g. `spacelift-prod-role`) or give single role access to both if you want.
3. In Spacelift, go to **Settings → Integrations → Cloud providers → AWS** and:
    - Create an AWS Integration, pointing at each role’s ARN. 

Later, in each stack, you’ll **attach the proper AWS integration** (dev stack → dev role, prod stack → prod role).

## Step 3 – Create DEV stack (plan + auto-apply after merge)

This stack will handle:
    - **Proposed runs** (speculative plan) on PRs,
    - **Tracked runs** (real plan + apply) on `master` after merge.

1. In Spacelift, go to **Stacks → Create stack**.
2. Fill basic info:
    - Name: `terraform-dev` (or `aws-infra-dev`).
    - Space: choose appropriate space.
    - Type: Terraform (or OpenTofu).
    - Repository: your GitHub monorepo.
    - Branch (tracked): `master` (your default branch).
    - Project root (working directory): `terraform/envs/dev`.
    - Additional project globs: `terraform/modules/`.
    - Terraform version: `1.5.7` (or newer in case OpenTofu).
3. Attach AWS Integration:
    - Under Cloud Integrations, attach the `spacelift-dev-role` integration.
4. Configure run behaviour:
    - Enable autodeploy / auto-apply for tracked runs (so after a green plan on `master`, it applies automatically in DEV).
    - Ensure PR integrations are enabled:
        - Spacelift will create proposed runs on PR branches and post status back. [Proposed runs are plan-only and never apply](https://docs.spacelift.io/concepts/run/proposed). 
5. Save the stack.

Now behaviour is:
- Push to feature branch with TF change:
    - Spacelift creates a Proposed run (speculative plan) for `terraform-dev`.
    - Plan result is sent to GitHub PR as a Check / status and linked from the PR.
- After PR merge to `master`:
    - Spacelift creates a Tracked run on `terraform-dev`.
    - It runs plan + apply automatically (DEV auto-deploy).

## Step 5 – Create PROD stack (plan + manual apply, triggered by DEV)

Now create `terraform-prod` stack and wire it to depend on DEV.

1. Create stack:
    - Name: `terraform-prod`.
    - Repo: same GitHub repo.
    - Tracked branch: `master`.
    - Working directory: `terraform/envs/prod`.
    - Terraform version: `1.5.7`.
2. Attach AWS Integration: `spacelift-prod-role` (with access to S3 prod backend).
3. Configure run behaviour (disable autodeploy):
    - Make sure auto-apply is OFF for this stack (you want manual approval).
4. Set **DEV → PROD** dependency:
    - Open the `terraform-prod` stack → Dependencies tab. 
    - Add dependency: `terraform-prod` depends on `terraform-dev`.

This means:
When a tracked run of `terraform-dev` (on `master`) completes successfully, Spacelift will enqueue a tracked run on `terraform-prod`.

5. Add manual approval for PROD:
You have two options:

- Simple mode (no policy at first):
    - Keep auto-apply off.
    - When a tracked run is created for PROD (triggered by DEV), it will:
        - Run the plan,
        - Wait in “unconfirmed” state.
    - A human with write access to the stack goes into Spacelift UI → opens the run → clicks **Confirm & Apply**.

- Strict mode (Approval Policy):
    - Create an Approval policy in Spacelift (**Policy → New policy → Type: APPROVAL**). 
[Spacelift doc](https://docs.spacelift.io/concepts/policy/approval-policy)
    - Use an example like “require 1 approval from specific usernames / team”.
    - Attach this policy to the `terraform-prod` stack.
    - Now PROD runs will literally wait for a specific approver (person or group) to approve in Spacelift’s “Review” UI before proceeding.

Result:
- PR → proposed runs for both stacks (DEV + PROD) → show plans in PR.
- Merge to master:
    - DEV tracked run → auto apply.
    - When DEV finishes OK, PROD tracked run starts (due to dependency).
    - PROD waits for manual approval (UI confirm and/or Approval policy).

## Migrate terraform state: S3 → Spacelift
1. Download current DEV state from S3
```bash
aws s3 cp s3://tf-state-531438381462-eu-west-1-dev/spacelift-test/dev/terraform.tfstate ./dev-terraform.tfstate
```
(adjust key path to match your backend config). Keep `dev-terraform.tfstate` safe.

2. Remove S3 backend from DEV code
In respective location (e.g. `terraform/envs/dev/backend.tf`) either delete the file, or comment out the backend "s3" block so that Terraform has no remote backend specified for DEV.

3. Recreate or edit DEV stack to import state
- In Spacelift, go to the `terraform-dev` stack.
    - If you already created it, you can import state via the State tab.
    - If you want to start clean, you can delete and recreate the stack and use “Import existing state file” during creation.
- On the State / creation screen:
    - Choose Import existing Terraform state file.
    - Upload `dev-terraform.tfstate` you downloaded.
- Save/update the stack.

Spacelift will now use that imported state as the dev stack’s state

3. Repeat steps for the PROD terraform state.

## Running terraform plan locally using Spacelift’s backend
If you move terraform state to Spacelift-managed state (no backend "s3" block, state imported into the stack), then:
- There is no “spacelift backend” you can directly put in backend.tf.
- Local `terraform plan` will default to a local state file, not the Spacelift one.
- You can’t make terraform CLI talk directly to Spacelift like it does to S3.

Instead, Spacelift gives you a feature called Local Preview via [`spacectl`](https://docs.spacelift.io/concepts/spacectl).

> “Run a plan with my local code against the stack’s remote state and environment, but stream the output to my terminal.”

### Using Local Preview
1. Enable Local Preview on the stack

In Spacelift UI:
- Go to your stack (e.g. `terraform-dev`).
- Open Stack Settings.
- Find Enable local preview and turn it on. 

⚠️ Note: This allows anyone with write access to the stack to trigger plans with arbitrary local code against that stack’s credentials and state – which is your requirement, but just be aware of the security implications.

2. Install `spacectl` locally
- Download `spacectl` from the releases page or via package manager.
- Configure authentication (usually Spacelift API key or SSO).
[Spacelift doc](https://docs.spacelift.io/concepts/spacectl#installation)

3. Run local preview
From your local repo:
```bash
cd terraform/envs/dev

spacectl stack local-preview --id <STACK_ID>
```

Where `<STACK_ID>` is the identifier of your Spacelift stack (visible in the UI / URL).

What happens:
- `spacectl` uploads your local directory content as a temporary workspace.
- Spacelift starts a proposed run using:
    - The stack’s remote state (Spacelift backend).
    - The stack’s environment variables, AWS integration, policies, etc.
- Output is streamed back to your terminal as if you ran terraform plan.

