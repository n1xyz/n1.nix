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


