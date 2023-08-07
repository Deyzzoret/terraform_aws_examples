# What do IaC files provision ?  
* Provisioning ECR (Elastic Container Repository)
* Pushing Image to ECR
* Provisioning ECS (Elastic Container Service)
* VPC (Virtual Private Cloud)
* ELB (Elastic Load Balancer)
* ECS Tasks
* Service on Fargate Cluster

# What do terraform files will do ? 

* First, we will create a dockerized Flask-app
* Provision ECR(Elastic Container Repository) and push to previous image to it
* After that, we will provision a VPC, Internet Gateway, Route Table, 3 Public Subnets
* Then, we will deploy ELB (Elastic Load Balancer), Listener, Target Group,
* Finally, ECS Fargate Cluster provisiton as well as Task and Service (running container as Service)