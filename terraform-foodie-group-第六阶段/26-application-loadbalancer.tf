
module "alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "8.1.0"

    name = "${local.name}-alb"
    load_balancer_type = "application"
    vpc_id = module.vpc.vpc_id
    # loadbalancer 被存放在pulic subnet里面，这样loadbalancer 可以在两个public subnet里面工作
    subnets = [
        module.vpc.public_subnets[0],
        module.vpc.public_subnets[1]
    ]
    security_groups = [module.loadbalancer_sg.security_group_id]

    # listener这个8080 是 loadbalancer要监听的8080端口，
    # 流程是这样的，请求使用 ( Load Balancer DNS：8080) ---> loadbalancer监听到8080端口 ---> 去到 target_group_index = 0 的group ----> ec2 instance 的8080端口
    http_tcp_listeners = [
        {
            port               = 8080
            protocol           = "HTTP"
            target_group_index = 0 # App1  target group associated to this listener
        }
    ]  

    # Target Groups,这里只建立了一个target group，放入两个ec2 instance
    target_groups = [
        # App1 Target Group - target group Index = 0
        {
            name_prefix          = "app1-"
            backend_protocol     = "HTTP"
            backend_port         = 8080
            target_type          = "instance"
            deregistration_delay = 10
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/foodie-dev-api/databaseConnection"  //health_check块里面只需要改这个就好，每隔30s检查一次【IP：8080/foodie-dev-api/databaseConnection】这个api是否正常。如果health check 发生错误会发生什么事呢？
                port                = "traffic-port"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"
            }
            protocol_version = "HTTP1"    //默认地写HTTP1
            # App1 Target Group - Targets，这两个(ec2_private_app) private ec2 instance 包含在target group里面
            targets = {
                my_app1_vm1 = {
                    target_id = module.ec2_private_app.id[0]
                    port      = 8080
                },
                my_app1_vm2 = {
                    target_id = module.ec2_private_app.id[1]
                    port      = 8080
                }
            }
            tags =local.common_tags # Target Group Tags
        }  
    ]
    tags = local.common_tags # ALB Tags
}

