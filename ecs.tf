// Jenkins Container Infra (Fargate)
resource "aws_ecs_cluster" "jenkins_controller" {
  name               = "${var.name_prefix}-main"
  capacity_providers = ["FARGATE"]
  tags               = var.tags
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster" "jenkins_agents" {
  name               = "${var.name_prefix}-spot"
  capacity_providers = ["FARGATE_SPOT"]
  tags               = var.tags
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

locals {
  base_secrets = {
    ADMIN_PWD = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/jenkins-pwd"
  }

  secrets = merge(local.base_secrets, var.secrets)

  jenkins_controller_container_def = [
    {
      name              = "${var.name_prefix}-controller"
      image             = aws_ecr_repository.jenkins_controller.repository_url
      cpu               = var.jenkins_controller_cpu
      memory            = var.jenkins_controller_memory
      memoryReservation = var.jenkins_controller_memory
      environment = [
        {
          name  = "JAVA_OPTS"
          value = "-Djenkins.install.runSetupWizard=false"
        }
      ]
      essential = true
      mountPoints = [
        {
          containerPath = "/var/jenkins_home"
          sourceVolume  = "${var.name_prefix}-efs"
        }
      ],
      portMappings = [
        { containerPort = var.jenkins_controller_port },
        { containerPort = var.jenkins_jnlp_port }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.jenkins_controller_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "controller"
        }
      },
      secrets = [for name, valueFrom in local.secrets : {
        name      = name
        valueFrom = valueFrom
      }]
    }
  ]
}

resource "aws_kms_key" "cloudwatch" {
  description = "KMS for cloudwatch log group"
  policy      = data.aws_iam_policy_document.cloudwatch.json
}



resource "aws_cloudwatch_log_group" "jenkins_controller_log_group" {
  name              = var.name_prefix
  retention_in_days = var.jenkins_controller_task_log_retention_days
  kms_key_id        = aws_kms_key.cloudwatch.arn
  tags              = var.tags
}



resource "aws_ecs_task_definition" "jenkins_controller" {
  family = var.name_prefix

  task_role_arn            = var.jenkins_controller_task_role_arn != null ? var.jenkins_controller_task_role_arn : aws_iam_role.jenkins_controller_task_role[0].arn
  execution_role_arn       = var.ecs_execution_role_arn != null ? var.ecs_execution_role_arn : aws_iam_role.ecs_execution_role[0].arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.jenkins_controller_cpu
  memory                   = var.jenkins_controller_memory
  container_definitions    = jsonencode(local.jenkins_controller_container_def)

  volume {
    name = "${var.name_prefix}-efs"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.this.id
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_service" "jenkins_controller" {
  name = "${var.name_prefix}-controller"

  task_definition  = aws_ecs_task_definition.jenkins_controller.arn
  cluster          = aws_ecs_cluster.jenkins_controller.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  // Assuming we cannot have more than one instance at a time. Ever.
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0


  service_registries {
    registry_arn = aws_service_discovery_service.controller.arn
    port         = var.jenkins_jnlp_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.name_prefix}-controller"
    container_port   = var.jenkins_controller_port
  }

  network_configuration {
    subnets          = var.jenkins_controller_subnet_ids
    security_groups  = [aws_security_group.jenkins_controller_security_group.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.https]
}


resource "aws_service_discovery_private_dns_namespace" "controller" {
  name        = var.name_prefix
  vpc         = var.vpc_id
  description = "Serverless Jenkins discovery managed zone."
}


resource "aws_service_discovery_service" "controller" {
  name = "controller"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.controller.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
  health_check_custom_config {
    failure_threshold = 5
  }
}
