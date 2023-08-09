# Includes ELB, Listener, Target Group, Security Group code


# Internet Access -> IGW -> LB Security Groups -> Application Load Balancer  (Listener 80) -> Target Groups  -> ECS Service -> ECS SG -> Tasks on each subnets 

# Creating Load Balancer (LB)
# The aws_alb resource block defines the creation of the Application Load Balancer.
# It's named "test-lb-tf" and specified to be of type "application".
# It's associated with three subnets, public_subnet_a, public_subnet_b, and public_subnet_c.
# This means the load balancer can route traffic to instances in these subnets.
# The security group load_balancer_security_group is assigned to the load balancer, which controls
# the incoming and outgoing traffic.
resource "aws_alb" "application_load_balancer" {
  name               = "test-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ 
    "${aws_subnet.public_subnet_a.id}",
    "${aws_subnet.public_subnet_b.id}",
    "${aws_subnet.public_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for LB
# This security group allows incoming traffic on port 80 (HTTP) from any IP address (0.0.0.0/0),
# making the ALB reachable from the internet. The egress rule allows all types of outgoing traffic.
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating LB Target Group
#  This target group is responsible for managing the targets (ECS tasks) that the load balancer will distribute traffic to.
#  It listens on port 80 for incoming HTTP requests and targets are identified by their IP addresses.
resource "aws_lb_target_group" "target_group_tf" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_vpc.my_vpc.id}" 
}

# Creating LB Listener
# The aws_lb_listener resource block sets up a listener on port 80 of the ALB.
# This listener forwards incoming HTTP requests to the previously defined target group 
resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
  }
}

# Scenario for ALB
# A user makes an HTTP request to the ALB's DNS name or IP address on port 80.
# The ALB listens to port 80 and receives the incoming request.
# The ALB's listener forwards the request to the target group "target-group".
# The target group identifies available targets (ECS tasks) to handle the request. It might distribute the request to multiple tasks based on load balancing algorithms.
# The selected target ECS task processes the request and sends the response back to the ALB.
# The ALB then forwards the response to the user who initiated the request.