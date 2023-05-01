module "bastion" {
  source         = "../../tf-aws-ec2-amzn2"
  common_tags    = { Environment = "dev", AppName = "GoWeb" }
  instance_type  = "t2.micro"
  key_pair_name = "deployer-key"
  sg_name        = "goweb-terraform-ec2-only"
  sg_description = "EC2 bastion SGs"

  sg_inbound_rules = [
    {
      description = "Prometheus from Internet"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Node Exporter from Internet"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH Access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "node1" {
  source         = "../../tf-aws-ec2-amzn2"
  common_tags    = { Environment = "dev", AppName = "Node1" }
  instance_type  = "t2.micro"
  key_pair_name = "node1-key"
  sg_name        = "goweb-terraform-ec2-node1"
  sg_description = "EC2 bastion SGs"

  sg_inbound_rules = [
    {
      description = "Prometheus from Internet"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Node Exporter from Internet"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH Access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}