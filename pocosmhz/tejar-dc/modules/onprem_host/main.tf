resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
