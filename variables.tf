variable "global_tags" {
  type        = map(string)
  description = "Default tags to apply to AWS resources. Meant to be defined via Variable Sets in your Terraform Cloud organization, but can be overriden if needed."
  default     = {}
}

variable "local_tags" {
  type        = map(string)
  description = "Local tags to apply to cloud resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS Region in which to deploy our instance."
  default     = "us-east-1"
}

variable "prefix" {
  type        = string
  description = "Naming prefix"
}

variable "owner_cidr_blocks" {
  type        = list(string)
  description = "Owner CIDR block to allow access from owner's subnet."
  default     = []
}

variable "ami_filter" {
  type        = string
  description = "AMI filter - e.g. ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

variable "ami_owner" {
  type        = string
  description = "Owner of AMI - e.g. Canonical (for Ubuntu images) is 099720109477. RedHat is 309956199498."
  default     = "099720109477"
}

variable "ami_id" {
  type        = string
  description = "Optional AMI ID - use this if not blank string, otherwise use AMI per ami_filter and ami_owner."
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Instance size."
  default     = "m5.large"
}

variable "root_volume_type" {
  type        = string
  description = "Root volume type."
  default     = "gp2"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GB."
  default     = 50
}

variable "instance_security_group_ids" {
  type        = list(string)
  description = "List of additional security group ID's to apply to the instance."
  default     = []
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile to apply to instance."
  default     = null
}

# Vault instance
variable "install_packages" {
  type        = bool
  description = "Install required packages? Set to false if using a machine image that has the required packages installed."
  default     = true
}

variable "ssh_import_id" {
  type        = string
  description = "Name of id from which to import ssh keys. e.g. gh:ykhemani. The corresponding ssh keys will have root access to the instance."
  default     = ""
}

variable "domain" {
  type        = string
  description = "Domain"
  default     = "example.com"
}

variable "vault_license" {
  type        = string
  description = "Vault license"
}

variable "cert_dir" {
  type        = string
  description = "Location for CA and certificates"
  default     = "/data/certs"
}

# Certificate Authority attributes
variable "ca_country" {
  type        = string
  description = "Certificate Authority (CA) Country."
  default     = "US"
}

variable "ca_state" {
  type        = string
  description = "CA State."
  default     = "California"
}

variable "ca_locale" {
  type        = string
  description = "CA Locale."
  default     = "San Francisco"
}

variable "ca_org" {
  type        = string
  description = "CA Organization."
  default     = "HashiCorp"
}

variable "ca_ou" {
  type        = string
  description = "CA Organizational Unit."
  default     = "HashiCorp Network Operations Center"
}

variable "ca_common_name" {
  type        = string
  description = "CA Common Name (CN)."
  default     = "HashiCorp Certificate Authority"
}

variable "ca_cert_validity" {
  type        = number
  description = "CA Certificate validity period in hours."
  default     = 87600 # 10 years  
}

# Wildcard certificate attributes, used for Vault and LDAP server
variable "cert_country" {
  type        = string
  description = "Certificate Country."
  default     = "US"
}

variable "cert_state" {
  type        = string
  description = "Certificate State."
  default     = "California"
}

variable "cert_locale" {
  type        = string
  description = "Certificate Locale."
  default     = "San Francisco"
}

variable "cert_org" {
  type        = string
  description = "Certificate Organization."
  default     = "HashiCorp"
}

variable "cert_ou" {
  type        = string
  description = "Certificate Organizational Unit."
  default     = "HashiCorp Network Operations Center"
}

variable "cert_validity" {
  type        = number
  description = "Certificate validity period in hours."
  default     = 8760 # 1 year
}

variable "ldap_users" {
  type        = string
  description = "list of ldap users to create. These users will also be able to log into Vault and be used to generate Vault clients."
  default     = "yash,scott,tom,brandon,dan,michael,john,jane,jessica,mary,tom,david,henry,sandy,mickey,minnie,goofy,pluto,joe,static-user"
}

variable "ldap_user_vault_admin" {
  type        = string
  description = "LDAP user to be assigned vault admin policy."
  default     = "yash"
}
