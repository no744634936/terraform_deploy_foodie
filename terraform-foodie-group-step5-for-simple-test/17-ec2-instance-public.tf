# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
# 用module来建立ec2 实例
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.21.0"  
  # insert the 10 required variables here
  name                   = "${var.environment}-BastionHost"
  #instance_count         = 2   //只有一个public ec2 instance,所以注释掉
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair     // ec2 的登录密钥的名字
  subnet_id              = module.vpc.public_subnets[1]  // 在第二个subnet中建立ec2 实例
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  user_data = file("${path.module}/mariadb-install.sh")  //下载mariadb  用来连接后面要建立的app3中的数据库
  tags = local.common_tags
}