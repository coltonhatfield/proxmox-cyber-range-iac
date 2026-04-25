resource "proxmox_vm_qemu" "ubuntu_dmz_01" {
  name        = "ubuntu-dmz-01"
  desc        = "Vulnerable Web Services for Portfolio Cyber Range"
  target_node = "proxmoxServer" 
  
  clone       = "ubuntu-cloud-template"
  
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu_type    = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size     = 20
          storage  = "local-zfs"
          iothread = true
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=dhcp" 
}