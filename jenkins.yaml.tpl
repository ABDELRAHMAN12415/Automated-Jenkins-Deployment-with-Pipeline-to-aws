credentials:
  system:
    domainCredentials:
      - credentials:
          - string:
              description: "jenkins_token"
              id: "Jenkins_Token"
              scope: GLOBAL
              secret: "${slack_token}"
jenkins:
  systemMessage: "Jenkins configured via JCasC"
  numExecutors: 0
  slaveAgentPort: -1
  mode: EXCLUSIVE
  myViewsTabBar: "standard"
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "${jenkins_username}"
          password: "${jenkins_password}"
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
  agentProtocols:
    - "JNLP4-connect"
    - "Ping"
  clouds:
    - amazonEC2:
        instanceCapStr: "4"
        name: "ec2-agent"
        region: "${region}"
        sshKeysCredentialsId: "jenkins_key"
        templates:
          - ami: "${agent_ami}"
            amiType:
              unixData:
                rootCommandPrefix: "sudo"
                slaveCommandPrefix: "sudo"
                sshPort: "22"
            associatePublicIp: true
            connectBySSHProcess: false
            connectionStrategy: PRIVATE_IP
            deleteRootOnTermination: false
            description: "ec2-agent-ami"
            ebsEncryptRootVolume: DEFAULT
            ebsOptimized: false
            hostKeyVerificationStrategy: ACCEPT_NEW
            idleTerminationMinutes: "30"
            initScript: |-
              #!/bin/bash
              # Update the package list
              sudo apt update -y

              # Install prerequisites
              sudo apt install openjdk-11-jdk -y
              sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

              # Add Docker's official GPG key and set up the stable repository
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Update package list again and install Docker and git
              sudo apt upgrade -y
              sudo apt update -y
              sudo apt install -y docker-ce docker-ce-cli containerd.io git

              # Enable and start Docker service
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu 

              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose

              # Apply executable permissions to Docker Compose binary
              sudo chmod +x /usr/local/bin/docker-compose
            instanceCapStr: "${agents_instance_cap}"
            javaPath: "java"
            labelString: "ec2-agent cloud docker"
            maxTotalUses: -1
            metadataEndpointEnabled: true
            metadataHopsLimit: 1
            metadataSupported: true
            metadataTokensRequired: false
            minimumNumberOfInstances: ${agents_instance_min}
            minimumNumberOfSpareInstances: 0
            mode: NORMAL
            monitoring: false
            nodeProperties:
              - diskSpaceMonitor:
                  freeDiskSpaceThreshold: "100MiB"
                  freeDiskSpaceWarningThreshold: "100MiB"
                  freeTempSpaceThreshold: "100MiB"
                  freeTempSpaceWarningThreshold: "100MiB"
            numExecutors: ${agent_num_executors}
            remoteAdmin: "ubuntu"
            remoteFS: "/home/jenkins"
            securityGroups: "jenkins-agents-sg"
            stopOnTerminate: false
            subnetId: "${agents_subnet_id}"
            t2Unlimited: false
            tenancy: Default
            type: T3Micro
            useEphemeralDevices: false
        useInstanceProfileForCredentials: true
unclassified:
  slackNotifier:
    botUser: false
    room: "${slack_domain}"
    sendAsText: false
    teamDomain: "${slack_workspace}"
    tokenCredentialId: "Jenkins_Token"
jobs:
  - script: >
      pipelineJob('${job_name}') {
        description('')
        keepDependencies(false)
        properties {
          githubProjectUrl('${github_pipeline_uri}')
        }
        triggers {
          githubPush()
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url('${github_pipeline_uri}')
                }
                branches('*/main')
                extensions { }
              }
            }
            scriptPath('Jenkinsfile')
            lightweight(true)
          }
        }
        disabled(false)
      }
tool:
  git:
    installations:
      - home: "git"
        name: "Default"
  mavenGlobalConfig:
    globalSettingsProvider: "standard"
    settingsProvider: "standard"
