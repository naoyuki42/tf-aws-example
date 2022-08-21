# ECSログ
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/default"
  retention_in_days = 180
}

# ECSログ用IAMロール
module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

# バッチ用ログ
resource "aws_cloudwatch_log_group" "for_ecs_scheduled_tasks" {
  name              = "/ecs-scheduled-tasks/default"
  retention_in_days = 180
}

# CloudWatch Events
resource "aws_cloudwatch_event_target" "default_batch" {
  target_id = "default-batch"
  rule      = aws_cloudwatch_event_rule.default_batch.name
  role_arn  = module.ecs_events_role.iam_role_arn
  arn       = aws_ecs_cluster.default.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    platform_version    = "1.3.0"
    task_definition_arn = aws_ecs_task_definition.default_batch.arn

    network_configuration {
      assign_public_ip = false
      subnets          = [aws_subnet.private_01.id]
    }
  }
}

resource "aws_cloudwatch_event_rule" "default_batch" {
  name                = "default-batch"
  description         = "とても重要なバッチ処理です"
  schedule_expression = "cron(*/2***?*)"
}

# バッチ用IAMロール
module "ecs_events_role" {
  source     = "./iam_role"
  name       = "ecs-events"
  identifier = "evetns.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_events_execution_role_policy.policy
}

data "aws_iam_policy" "ecs_events_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

# SSMオペレーションログ
resource "aws_cloudwatch_log_group" "operation" {
  name              = "/operation"
  retention_in_days = 180
}
