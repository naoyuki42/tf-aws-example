# クラスター
resource "aws_ecs_cluster" "default" {
  name = "default"
}

# タスク定義
# アプリケーション
resource "aws_ecs_task_definition" "default" {
  family                   = "default"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

# バッチ処理
resource "aws_ecs_task_definition" "default_batch" {
  family                   = "default-batch"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./batch_container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

# サービス
resource "aws_ecs_service" "default" {
  name                              = "default"
  cluster                           = aws_ecs_cluster.default.arn
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.private_01.id,
      aws_subnet.private_02.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = "default"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

# セキュリティグループ
module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.default.id
  port        = 80
  cidr_blocks = [aws_vpc.default.cidr_block]
}
