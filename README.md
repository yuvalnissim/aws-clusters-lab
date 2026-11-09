# AWS Private EKS Clusters Lab

A hands-on lab demonstrating two EKS clusters with private
Kubernetes API endpoints, private worker nodes, and different
application exposure models.

## Architecture

- AWS Region: eu-north-1.
- One VPC: 10.20.0.0/16.
- Two public and two private subnets across two Availability Zones.
- Internet Gateway for public subnet routing.
- One NAT Gateway for outbound internet access from private subnets.
- One private EC2 instance running a self-hosted GitHub Actions runner.
- Two EKS clusters:
  - aws-clusters-lab-internal
  - aws-clusters-lab-public
- Each cluster has two t3.small worker nodes in private subnets.
- Both Kubernetes API endpoints are private.
- Each demo application runs two replicas, spread across worker nodes.

## Application access

### Internal application

Runner → internal ALB → application Pods.

The ALB accepts HTTP traffic from the runner security group.
Access succeeded from the runner and timed out from the external
Windows workstation.

### Public application

Internet client → internet-facing ALB → private application Pods.

The NGINX page loaded in a browser and returned HTTP 200
from the external Windows workstation.

Public access to the application does not expose the Kubernetes API
or give worker nodes public IP addresses.

## Deployment

Application manifests are stored under:

- k8s/internal/demo.yml
- k8s/public/demo.yml

Manual GitHub Actions workflows deploy each application:

- .github/workflows/deploy-internal.yml
- .github/workflows/deploy-public.yml

The workflows use a self-hosted runner inside the VPC.
The runner reaches GitHub through outbound connections via NAT
and reaches the Kubernetes APIs through private VPC networking.

Terraform infrastructure changes were applied from the local
Windows workstation. Terraform state is currently stored locally
and is excluded from Git.

## Identity and permissions

- The runner uses an EC2 IAM role and temporary AWS credentials.
- EKS Access Entries grant cluster visibility and application editing
  within the default namespace.
- AWS Load Balancer Controllers use EKS Pod Identity and dedicated
  IAM roles restricted by cluster, namespace, and service account.
- Temporary cluster administrator access was used for controller
  installation and removed afterward.

Creating an IAM OIDC provider was denied by an organization SCP.
EKS Pod Identity was used as the supported alternative.

## Manually installed components

The runner tools and GitHub runner service were installed manually.

AWS Load Balancer Controller was installed with Helm in each cluster:

- Helm: 4.3.1
- Chart: eks/aws-load-balancer-controller
- Chart version: 3.6.2
- Namespace: kube-system
- Service account: aws-load-balancer-controller
- Two controller replicas per cluster
- Explicit region and VPC settings

These manual installation steps are not yet fully automated.

## Validation completed

- GitHub Actions runner verification succeeded.
- Both application deployment workflows succeeded.
- System Pods and application Pods reached Running/Ready.
- Application replicas ran on different worker nodes.
- Internal application returned HTTP 200 from the runner.
- Internal application was unreachable from the external workstation.
- Public application returned HTTP 200 from the external workstation.
- Temporary cluster administrator access was removed.

## Lab limitations

- Demo HTTP traffic is not encrypted with TLS.
- Both clusters share a VPC, subnets, and a single NAT Gateway.
- Separate clusters do not establish complete network isolation.
- The single NAT Gateway is a shared dependency.
- Terraform state is local.
- Monitoring, backup, and production hardening are outside this lab.
- Some installation steps are manual.

## Cleanup order

1. Remove both application Ingress resources while the controllers,
   worker nodes, and their IAM permissions are still available.
2. Wait for the controllers to delete the ALBs and associated resources.
3. Review a Terraform destroy plan.
4. Destroy the Terraform-managed lab infrastructure.
5. Remove the self-hosted runner registration from GitHub.
6. Verify that no lab load balancers, instances, NAT Gateways,
   Elastic IPs, or chargeable storage remain.

Do not delete the local Terraform state before cleanup is complete.
Do not assume stopping EC2 instances stops all lab costs.


## Architecture and evidence

See [architecture and validation evidence](docs/architecture.md).

## Manual setup

See [manual setup and rebuild notes](docs/manual-setup.md).