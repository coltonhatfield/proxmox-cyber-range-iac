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

  # Cloud-Init User Config (Keep these at the top level)
  ciuser      = "colton"
  ipconfig0   = "ip=dhcp" 
  sshkeys     = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHcX1JuoNjwv7SG+3ykiivVXDQa/j3UMhqy/fw6AUjuoRJegs40KeLLpbLFxOh3/jpyte2UQw5/k7ZQdK3abduSU4tjSSIBy5woj2ZwvjVW8yBa5lMWJfSohIgL3Q7yyynho+YRxp/2oZh32VT3Zj/RB1AhJLcCrd4DAye3v924Sn2ID9gAu6guQ317m6V1kHOxTiN9dbgjmjENckHtMD/LShNTimukST/vdqkake5mJsQC33bE87ed24I40eN2XCq3pDr6xehiLQCERPA4Csny9IRS7IVPAbRvdgHotrSrIBJidEXU62YOerwq6FnFxuiU/BI4IjeuSMoJ2k3mYJq7uAV6Gb9o8DJfJdm2YrVlPIC4i2WeGrj7/TSLuNQNaFcDeBEreheBBtgW9GS63uIJxBD9Ga1JpOEVOV8LFAvP+TSnj4FVbhkDZPeKKIR5xOounXE0Df1vOkv6Rn1uPWWaKPa7w3LNY7XDcBFZv8skTXvLe3vT+3jSFQ6SDUB1Fr3tOTvOA2GUstwaKte9a5O6ZZQPBh8gTMLveurOI4DCxHkcre0FquQNuEYK+zxjQLlp8PpoJSO/O3GOsqGRVHo89+yFQroxx9b5cG39QsB5O6cQypAcilWaSZkKI75k0TqzhdZcEMmP3LGRteOHjqtz1YtErLfD36dKafzSIHW6Q== colto@Colton
EOF

  # Corrected Disks Block for Provider v3.x
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
    # NEW: This is where the Cloud-Init drive lives now
    ide {
      ide2 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }
  }

  # Serial Console Fix
  serial {
    id   = 0
    type = "socket"
  }
  vga {
    type = "serial0"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1" # Change from vmbr0 to vmbr1
  }
}

resource "proxmox_vm_qemu" "opnsense_router" {
  name        = "opnsense-router"
  target_node = "proxmoxServer"
  clone       = "800" # Your OPNsense template ID
  full_clone  = true
  
  cores   = 2
  memory  = 2048
  agent   = 1

  # Interface 0: WAN (Connected to your home network)
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Interface 1: LAN/DMZ (Connected to your internal lab)
  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1" # Ensure this bridge exists in Proxmox
  }
}