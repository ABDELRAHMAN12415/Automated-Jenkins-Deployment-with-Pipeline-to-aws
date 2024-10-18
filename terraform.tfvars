# newuser.tfvars

jenkins_username = "a"
jenkins_password = "a"
jenkins_plugins = [
  "configuration-as-code",  # Core plugin for JCasC
  "credentials",             # Essential for credential management
  "plain-credentials",       # Required for handling plain credentials
  "git",                     # Needed for Git operations
  "workflow-aggregator",     # Aggregates pipeline-related plugins
  "job-dsl",                 # For job configuration using DSL
  "jobConfigHistory",        # Tracks job configuration changes
  "cloudbees-credentials",   # Enhanced credential management
  "docker-workflow",         # For Docker integration in pipelines
  "github-branch-source",    # For multibranch pipelines with GitHub
  "ssh-credentials",         # For managing SSH keys
  "ec2"               # For creating the cloud agents
]
github_pipeline_uri = "https://github.com/ABDELRAHMAN12415/jenkins.git"
#agent_conf_uri = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/cloud-node-config/jenkins.yaml"