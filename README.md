# AWS Serverless Jenkins Terraform Module
Terraform module which creates a serverless Jenkins environment based on AWS Fargate. The following resources are created:

* Two Amazon ECS clusters
    * One utilizing the standard `FARGATE` capacity provider, which is to be used by the Jenkins controller and high priority agents.
    * One utilizing the `FARGATE_SPOT` capacity provider, which is to be used by Jenkins agents which handle lower priority jobs.
* Amazon ECS service and task for Jenkins controller.
* Jenkins controller Docker container, including the [amazon-ecs-plugin](https://github.com/jenkinsci/amazon-ecs-plugin).
* Amazon ECR repository for storing the above container
* Application load balancer
* Amazon Elastic Filesystem to provide stateful storage for the Jenkins controller
* AWS Backup vault and schedule to backup EFS
* AWS Cloud Map service discovery domain and entry for Jenkins controller (for agent -> controller discovery)
* IAM Roles for the above components
* Security Groups for the above components

![Architecture](docs/Jenkins.png)

An example is included in the `example` directory.
## Prerequisites
The following are required to deploy this Terraform module

1. Terraform 13+ - Download at https://www.terraform.io/downloads.html
1. Docker 19+ - Download at https://docs.docker.com/get-docker/
1. A VPC with at least two public and two private subnets.
1. An SSL certificate to associate with the Application Load Balancer. It's recommended to use and ACM certificate. This is not done by the main Terraform module. However, the example in the `example` directory uses the [public AWS ACM module](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest) to create the ACM certificate and pass it to the Serverless Jenkins module. You may choose to do it this way or explicitly pass the ARN of a certificate that you had previously created or imported into ACM.
1. An admin password for Jenkins must be stored in SSM Parameter store. This parameter must be of type `SecureString` and have the name `jenkins-pwd`
1. Terraform must be bootstrapped. This means that a state S3 bucket and a state locking DynamoDB table must be initialized.

## Deployment
This is packaged as a Terraform module, which means it's not directly deployable. However, there is a deployable example in the `example` directory. To deploy the example:

1. Ensure you have met all the Prerequisites
1. If necessary, execute the bootstrap in the bootstrap directory. This will create a Terraform state bucket & state locking table. This step may be unnecessary if you already have an established Terraform environment.
1. copy `vars.sh.example` to `vars.sh`
1. Edit the variables in `vars.sh` as necessary giving all details specific to your environment (VPC, subnets, state bucket & state locking table, etc.)
1. Run `deploy_example.sh`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_cloudwatch_log_group.jenkins_controller_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_repository.jenkins_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_ecs_cluster.jenkins_agents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster.jenkins_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.jenkins_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.jenkins_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_policy.jenkins_controller_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.aws_backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.jenkins_controller_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jenkins_controller_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jenkins_controller_task_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.redirect_http_to_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.jenkins_controller_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_private_dns_namespace.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [null_resource.build_docker_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.render_template](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_iam_policy_document.aws_backup_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.efs_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.jenkins_controller_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_file.jenkins_configuration_def](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The target AWS account's id | `string` | n/a | yes |
| <a name="input_alb_access_logs_bucket_name"></a> [alb\_access\_logs\_bucket\_name](#input\_alb\_access\_logs\_bucket\_name) | n/a | `string` | `null` | no |
| <a name="input_alb_access_logs_s3_prefix"></a> [alb\_access\_logs\_s3\_prefix](#input\_alb\_access\_logs\_s3\_prefix) | n/a | `bool` | `null` | no |
| <a name="input_alb_acm_certificate_arn"></a> [alb\_acm\_certificate\_arn](#input\_alb\_acm\_certificate\_arn) | The ACM certificate ARN to use for the alb | `string` | n/a | yes |
| <a name="input_alb_create_security_group"></a> [alb\_create\_security\_group](#input\_alb\_create\_security\_group) | Should a security group allowing all traffic on ports 80 * 443 be created for the alb.<br>If false, a valid list of security groups must be passed with 'alb\_security\_group\_ids' | `bool` | `true` | no |
| <a name="input_alb_enable_access_logs"></a> [alb\_enable\_access\_logs](#input\_alb\_enable\_access\_logs) | n/a | `bool` | `false` | no |
| <a name="input_alb_ingress_allow_cidrs"></a> [alb\_ingress\_allow\_cidrs](#input\_alb\_ingress\_allow\_cidrs) | A list of cidrs to allow inbound into Jenkins. | `list(string)` | `null` | no |
| <a name="input_alb_security_group_ids"></a> [alb\_security\_group\_ids](#input\_alb\_security\_group\_ids) | A list of security group ids to attach to the Application Load Balancer | `list(string)` | `null` | no |
| <a name="input_alb_subnet_ids"></a> [alb\_subnet\_ids](#input\_alb\_subnet\_ids) | A list of subnets for the Application Load Balancer | `list(string)` | `null` | no |
| <a name="input_alb_type_internal"></a> [alb\_type\_internal](#input\_alb\_type\_internal) | alb | `bool` | `false` | no |
| <a name="input_docker_folder"></a> [docker\_folder](#input\_docker\_folder) | The path to a folder containing a Dockerfile and a Jenkins YAML template. If<br>not set, the default is to use the included files in './docker' | `string` | `null` | no |
| <a name="input_ecs_execution_role_arn"></a> [ecs\_execution\_role\_arn](#input\_ecs\_execution\_role\_arn) | An custom execution role to use as the ecs exection role (optional) | `string` | `null` | no |
| <a name="input_efs_access_point_gid"></a> [efs\_access\_point\_gid](#input\_efs\_access\_point\_gid) | The gid number to associate with the EFS access point | `number` | `1000` | no |
| <a name="input_efs_access_point_uid"></a> [efs\_access\_point\_uid](#input\_efs\_access\_point\_uid) | The uid number to associate with the EFS access point | `number` | `1000` | no |
| <a name="input_efs_backup_cold_storage_after_days"></a> [efs\_backup\_cold\_storage\_after\_days](#input\_efs\_backup\_cold\_storage\_after\_days) | Number of days until backup is moved to cold storage | `number` | `30` | no |
| <a name="input_efs_backup_completion_window"></a> [efs\_backup\_completion\_window](#input\_efs\_backup\_completion\_window) | A value in minutes after a backup job is successfully started before<br>it must be completed or it will be canceled by AWS Backup | `number` | `120` | no |
| <a name="input_efs_backup_delete_after_days"></a> [efs\_backup\_delete\_after\_days](#input\_efs\_backup\_delete\_after\_days) | Number of days until backup is deleted. If cold storage transition<br>'efs\_backup\_cold\_storage\_after\_days' is declared, the delete value must<br>be 90 days greater | `number` | `120` | no |
| <a name="input_efs_backup_schedule"></a> [efs\_backup\_schedule](#input\_efs\_backup\_schedule) | n/a | `string` | `"cron(0 00 * * ? *)"` | no |
| <a name="input_efs_backup_start_window"></a> [efs\_backup\_start\_window](#input\_efs\_backup\_start\_window) | A value in minutes after a backup is scheduled before a job will be<br>canceled if it doesn't start successfully | `number` | `60` | no |
| <a name="input_efs_enable_backup"></a> [efs\_enable\_backup](#input\_efs\_enable\_backup) | n/a | `bool` | `true` | no |
| <a name="input_efs_enable_encryption"></a> [efs\_enable\_encryption](#input\_efs\_enable\_encryption) | EFS | `bool` | `true` | no |
| <a name="input_efs_ia_lifecycle_policy"></a> [efs\_ia\_lifecycle\_policy](#input\_efs\_ia\_lifecycle\_policy) | n/a | `string` | `null` | no |
| <a name="input_efs_kms_key_arn"></a> [efs\_kms\_key\_arn](#input\_efs\_kms\_key\_arn) | n/a | `string` | `null` | no |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | n/a | `string` | `"generalPurpose"` | no |
| <a name="input_efs_provisioned_throughput_in_mibps"></a> [efs\_provisioned\_throughput\_in\_mibps](#input\_efs\_provisioned\_throughput\_in\_mibps) | n/a | `number` | `null` | no |
| <a name="input_efs_subnet_ids"></a> [efs\_subnet\_ids](#input\_efs\_subnet\_ids) | A list of subnets to attach to the EFS mountpoint | `list(string)` | `null` | no |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | n/a | `string` | `"bursting"` | no |
| <a name="input_jenkins_controller_cpu"></a> [jenkins\_controller\_cpu](#input\_jenkins\_controller\_cpu) | n/a | `number` | `2048` | no |
| <a name="input_jenkins_controller_memory"></a> [jenkins\_controller\_memory](#input\_jenkins\_controller\_memory) | n/a | `number` | `4096` | no |
| <a name="input_jenkins_controller_port"></a> [jenkins\_controller\_port](#input\_jenkins\_controller\_port) | n/a | `number` | `8080` | no |
| <a name="input_jenkins_controller_subnet_ids"></a> [jenkins\_controller\_subnet\_ids](#input\_jenkins\_controller\_subnet\_ids) | A list of subnets for the jenkins controller fargate service (required) | `list(string)` | `null` | no |
| <a name="input_jenkins_controller_task_log_retention_days"></a> [jenkins\_controller\_task\_log\_retention\_days](#input\_jenkins\_controller\_task\_log\_retention\_days) | n/a | `number` | `30` | no |
| <a name="input_jenkins_controller_task_role_arn"></a> [jenkins\_controller\_task\_role\_arn](#input\_jenkins\_controller\_task\_role\_arn) | An custom task role to use for the jenkins controller (optional) | `string` | `null` | no |
| <a name="input_jenkins_ecr_repository_name"></a> [jenkins\_ecr\_repository\_name](#input\_jenkins\_ecr\_repository\_name) | Name for Jenkins controller ECR repository | `string` | `"serverless-jenkins-controller"` | no |
| <a name="input_jenkins_jnlp_port"></a> [jenkins\_jnlp\_port](#input\_jenkins\_jnlp\_port) | n/a | `number` | `50000` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `"serverless-jenkins"` | no |
| <a name="input_region"></a> [region](#input\_region) | The target AWS region | `string` | n/a | yes |
| <a name="input_route53_alias_name"></a> [route53\_alias\_name](#input\_route53\_alias\_name) | The CNAME alias for the ALB, if `route53_create_alias` is `true` | `string` | `"jenkins-controller"` | no |
| <a name="input_route53_create_alias"></a> [route53\_create\_alias](#input\_route53\_create\_alias) | Create a CNAME alias for the ALB | `string` | `false` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | An existing zone id to place the alias in, if `route53_create_alias` is `true` | `string` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A list of environment variables used to populate the secrets section of the<br>Jenkins controller task definition. The map is defined as a environment<br>variable name to SSM value ARN | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An object of tag key value pairs | `map(any)` | `{}` | no |
| <a name="input_template_vars"></a> [template\_vars](#input\_template\_vars) | A map of key/value pairs that will be added to the default set, overriding<br>existing keys, and inected into the jenkins.yaml.tpl file to generate<br>jenkins.yaml | `map(any)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs_access_point_id"></a> [efs\_access\_point\_id](#output\_efs\_access\_point\_id) | The id of the efs access point |
| <a name="output_efs_aws_backup_plan_name"></a> [efs\_aws\_backup\_plan\_name](#output\_efs\_aws\_backup\_plan\_name) | The name of the aws backup plan used for EFS backups |
| <a name="output_efs_aws_backup_vault_name"></a> [efs\_aws\_backup\_vault\_name](#output\_efs\_aws\_backup\_vault\_name) | The name of the aws backup vault used for EFS backups |
| <a name="output_efs_file_system_dns_name"></a> [efs\_file\_system\_dns\_name](#output\_efs\_file\_system\_dns\_name) | The dns name of the efs file system |
| <a name="output_efs_file_system_id"></a> [efs\_file\_system\_id](#output\_efs\_file\_system\_id) | The id of the efs file system |
| <a name="output_efs_security_group_id"></a> [efs\_security\_group\_id](#output\_efs\_security\_group\_id) | The id of the efs security group |
| <a name="output_jenkins_controller_task_role"></a> [jenkins\_controller\_task\_role](#output\_jenkins\_controller\_task\_role) | The ARN of the task role used by or created for the Jenkins controller |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
