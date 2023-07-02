# Autoscaling Group Resource
# 使用launch template 做一个 auto scaling group
# auto scaling group 里面有两个 ec2 instance
# 这两个 ec2 instance 均分在 两个private_subnets里面，也就是说一个private_subnet里又一个ec2 instance
# 通过 target_group_arns = module.alb.target_group_arns 将auto scaling group 绑定到 load balancer的target group上
# 于是就有了这个流程
# 请求使用 ( Load Balancer DNS：8080) ---> loadbalancer监听到8080端口 ---> 去到 target_group_index = 0 的group的8080 端口 ---> auto scaling group 中的ec2 instance 的8080端口
resource "aws_autoscaling_group" "my_asg" {
  //不写这个depends_on 就会报错 ValidationError: The load balancer does not route traffic to the target group
  depends_on = [
    module.alb
  ]
  name_prefix = "myasg-"
  desired_capacity = 2   //ASG 里初始只有2台ec2 instance。デフォルトの台数
  max_size = 6 //ec2 instance最多几个
  min_size = 2 //ec2 instance最少几个
  vpc_zone_identifier = module.vpc.private_subnets //8号文件中里有这个变量，与private subnet 链接起来
  target_group_arns = module.alb.target_group_arns //将auto scaling group 绑定到 load balancer的target group上，27号文件里有这个变量， target_group_arns = ["arn:aws:elasticloadbalancing:ap-northeast-1:542542141872:targetgroup/app1-20221125212223023800000004/34bea09efbfeb43f",]
  health_check_type = "ELB" //按照 loadbalancer 的health check 规则来检查服务器是否正常，如果某个服务器不正常就自动替换掉它，如果没有设置loadbalancer 可以设置为EC2
  #health_check_grace_period = 300 # default is 300 seconds
  launch_template {
    id = aws_launch_template.my_launch_template.id 
    version = aws_launch_template.my_launch_template.latest_version
  }
# Instance Refresh
# 更新instance 的设定，可以找点youtube的视频看看
  instance_refresh {
    strategy = "Rolling"
    preferences {
      # instance_warmup = 300 # Default behavior is to use the Auto Scaling Groups health check grace period value
      min_healthy_percentage = 50            
    }
    triggers = [ "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger   
  }
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
}