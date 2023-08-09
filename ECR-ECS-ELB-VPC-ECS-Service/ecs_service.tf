# Includes ECS Fargate Service code with linking to ELB (Elastic Loadbalancer), subnets, task definition.

# Creating ECS Service
resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.flask_app_ecs_cluster_tf.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.flask_app_task_tf.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group_tf.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.flask_app_task_tf.family}"
    container_port   = 5000 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_subnet.public_subnet_a.id}", "${aws_subnet.public_subnet_b.id}", "${aws_subnet.public_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}

# Creating SG for ECS Container Service, referencing the load balancer security group
# This security group has an ingress rule that allows traffic from the security group associated
# with the load balancer (load_balancer_security_group).
# This rule ensures that only the load balancer can communicate with the ECS tasks.
resource "aws_security_group" "service_security_group" {
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Log the load balancer app URL
output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}
