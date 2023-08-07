# Includes ECS Cluster, Task Definition, Role and Policy code

# Getting data existed ECR
data "aws_ecr_repository" "flask_app_tf" {
  name = "flask-app-ecr"
}

# Creating ECS Cluster
resource "aws_ecs_cluster" "flask_app_ecs_cluster_tf" {
  # Naming the cluster
  name = "flask_app_ecs_cluster" 
}

# Creating ECS Task
# TODO: Check what is this 
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}