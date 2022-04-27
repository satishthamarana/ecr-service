#----------------------------------
# ECS Task
#----------------------------------
resource "aws_ecs_task_definition" "ecs_task" {
    family = "dms-common-service-${var.environment}"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu       = 1024
    memory    = 2048
    task_role_arn            = "arn:aws:iam::${var.account_id}:role/cl/app/oms/ecs-oms-common-role"
    execution_role_arn       = "arn:aws:iam::${var.account_id}:role/cl/app/oms/ecs-oms-common-role"

    container_definitions = jsonencode([
    {
      "name"      : "ecs-dms-dmsservice-${var.environment}",
      "image"     : "${var.ecr_repo}/dms/dmsservice:${var.app_version}",
      "essential" : true,
      "logConfiguration": {
         "logDriver": "awslogs",
         "options": {
            "awslogs-group": "/ecs/dms/dmsservice/${var.environment}",
            "awslogs-region": "ap-south-1",
            "awslogs-stream-prefix": "ecs"
         }
      },
      "portMappings" : [
        {
          "containerPort" : var.listener_port
          "hostPort"      : var.listener_port
        }
      ],
      "environment" : [
          {
              "name"  : "RDS_PORT",
              "value" : "5432"
          },
          {
              "name"  : "env",
              "value" : "${var.environment}"
          }
      ]
    }
  ])

    tags = {
	Name        = "ecs-dmsservice-task-definition-${var.environment}"
	Environment = var.environment
    }
}

#----------------------------------
# ECS Service
#----------------------------------
resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-dms-dmsservice-${var.environment}"
  cluster         = "oms-common-ecs-cluster-${var.environment}"
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = "${var.ecs_desired_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [data.aws_security_group.common.id]
    subnets         = "${split(",", "${var.private_subnets}")}"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "ecs-dms-dmsservice-${var.environment}"
    container_port   = "${var.listener_port}"
  }

  depends_on = [
      aws_lb_listener_rule.alb_http_rule,
      aws_lb_listener_rule.alb_http_rule_glob
  ]

    tags = {
	Name        = "ecs-dmsservice-${var.environment}"
	Environment = var.environment
    }
}

resource "aws_cloudwatch_log_group" "service_log_group" {
   name    = "/ecs/dms/dmsservice/${var.environment}"
   retention_in_days = 30

   tags = {
        Name        = "dms-dmsservice-${var.environment}"
        Environment = var.environment
    }
  
}

#----------------------------------
# ALB Target Group for ECS Service
#----------------------------------
resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-dms-dmsservice-${var.environment}"
  port        = var.listener_port
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
      path = "${var.healthcheck_path}"
      matcher = "200"
      unhealthy_threshold = 6
  }

    tags = {
       	Name        = "ecs-dmsservice-task-definition-${var.environment}"
	Environment = var.environment
    }
}

#------------------------------------------------
# ALB Listener Rules for https
#-----------------------------------------------
#resource "aws_lb_listener_rule" "alb_https_rule" {
#  listener_arn = "$data.aws_lb_listener.lb-common-https-listener.arn}"

#  action {
#    type             = "forward"
#    target_group_arn = "${aws_lb_target_group.ecs_target_group.arn}"
#  }

#  condition {
#    path_pattern {
#      values = ["${var.service_path}"]
#    }
#  }
#}

#resource "aws_lb_listener_rule" "alb_https_rule_glob" {
#  listener_arn = "$data.aws_lb_listener.lb-common-https-listener.arn}"

#  action {
#    type             = "forward"
#    target_group_arn = "${aws_lb_target_group.ecs_target_group.arn}"
#  }

#  condition {
#    path_pattern {
#      values = ["${var.service_path}/*"]
#    }
#  }
#}

#------------------------------------------------
# ALB Listener Rules for http
#-----------------------------------------------
resource "aws_lb_listener_rule" "alb_http_rule" {
  listener_arn = data.aws_lb_listener.lb_common_http_listener.arn

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ecs_target_group.arn}"
  }

  condition {
    path_pattern {
      values = ["${var.service_path}"]
    }
  }
}

resource "aws_lb_listener_rule" "alb_http_rule_glob" {
  listener_arn = data.aws_lb_listener.lb_common_http_listener.arn

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ecs_target_group.arn}"
  }

  condition {
    path_pattern {
      values = ["${var.service_path}/*"]
    }
  }
}
