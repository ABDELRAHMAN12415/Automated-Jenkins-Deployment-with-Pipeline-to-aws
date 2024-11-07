
variable "jenkins_username" {
  description = "Jenkins username"
  type        = string
  default     = "admin" 
}

variable "jenkins_password" {
  description = "Jenkins password"
  type        = string
  default     = "admin"
}

variable "region" {
  default = "eu-north-1"
}

variable "jenkins_master_ami" {
  description = "AMI ID for Jenkins EC2 instance"
  default     = "ami-097c5c21a18dc59ea"
}

variable "master_num_executors" {
  description = "Number of executors on the Jenkins master"
  default     = 0
}

variable "jenkins_plugins" {
  description = "List of Jenkins plugins to install"
  type        = list(string)
  default     = ["git", "workflow-aggregator", "github-branch-source", "GitHub", "configuration-as-code", "amazon-ec2"]  # Add more plugins as needed
}

variable "agent_ami" {
  description = "AMI ID for Jenkins agent EC2 instances"
  default     = "ami-08eb150f611ca277f"
}

variable "agent_instance_name" {
  description = "EC2 instance name for Jenkins cloud agent"
  default     = "jenkins_slave"
}

variable "agent_instance_type" {
  description = "EC2 instance type for Jenkins cloud agent"
  default     = "t2.micro"
}

variable "agent_num_executors" {
  description = "Number of executors on the Jenkins master"
  default     = 2
}

variable "agents_instance_min" {
  description = "Number of Jenkins EC2 instances"
  default     = 1
}

variable "agents_instance_cap" {
  description = "Maximum number of instances for Jenkins agents"
  default     = 3
}

variable "github_pipeline_uri" {
  description = "jenkins_initial_job_github_uri"
  type        = string
  default     = "https://github.com/ABDELRAHMAN12415/jenkins.git"
}

variable "github_pipeline_branch_uri" {
  description = "jenkins_initial_job_github_branch_uri"
  type        = string
  default     = "html-and-pipeline-files"
}

variable "job_name" {
  description = "initial_job_name"
  type        = string
  default     = "github_pipeline-job"
}

variable "jenkins_ssh_public_key" {
  description = "jenkins_ssh_public_key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8DI9N2faHkIk+9N/0PTf8c3KNrJxXSRAEA5NrGNQOrbkS4VbEEB2UjTlyQuDHVelKxaxHftTT+7ZhvisKSIyvhMGeuW2l977Wa3x0ARjCNWIQcOIuJUzBE/xbuPFg+RhW+Q7AtvTT8rFDzJ5GJygdu190dYQOIIk9waQHQJKlqXrI/TtKwD4ysoPSQDSBuoVM/i+acNqDFwtMn+h/2AhoXIL6YbUDu6nauWJ29jddul7VbO4a7nfOQlgw6FsFLvYfYJdtNamueYthB8pUs0X7Oov+pW/pLHxCAtoXiB051qn6iof7QHIYwuoqPxLVeV5+HFxskZxKy6VzbCfEEjNp"
}

# variable "agent_conf_uri" {
#   description = "jenkins_cloud_node_conf-file_uri"
#   type        = string
#   default     = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/cloud-node-config/jenkins.yaml"
# }

variable "slack_domain" {
  description = "Slack domain"
  type        = string
}

variable "slack_token" {
  description = "Slack API token"
  type        = string
}

variable "slack_workspace" {
  description = "Slack workspace name"
  type        = string
}
