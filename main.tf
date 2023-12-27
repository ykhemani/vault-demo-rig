locals {
  tags = merge(
    var.global_tags,
    var.local_tags
  )

  # ami_id precedence:
  # 1. var.ami_id
  # 2. data.aws_ami.ami
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.ami.id
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

# for CA
# ca private key
resource "tls_private_key" "ca-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ca cert
resource "tls_self_signed_cert" "ca-cert" {
  private_key_pem       = tls_private_key.ca-private-key.private_key_pem
  validity_period_hours = var.ca_cert_validity
  is_ca_certificate     = true

  subject {
    common_name         = "${var.domain} Certificate Authority"
    country             = var.ca_country
    province            = var.ca_state
    locality            = var.ca_locale
    organization        = var.ca_org
    organizational_unit = var.ca_ou

  }
  allowed_uses = [

    "digital_signature",
    "key_encipherment",
    "data_encipherment",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
}

# ssh private key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.prefix}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# wildcard private key
resource "tls_private_key" "wildcard_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# wildcard csr
resource "tls_cert_request" "wildcard_csr" {
  private_key_pem = tls_private_key.wildcard_private_key.private_key_pem

  subject {
    common_name         = "*.${var.domain}"
    country             = var.cert_country
    province            = var.cert_state
    locality            = var.cert_locale
    organization        = var.cert_org
    organizational_unit = var.cert_ou
  }

  dns_names = [
    "*.${var.domain}",
  ]

  ip_addresses = ["127.0.0.1"]
}

# wildcard cert
resource "tls_locally_signed_cert" "wildcard_cert" {
  cert_request_pem   = tls_cert_request.wildcard_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca-private-key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca-cert.cert_pem

  validity_period_hours = var.cert_validity

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",

  ]
}

# Canonical Ubuntu Image
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = [var.ami_owner]
}

resource "aws_network_interface" "nic" {
  subnet_id = element(module.vpc.public_subnets, 1)
  security_groups = concat(
    [
      aws_security_group.sg_ingress.id,
      aws_security_group.sg_egress.id
    ],
    var.instance_security_group_ids
  )
}

resource "aws_eip" "eip" {
  network_interface = aws_network_interface.nic.id
}

resource "aws_instance" "instance" {
  network_interface {
    network_interface_id = aws_network_interface.nic.id
    device_index         = 0
  }

  # ami                  = "ami-0d617e077b72bc526"
  # ami                  = data.hcp_packer_image.image.cloud_image_id # hcp packer image
  ami                  = local.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  key_name             = aws_key_pair.ssh.key_name
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  user_data_base64 = base64gzip(templatefile("${path.module}/templates/userdata.tftpl", {
    install_packages      = var.install_packages,
    domain                = var.domain,
    vault_license         = var.vault_license,
    ldap_users            = var.ldap_users,
    ldap_user_vault_admin = var.ldap_user_vault_admin,
    cert_dir              = var.cert_dir,
    ca_cert               = tls_self_signed_cert.ca-cert.cert_pem,
    wildcard_private_key  = tls_private_key.wildcard_private_key.private_key_pem,
    wildcard_cert         = tls_locally_signed_cert.wildcard_cert.cert_pem,
    ssh_import_id         = var.ssh_import_id,
  }))

  tags = merge(
    { Name = "${var.prefix}-demo" },
    local.tags
  )
}

resource "local_file" "ca_cert" {
  content         = tls_self_signed_cert.ca-cert.cert_pem
  filename        = "${path.module}/ca.pem"
  file_permission = "0644"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "${path.module}/ssh_key"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "${path.module}/ssh_key.pub"
  file_permission = "0644"
}
