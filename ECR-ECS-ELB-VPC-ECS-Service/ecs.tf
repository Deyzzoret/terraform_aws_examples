# Includes ECS Cluster, Task Definition, Role and Policy code

# Getting data existed ECR
# Data source bloc, used to retrieve information related to 
# ECR created for application
data "aws_ecr_repository" "flask_app_tf" {
  name = "flask-app-ecr"
}

# Creating ECS Cluster
# The aws_ecs_cluster resource in Terraform is used to create an Amazon ECS cluster, which is a logical grouping of tasks and services.
# An ECS cluster represents a pool of resources (such as EC2 instances or Fargate tasks) that can be used to run and manage your containerized applications.
# From my understanding, this is where it will be contained all my
# container services running in AWS FARGATE, or at least where they will
# be deployed.

# The aws_ecs_cluster resource in Terraform is used to create an Amazon ECS cluster,
# which is a logical grouping of tasks and services. An ECS cluster represents a pool
# of resources (such as EC2 instances or Fargate tasks) that can be used to run and
# manage your containerized applications.

# In summary, the aws_ecs_cluster resource is used to create a cluster that serves as a foundational
# environment for running containerized applications. You can definitely associate multiple services
# with a single cluster to efficiently manage and scale your container workloads.
resource "aws_ecs_cluster" "flask_app_ecs_cluster_tf" {
  # Naming the cluster
  name = "flask_app_ecs_cluster" 
}

# Creating ECS Task
# This represents the lowest running entity in Fargate or EC2 instance with ECS.
# Normally, we will have to to define a Task template within it will be defined
# the spec of the image to execute either on Fargate/EC2-ECS.
resource "aws_ecs_task_definition" "flask_app_task_tf" {
  family                   = "flask-app-task" 
  container_definitions    = <<DEFINITION
  [
    {
      "name": "flask-app-task",
      "image": "${data.aws_ecr_repository.flask_app_tf.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  # Stating that we are using ECS Fargate
  requires_compatibilities = ["FARGATE"] 
  # Using awsvpc as our network mode as this is required for Fargate
  network_mode             = "awsvpc"
  # Specifying the memory our container requires
  memory                   = 512
  # Specifying the CPU our container requires   
  cpu                      = 256         
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

# This is like if we were defining the assume role policy inside the 
# IAM role definition. Like if we were saving content on a variable.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Creating Role for ECS
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}


# Role - Policy Attachment for ECS
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  // Policy defined by AWS
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}