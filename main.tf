resource "proxmox_vm_qemu" "ubuntu_dmz_01" {
  # This forces Ubuntu to wait until the router is fully provisioned
  depends_on = [
    proxmox_vm_qemu.opnsense_router
  ]
  name        = "ubuntu-target-01"
  target_node = "proxmoxServer" 
  vga {
    type = "std"
  }

  serial {
    id   = 0
    type = "socket"
  }

  # 1. Point to your untouched base template
  clone       = "ubuntu-cloud-template" 
  full_clone  = true
  
  agent       = 1
  os_type     = "cloud-init"
  
  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  # 2. Tell Proxmox to run your custom YAML on boot
  cicustom    = "vendor=local:snippets/vendor.yaml"

  # 3. Terraform will still inject these automatically
  ciuser      = "colton"
  cipassword  = "TheGoats1234!"
  ipconfig0   = "ip=dhcp" 
  sshkeys     = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHcX1JuoNjwv7SG+3ykiivVXDQa/j3UMhqy/fw6AUjuoRJegs40KeLLpbLFxOh3/jpyte2UQw5/k7ZQdK3abduSU4tjSSIBy5woj2ZwvjVW8yBa5lMWJfSohIgL3Q7yyynho+YRxp/2oZh32VT3Zj/RB1AhJLcCrd4DAye3v924Sn2ID9gAu6guQ317m6V1kHOxTiN9dbgjmjENckHtMD/LShNTimukST/vdqkake5mJsQC33bE87ed24I40eN2XCq3pDr6xehiLQCERPA4Csny9IRS7IVPAbRvdgHotrSrIBJidEXU62YOerwq6FnFxuiU/BI4IjeuSMoJ2k3mYJq7uAV6Gb9o8DJfJdm2YrVlPIC4i2WeGrj7/TSLuNQNaFcDeBEreheBBtgW9GS63uIJxBD9Ga1JpOEVOV8LFAvP+TSnj4FVbhkDZPeKKIR5xOounXE0Df1vOkv6Rn1uPWWaKPa7w3LNY7XDcBFZv8skTXvLe3vT+3jSFQ6SDUB1Fr3tOTvOA2GUstwaKte9a5O6ZZQPBh8gTMLveurOI4DCxHkcre0FquQNuEYK+zxjQLlp8PpoJSO/O3GOsqGRVHo89+yFQroxx9b5cG39QsB5O6cQypAcilWaSZkKI75k0TqzhdZcEMmP3LGRteOHjqtz1YtErLfD36dKafzSIHW6Q== colto@Colton
EOF

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
    ide {
      ide2 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1" 
  }
}

resource "proxmox_vm_qemu" "opnsense_router" {
  name        = "opnsense-router"
  target_node = "proxmoxServer"
  clone       = "opnsense-golden-base" 
  full_clone  = true
  
  # REMOVED: boot = "order=scsi0"

  cpu {
    cores   = 2
    type    = "host"
    sockets = 1
  }

  memory = 2048
  agent  = 1
  scsihw = "virtio-scsi-pci" 

  # The disks block remains deleted so we don't overwrite the clone
  
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1"
  }
  lifecycle {
    ignore_changes = [
      disks,
    ]
  }
}

resource "proxmox_vm_qemu" "windows_admin" {
  name        = "win10-admin-01"
  target_node = "proxmoxServer"
  clone       = "Win10-Lab-01" 
  full_clone  = true
  
  os_type     = "win10"
  agent       = 0 

  cpu {
    cores   = 2
    type    = "host"
    sockets = 1
  }

  memory = 4096 

  # Force UEFI, but let the template handle the boot order
  bios   = "ovmf"

  network {
    id     = 0
    model  = "virtio" 
    bridge = "vmbr1" 
  }

  lifecycle {
    ignore_changes = [
      disks,
      efidisk
    ]
  }
}