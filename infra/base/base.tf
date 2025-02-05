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

resource "b2_bucket" "base" {
  bucket_name = "base"
  bucket_type = "allPublic"
}

resource "b2_bucket_file_version" "ipxe" {
    bucket_id = b2_bucket.base.id
    file_name = "base.ipxe"
    source = file("${path.module}/../../result/netboot.ipxe")
}