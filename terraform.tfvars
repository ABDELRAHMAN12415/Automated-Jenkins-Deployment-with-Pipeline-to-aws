# newuser.tfvars

jenkins_username = "a"
jenkins_password = "a"
jenkins_plugins = [ 
  "slack:latest",                   // to send notifications
  "configuration-as-code:latest",   // Core plugin for JCasC
  "credentials:latest",             // Essential for credential management
  "plain-credentials:latest",       // Required for handling plain credentials
  "git:latest",                     // Needed for Git operations
  "workflow-aggregator:latest",     // Aggregates pipeline-related plugins
  "job-dsl:latest",                 // For job configuration using DSL
  "jobConfigHistory:latest",        // Tracks job configuration changes
  "cloudbees-credentials:latest",   // Enhanced credential management
  "docker-workflow:latest",         // For Docker integration in pipelines
  "github-branch-source:latest",    // For multibranch pipelines with GitHub
  "ssh-credentials:latest",         // For managing SSH keys
  "ec2:latest",                     // For creating cloud agents
  "pipeline-stage-view:latest"      // Stage View Plugin for visualizing pipeline stages
]
github_pipeline_uri = "https://github.com/ABDELRAHMAN12415/Automated-Jenkins-Deployment-with-Pipeline-to-aws.git"
github_pipeline_branch_uri = "html-and-pipeline-files"
#agent_conf_uri = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/cloud-node-config/jenkins.yaml"
slack_domain = "jenkins-fxn3433"
slack_token = "YenlR9C9TqUlTpiEqQssRMe9"
slack_workspace = "#wordpress-pipline"
