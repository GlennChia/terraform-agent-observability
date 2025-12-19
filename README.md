# Terraform Agent Observability

This repository provides demo code on how to visualize Terraform agent telemetry. It includes Terraform code to deploy the agent pool, set the organization's default settings to use the agent pool. It also includes a [docker-compose.yml](./docker-compose.yml) to launch containers for the Agent, OTel collector, Prometheus, and Grafana. There is Terraform code for creating test workspaces to generate telemetry for visualization.

![dashboard cover](./docs/01-architecture/02-dashboard-cover.png)

Read the accompanying [Medium blog post](https://medium.com/hashicorp-engineering/hcp-terraform-agent-observability-with-opentelemetry-prometheus-grafana-and-jaeger-2de6eca1b319) or [Substack blog post](https://open.substack.com/pub/hashicorpengineering/p/hcp-terraform-agent-observability) for more details about the integration and additional screenshots.

# 1. Architecture

![architecture diagram](./docs/01-architecture/01-architecture-diagram.png)

# 2. Deployment

## 2.1 Agent pool and organization default settings

Step 1: Configure HCP Terraform credentials. Refer to the [tfe_provider authentication docs](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs#authentication) for the various token options and guidance. For example:

```bash
export TFE_TOKEN=example
```

Step 2: In [tf-agent](./tf-agent/) directory, run an apply, review the plan output, and approve the plan accordingly. The apply outputs the commands to run the Terraform agent. This includes the agent token.

> [!CAUTION]
> In a live environment it is not good practice to output the Terraform agent token. The token is output in this repo purely for demo purposes, such that readers can easily pass the token to the Terraform agent.

```bash
terraform init
terraform apply
```

## 2.2 Start the containers

Step 1: Run the following commands in the root directory to start up the containers (replace the agent token with the output from the previous step)

```bash
export TFC_AGENT_TOKEN=example
export TFC_AGENT_NAME=demo-agent-pool
docker compose up
```

# 3. Verify deployment

## 3.1 Terraform agent pool

Terraform agent pool created with an idle agent

![agent pool](./docs/02-deployment/01-tf-agent/01-agent-pool.png)

Terraform org settings default execution mode shows `Agent`

![org settings general default execution mode](./docs/02-deployment/01-tf-agent/02-org-settings-general-default-execution-mode.png)

## 3.2 Prometheus

Visit localhost:9090 and choose `Explore metrics`

![explore metrics](./docs/02-deployment/02-prometheus/01-explore-metrics.png)

View `tfc_agent` prefixed metrics

![tfc agent metrics](./docs/02-deployment/02-prometheus/02-tfc-agent-metrics.png)

## 3.3 Grafana

Visit localhost:3000 and login with

- Username: `admin`
- Password: `admin`

![login](./docs/02-deployment/03-grafana/01-login.png)

Initial `Terraform Agent Dashboard`. This is configured from [Metrics-Dashboard.json](./grafana/provisioning/dashboards/Metrics-Dashboard.json)

![dashboard initial](./docs/02-deployment/03-grafana/02-dashboard-initial.png)

## 3.4 Jaeger

Visit localhost:16686. There are no traces yet since there are no workspace runs.

![jaeger ui initial](./docs/02-deployment/04-jaeger/01-jaeger-ui-initial.png)

# 4. Testing

## 4.1 Create workspaces for testing

Step 1: In the [tf/test](./tf-test/) directory, copy [tf-test/terraform.tfvars.example](./tf-test/terraform.tfvars.example) to `terraform.tfvars` and change the environment variables accordingly. GitHub credentials can use a [personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens). This token needs sufficient permissions to create, delete repositories, and write files to the repository.

> [!CAUTION]
> In a live environment, it is not good practice to directly pass the GitHub token. Instead, sensitive credentials should be securely stored and accessed using solutions like HashiCorp Vault, which provides encrypted storage and access controls capabilities.

Step 3: In the [tf/test-auto-scaling](./tf/test-auto-scaling/) directory, run an apply, review the plan output, and approve the plan accordingly.

```bash
terraform init
terraform apply
```

## 4.2 GitHub repo created for testing

GitHub repository created with simple Terraform resources.

![github repo](./docs/03-testing/01-github/01-github-repo.png)

## 4.3 First workspace plan

Agent processes workspace runs one at a time. Agent is `Busy`

![agent busy](./docs/03-testing/02-first-workspace/01-agent-busy.png)

Dashboard shows data about the first run

![dashboard](./docs/03-testing/02-first-workspace/02-dashboard.png)

## 4.4 Workspaces applied

### 4.4.1 HCP TF view

All workspaces are eventually applied

![workspaces applied](./docs/03-testing/03-first-run/01-workspaces-applied.png)

Agent transitions to `Idle`

![agent idle](./docs/03-testing/03-first-run/02-agent-idle.png)

### 4.4.2 Grafana dashboard

Dashboard with metrics across all the workspace runs

![dashboard](./docs/03-testing/03-first-run/03-dashboard.png)

Zoomed in view for various dashboard sections - Job and workspace performance

![dashboard1](./docs/03-testing/03-first-run/04-dashboard1.png)

Resource utilization (Pool-wide)

![dashboard2](./docs/03-testing/03-first-run/05-dashboard2.png)

Runtime metrics (Pool-wide)

![dashboard3](./docs/03-testing/03-first-run/06-dashboard3.png)

Individual agent details

![dashboard4](./docs/03-testing/03-first-run/07-dashboard4.png)

### 4.4.3 Prometheus metrics

Some metrics are available during runs. For example

- tfc_agent_core_profiler_cpu_busy_percent
- tfc_agent_core_profiler_memory_used_percent

![agent metric during run](./docs/03-testing/04-prometheus-metrics/01-agent-metric-during-run.png)

`tfc_agent_core_profiler_memory_used_percent`

![agent memory](./docs/03-testing/04-prometheus-metrics/02-agent-memory.png)

`tfc_agent_core_profiler_cpu_busy_percent`

![agent cpu](./docs/03-testing/04-prometheus-metrics/03-agent-cpu.png)

### 4.4.4 Jaeger

Jaeger UI shows 10 traces. Each workspace has 2 traces - 1 for plan, and 1 for apply.

![jaeger ui traces](./docs/03-testing/05-jaeger-traces/01-jaeger-ui-traces.png)

Example of a plan trace

![plan overview](./docs/03-testing/05-jaeger-traces/02-plan-overview.png)

This can be drilled down to the span information

![plan span](./docs/03-testing/05-jaeger-traces/03-plan-span.png)

Example of an apply trace

![apply overview](./docs/03-testing/05-jaeger-traces/04-apply-overview.png)

This can be drilled down to the span information

![apply span](./docs/03-testing/05-jaeger-traces/05-apply-span.png)

# 5. Cleanup

Step 1: Run `docker compose down -v`

Step 2: In the [tf-test](./tf-test/) directory, run destroy. Review the destroy output before approving.

```bash
terraform destroy
```

Step 3: In the [tf-agent](./tf-agent/) directory, run destroy. Review the destroy output before approving.

```bash
terraform destroy
```
