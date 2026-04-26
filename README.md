# Enterprise Cyber Range Infrastructure (Proxmox)

This repository contains the Infrastructure as Code (IaC) required to automatically provision, configure, and segment an enterprise-grade cyber range for offensive and defensive security operations.

## Architecture Overview
This environment is hosted on a bare-metal Proxmox hypervisor. The infrastructure is entirely codified using **Terraform**, allowing for rapid teardown and reproducible deployments.

## Physical Diagram
flowchart TD
    Internet((Internet)) --- LocalRouter[Local Physical Router]
    LocalRouter --- Switch[Physical Network Switch]
    Switch --- NIC[Physical NIC e.g., eno1]
    
    subgraph Hardware
    NIC --- Proxmox[Proxmox Bare-Metal Server]
    end

## Logical Diagram
flowchart TB
    RemoteUser((Remote User)) -- Tailscale VPN Tunnel --> OPNsense

    subgraph Proxmox Hypervisor
        
        subgraph WAN [vmbr0 - External Bridge]
            Ext_Net[Physical Network / Internet]
        end

        Ext_Net -->|WAN Interface| OPNsense[OPNsense Firewall VM]

        subgraph LAN [vmbr1 - Cyber Range 192.168.1.0/24]
            OPNsense -->|LAN Interface| Switch{Virtual Switch}
            Switch --- Ubuntu[ubuntu-target-01]
            Switch --- Windows[win10-target-01]
        end
        
    end

### Currently Deployed Infrastructure
* **Perimeter Firewall (OPNsense):** An OPNsense router (`opnsense-fw-01`) that isolates the cyber range. It bridges the external network (`vmbr0`) and the internal lab network (`vmbr1`). It is automatically bootstrapped via SSH to install and configure **Tailscale**, advertising the internal subnet (`192.168.1.0/24`) for secure remote access.
* **Linux Target / DMZ:** An Ubuntu VM (`ubuntu-target-01`) deployed via Cloud-Init with custom vendor YAML snippets. Terraform dependencies ensure this node only provisions after the routing layer is fully operational.
* **Windows Target:** A Windows 10 machine (`win10-target-01`) connected to the internal network (`vmbr1`), utilizing VirtIO drivers and UEFI (OVMF) for optimized performance.

*(Note: Future deployments will expand the environment to include a fully configured Windows Active Directory domain and a Wazuh SIEM).*

## Technologies Used
* **Hypervisor:** Proxmox VE 8/9
* **Infrastructure Provisioning:** Terraform (Telmate Provider)
* **Automation:** Cloud-Init, SSH remote-exec provisioners
* **Networking & VPN:** OPNsense, Tailscale

## Security Notice
For security purposes, the `terraform.tfvars` file containing hypervisor authentication credentials and sensitive API tokens (like the `tailscale_auth_key`) has been excluded from this repository via `.gitignore`. To deploy this environment locally, you must provide your own `.tfvars` file matching the variables declared in your Terraform configuration.