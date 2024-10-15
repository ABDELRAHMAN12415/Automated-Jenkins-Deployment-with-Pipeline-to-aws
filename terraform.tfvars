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
  "ssh-credentials"          # For managing SSH keys
]
github_job_uri = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/job-config/config.xml"
github_cloud_node_uri = "https://raw.githubusercontent.com/ABDELRAHMAN12415/jenkins/cloud-node-config/casc.yaml"  

#java -jar /usr/local/bin/pim.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins/ --plugins configuration-as-code