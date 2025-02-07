terraform {
  required_providers {
    b2 = {
      source = "Backblaze/b2"
      version = "0.10.0"
    }
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = "1.2.0"
    }    
  }
}

provider "b2" {

}

variable "LATITUDESH_AUTH_TOKEN" {
  type = string
  sensitive = true
  nullable = false  
}

variable "LATITUDESH_PROJECT" {
  nullable = false
  type = string
}

variable "SSH_PUBLIC_KEY" {
  nullable = false
  type = string
}

provider "latitudesh" {
  auth_token = var.LATITUDESH_AUTH_TOKEN
}

data "b2_bucket" "n1-nix-public" {
  bucket_name = "n1-nix-public"
  # bucket_type = "allPublic" # must be to share with Latitude
}

# resource "b2_bucket_file_version" "ipxe_003" {
#     bucket_id = data.b2_bucket.n1-nix-public.id
#     file_name = "ipxe_003.ipxe"
#     content_type = "text/plain"
#     source = "${path.module}/../../result/netboot.ipxe"
#     # depends_on = [ b2_bucket_file_version.initrd_003 ]
# }


# resource "b2_bucket_file_version" "initrd_003" {
#     bucket_id = data.b2_bucket.n1-nix-public.id
#     file_name = "initrd_003"
#     content_type = "application/octet-stream"
#     source = "${path.module}/../../result/initrd"
#     depends_on = [ b2_bucket_file_version.kernel_003 ]
# }


# resource "b2_bucket_file_version" "kernel_003" {
#     bucket_id = data.b2_bucket.n1-nix-public.id
#     file_name = "kernel_003"
#     content_type = "application/octet-stream"
#     source = "${path.module}/../../result/bzImage"
# }

# # what we get using:
# # backblaze-b2 file url b2://{bucket_name}/{file_name}
# output "ipxe_url" {
#     value = "https://f003.backblazeb2.com/file/${data.b2_bucket.n1-nix-public.bucket_name}/${b2_bucket_file_version.ipxe_003.file_name}"
# }

# output "initrd_url" {
#     value =  "https://f003.backblazeb2.com/file/${data.b2_bucket.n1-nix-public.bucket_name}/${b2_bucket_file_version.initrd_003.file_name}"
# }

# output "kernel_url" {
#     value = "https://f003.backblazeb2.com/file/${data.b2_bucket.n1-nix-public.bucket_name}/${b2_bucket_file_version.kernel_003.file_name}"
# }

resource "latitudesh_ssh_key" "latitudesh_ssh_key" {
  project    = var.LATITUDESH_PROJECT
  name       = "init_key"
  public_key = var.SSH_PUBLIC_KEY
}

resource "latitudesh_server" "server" {
  hostname         = "c2-small-x86-nixos-22-11-sao-nord"
  # "https://f003.backblazeb2.com/file/${data.b2_bucket.n1-nix-public.bucket_name}/${b2_bucket_file_version.ipxe_003.file_name}"
  ipxe_url = "https://raw.githubusercontent.com/latitudesh/examples/refs/heads/main/custom-images/ubuntu-24/boot.ipxe" 
  operating_system = "ipxe"
  plan             = "c2-small-x86"
  project          = var.LATITUDESH_PROJECT   # MUST be ID, not name, name leads to recreation
  site             = "SAO"  
  ssh_keys         = [latitudesh_ssh_key.latitudesh_ssh_key.id]
  tags = [] # must use, beause auto is [], not null
}


qemu-system-x86_64   -m 4096   -kernel result-2/bzImage   -initrd result-2/initrd.img   -append "console=ttyS0 root=/dev/ram0 rw init=/nix/store/87kznggrn3pig59r1fik9irii182bh37-nixos-system-nixos-24.11beta708350.1d95cb5/init initrd=initrd-x86_64-linux nohibernate loglevel=4 "   -nographic

qemu-system-x86_64   -m 4096   -kernel result/bzImage   -initrd result/initrd   -append "console=ttyS0 root=/dev/ram0 rw init=/nix/store/k6k1x4g20ny06hd35p5djngjs79ah9pa-nixos-system-nixos-24.11.20241231.edf04b7/init initrd=initrd nohibernate loglevel=4 "   -nographic