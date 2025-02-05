terraform {
  required_providers {
    b2 = {
      source = "Backblaze/b2"
      version = "0.10.0"
    }
  }
}

provider "b2" {

}

data "b2_bucket" "n1-nix-public" {
  bucket_name = "n1-nix-public"
  # bucket_type = "allPublic"
}

resource "b2_bucket_file_version" "ipxe_1" {
    bucket_id = data.b2_bucket.n1-nix-public.id
    file_name = "ipxe_1.ipxe"
    content_type = "text/plain"
    source = "${path.module}/../../result/netboot.ipxe"
}


resource "b2_bucket_file_version" "initrd_1" {
    bucket_id = data.b2_bucket.n1-nix-public.id
    file_name = "initrd_1"
    content_type = "application/octet-stream"
    source = "${path.module}/../../result/initrd"
}


resource "b2_bucket_file_version" "kernel_1" {
    bucket_id = data.b2_bucket.n1-nix-public.id
    file_name = "kernel_1"
    content_type = "application/octet-stream"
    source = "${path.module}/../../result/bzImage"
}

output "ipxe_url" {
    value = b2_bucket_file_version.ipxe_1.file_id
}

output "initrd_url" {
    value = b2_bucket_file_version.initrd_1.file_id
}

output "kernel_url" {
    value = b2_bucket_file_version.kernel_1.file_id
}