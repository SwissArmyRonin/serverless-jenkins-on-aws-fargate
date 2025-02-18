data "aws_ecr_authorization_token" "token" {}

locals {
  ecr_endpoint  = split("/", aws_ecr_repository.jenkins_controller.repository_url)[0]
  docker_folder = var.docker_folder != null ? var.docker_folder : "${path.module}/docker"
}

resource "aws_ecr_repository" "jenkins_controller" {
  name                 = var.jenkins_ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "template_file" "jenkins_configuration_def" {

  template = file("${local.docker_folder}/files/jenkins.yaml.tpl")

  vars = merge({
    ecs_cluster_fargate      = aws_ecs_cluster.jenkins_controller.arn
    ecs_cluster_fargate_spot = aws_ecs_cluster.jenkins_agents.arn
    cluster_region           = var.region
    jenkins_cloud_map_name   = "controller.${var.name_prefix}"
    jenkins_controller_port  = var.jenkins_controller_port
    jnlp_port                = var.jenkins_jnlp_port
    agent_security_groups    = aws_security_group.jenkins_controller_security_group.id
    subnets                  = join(",", var.alb_subnet_ids)
  }, var.template_vars)
}


resource "null_resource" "render_template" {
  triggers = {
    src_hash = file("${local.docker_folder}/files/jenkins.yaml.tpl")
  }
  depends_on = [data.template_file.jenkins_configuration_def]

  provisioner "local-exec" {
    command = <<EOF
tee ${local.docker_folder}/files/jenkins.yaml <<ENDF
${data.template_file.jenkins_configuration_def.rendered}
EOF
  }
}

resource "null_resource" "build_docker_image" {
  triggers = {
    docker_hash = file("${local.docker_folder}/Dockerfile")
    src_hash    = file("${local.docker_folder}/files/jenkins.yaml.tpl")
    plugin_hash = file("${local.docker_folder}/files/plugins.txt")
  }
  depends_on = [null_resource.render_template]
  provisioner "local-exec" {
    command = <<EOF
docker login -u AWS -p ${data.aws_ecr_authorization_token.token.password} ${local.ecr_endpoint} && \
docker build -t ${aws_ecr_repository.jenkins_controller.repository_url}:latest ${local.docker_folder}/ && \
docker push ${aws_ecr_repository.jenkins_controller.repository_url}:latest
EOF
  }
}
