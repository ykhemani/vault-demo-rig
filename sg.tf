resource "aws_security_group" "sg_ingress" {
  name        = "${var.prefix}_ingress_sg"
  description = "${var.prefix} Ingress Security Group"
  vpc_id      = module.vpc.vpc_id

  # owner cidr blocks
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.owner_cidr_blocks
  }

  # vpc cidr block
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "${var.prefix}_ingress_sg"
  }
}

resource "aws_security_group" "sg_egress" {
  name        = "${var.prefix}_egress_sg"
  description = "${var.prefix} Egress Security Group"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}_egress_sg"
  }
}
