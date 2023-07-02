# AWS EC2 Security Group Terraform Module
# Security Group for private Bastion 
# 使用module来建立Security Group

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  name        = "private-sg"
  description = "Security Group with HTTP & SSH port open for entire VPC Block (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH TCP"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "nginx port"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "tomcat port"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = "tcp"
      description = "foodie project port"
      cidr_blocks = module.vpc.vpc_cidr_block
    },] 
    //注意这里的8080,8088端口要打开，后面的java app是跑在8080端口的

  egress_rules = ["all-all"]
  tags = local.common_tags 
}