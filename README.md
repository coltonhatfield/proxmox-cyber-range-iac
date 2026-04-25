# Enterprise Cyber Range Infrastructure (Proxmox)

This repository contains the Infrastructure as Code (IaC) required to automatically provision, configure, and segment an enterprise-grade cyber range for offensive and defensive security operations.

## Architecture Overview
This environment is hosted on a bare-metal Proxmox hypervisor. The infrastructure is entirely codified using **Terraform**, allowing for rapid teardown and reproducible deployments.

Currently deployed:
* **DMZ Zone:** Ubuntu 24.04 server hosting intentionally vulnerable web services.

*(Note: As the project grows, list your Windows AD environment, pfSense firewall, and Wazuh SIEM here).*

## Technologies Used
* **Hypervisor:** Proxmox VE 8/9
* **Infrastructure Provisioning:** Terraform (Telmate Provider v3.x)
* **Automation:** Cloud-Init 

## Security Notice
For security purposes, the `terraform.tfvars` file containing hypervisor authentication credentials has been excluded from this repository via `.gitignore`. To deploy this environment locally, you must provide your own `.tfvars` file matching the variables declared in `provider.tf`.