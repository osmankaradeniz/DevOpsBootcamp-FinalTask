resource "aws_ecs_cluster" "ecs" {
  name = "reactjs-app-cluster"
}
 

resource "aws_ecs_task_definition" "td" {
  container_definitions = jsonencode([
    {
      name         = "reactjs-app"
      image        = "978871063865.dkr.ecr.eu-central-1.amazonaws.com/reactjs-app:latest"
      cpu          = 256
      memory       = 512
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  family                   = "reactjs-app"
  requires_compatibilities = ["FARGATE"]

  cpu                = "256"
  memory             = "512"
  network_mode       = "awsvpc"
  task_role_arn      = "arn:aws:iam::978871063865:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::978871063865:role/ecsTaskExecutionRole"
  
}



resource "aws_alb" "alb" {
  name               = "reactjs-app-alb" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
  aws_subnet.sn1.id, 
  aws_subnet.sn2.id, 
  aws_subnet.sn3.id
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.alb_sg.id}"]
}



resource "aws_ecs_service" "service" {
  name = "reactjs-app-service"
  cluster                = aws_ecs_cluster.ecs.arn
  launch_type            = "FARGATE"
  enable_execute_command = true
  
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 3
  task_definition                    = aws_ecs_task_definition.td.arn

  
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.td.family
    container_port   = 80
  }
  

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.service_sg.id]
    subnets          = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
  }

  
}




