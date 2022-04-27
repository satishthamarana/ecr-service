data "aws_lb" "common" {
    name = "oms-common-alb-${var.environment}"
}

data "aws_security_group" "common" {
    vpc_id = "${var.vpc_id}"
    name = "ecs-oms-common-sg-${var.environment}"
}

data "aws_lb_listener" "lb_common_http_listener" {
    load_balancer_arn = "${data.aws_lb.common.arn}"
    port = 80
}

#data "aws_route53_zone" "public_hosted_zone" {
#    name = "${var.route53_zone_name}"
#    private_zone = false
#}
