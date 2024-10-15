
variable "jenkins_username" {
  description = "Jenkins username"
  type        = string
  default     = "admin"  # Default value
}

variable "jenkins_password" {
  description = "Jenkins password"
  type        = string
  default     = "admin"  # Default value
}

variable "jenkins_plugins" {
  description = "List of Jenkins plugins to install"
  type        = list(string)
  default     = ["git", "workflow-aggregator", "github-branch-source", "GitHub", " "]  # Add more plugins as needed
}

variable "github_job_uri" {
  description = "jenkins_job_github_uri"
  type        = string
  default     = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/job-config/config.xml"  # Default value
}

variable "github_cloud_node_uri" {
  description = "jenkins_cloud_node_github_uri"
  type        = string
  default     = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/cloud-node-config/casc.yaml"  # Default value
}