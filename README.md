# Automated preconfigured Jenkins Deployment with Pipeline to AWS

This repository provides an automated Jenkins deployment using a pipeline to AWS. It incorporates Docker, NGINX, and Slack integrations. The Jenkins pipeline automates the build and deployment process, including building Docker images, running containers, and sending notifications via Slack.

![Deployment Diagram](https://github.com/ABDELRAHMAN12415/Automated-Jenkins-Deployment-with-Pipeline-to-aws/blob/main/Untitled%20Diagram.drawio.png)

## Features
- **Automated Jenkins Deployment**: A pipeline that automates Jenkins setup, builds Docker images, and deploys applications.
- **GitHub Integration**: Automatically clones a GitHub repository and integrates it into the Jenkins pipeline.
- **Docker Compose**: Configured to use Docker Compose to build and run the NGINX container.
- **Slack Notifications**: Sends build status notifications (success/failure) to Slack channels.
- **AWS Integration**: Terraform configurations to deploy and manage AWS resources, including Jenkins and other infrastructure.
- **Jenkins Configuration as Code (JCasC)**: Automates Jenkins configuration using a YAML file, ensuring that Jenkins is set up consistently with all necessary plugins and security settings.

## File Structure

- **`Jenkinsfile`**: Defines the Jenkins pipeline, including stages for cloning the GitHub repo, building Docker images, deploying containers, and handling notifications.
- **`docker-compose.yml`**: Defines the services, such as NGINX, to be built and deployed using Docker Compose.
- **`newuser.tfvars`**: Terraform variable file for configuring Jenkins credentials, GitHub repository information, and Slack integration.
- **`jenkins.yaml`**: Jenkins Configuration as Code (JCasC) file to set up Jenkins environment, security, and plugin configurations.
- **`index.html`**: The HTML file that gets copied into the NGINX container to serve content.

## Setup Instructions

### Prerequisites
- **AWS Account**: An active AWS account to provision EC2 instances and manage resources.
- **Jenkins**: Jenkins installed and running, with the necessary plugins.
- **Docker & Docker Compose**: Required to build and run the NGINX container.
- **Slack Workspace**: Used for sending build notifications to a Slack channel.
- **GitHub**: The repository to be cloned and used in the Jenkins pipeline.

### Step 1: Jenkins Configuration

1. **Clone the Repository**:
   Clone this repository to your local environment or directly into your Jenkins workspace.

   ```bash
   git clone https://github.com/ABDELRAHMAN12415/Automated-Jenkins-Deployment-with-Pipeline-to-aws.git
   ```

2. **Install Required Jenkins Plugins**:
   Install the following Jenkins plugins:
   - Slack Notification
   - Configuration as Code (JCasC)
   - GitHub Branch Source
   - Docker Workflow
   - EC2 Plugin
   - Git
   - SSH Credentials

3. **Configure Jenkins with JCasC**:
   Use the `jenkins.yaml` file to configure your Jenkins environment automatically. This YAML file contains all of the necessary configuration settings for Jenkins, including plugin installations, security settings, and other configurations that are typically done manually in the Jenkins UI.

   - **Configuration as Code**: JCasC allows you to define your Jenkins setup in a declarative YAML format. By using the `jenkins.yaml` file, you can automate the entire Jenkins configuration process, including:
     - **Plugin Installation**: Plugins like Docker, Slack, and GitHub integration are automatically installed.
     - **Security Settings**: User authentication, authorization, and permissions are configured.
     - **Credentials Management**: Credentials like GitHub tokens, Slack API keys, and Docker credentials are securely stored in Jenkins.
     - **Job Configuration**: Job configurations, including pipeline jobs, can be predefined in the YAML file.
   
   - **How to Apply JCasC**:
     After the `jenkins.yaml` file is ready, you can apply it in Jenkins using the JCasC plugin. The process depends on how you installed Jenkins:
     
     - **Using the JCasC plugin**: Place the `jenkins.yaml` file in the JCasC configuration directory (default: `/var/jenkins_home/casc_configs/`) or specify its path in Jenkins settings.

     - **Manual Application**: Alternatively, you can use the following steps to manually apply the configuration in the Jenkins interface:
       1. Go to **Manage Jenkins** > **Configure System**.
       2. Scroll down to **Configuration as Code** and specify the path to the `jenkins.yaml` file.
       3. Restart Jenkins to apply the changes.

     **Note**: If using Docker for Jenkins, you can mount the `jenkins.yaml` file as a volume, and Jenkins will automatically load the configuration on startup.

4. **Set Up GitHub Credentials**:
   Add your GitHub token in Jenkins as a credential (`GitHub-Token`) for accessing the repository.

5. **Configure Slack Integration**:
   Modify the `slack_token` and `slack_workspace` in the `newuser.tfvars` file for Slack notifications. Ensure that your Jenkins instance is configured to send messages to the Slack channel `#wordpress-pipline`.

### Step 2: AWS Setup (Optional)

1. **Configure Terraform**:
   If you are deploying the infrastructure on AWS, modify the `newuser.tfvars` file with the required values such as AWS region, instance details, and security settings.

2. **Deploy AWS Infrastructure**:
   Run the following Terraform commands to deploy resources:

   ```bash
   terraform init
   terraform apply -var-file=newuser.tfvars
   ```

### Step 3: Docker Setup

1. **Build Docker Images**:
   The `docker-compose.yml` defines the NGINX service. Build the Docker images using Docker Compose:

   ```bash
   docker-compose -f docker-compose.yml build
   ```

2. **Run Docker Containers**:
   Start the containers using Docker Compose:

   ```bash
   docker-compose -f docker-compose.yml up -d
   ```

   The NGINX container will be exposed on port `80` and will serve the `index.html` file.

3. **Copy the HTML File to NGINX**:
   During the pipeline execution, the `index.html` file will automatically be copied to the NGINX container:

   ```bash
   docker cp index.html nginx:/usr/share/nginx/html/index.html
   ```

### Step 4: Jenkins Pipeline Execution

Once Jenkins is set up and the pipeline is triggered, the following steps will be executed automatically:

1. **Clone GitHub Repository**:
   The Jenkins pipeline will clone the GitHub repository defined in the pipeline configuration:

   ```groovy
   git url: 'https://github.com/ABDELRAHMAN12415/Automated-Jenkins-Deployment-with-Pipeline-to-aws.git', branch: 'main', credentialsId: 'GitHub-Token'
   ```

2. **Build Docker Images**:
   The pipeline will use Docker Compose to build the required images as specified in the `docker-compose.yml` file:

   ```bash
   docker-compose -f docker-compose.yml build
   ```

3. **Run Docker Compose**:
   The pipeline will run Docker Compose to start the NGINX container:

   ```bash
   docker-compose -f docker-compose.yml up -d
   ```

4. **Copy index.html to NGINX**:
   The pipeline will copy the updated `index.html` into the NGINX container:

   ```bash
   docker cp index.html nginx:/usr/share/nginx/html/index.html
   ```

### Step 5: Slack Notifications

The pipeline will send notifications to the configured Slack channel (`#wordpress-pipline`) based on the build status:

- **Success**: Sends a success message with the build number.
- **Failure**: Sends a failure message with the build number.

Example success message:
```text
Build 1 succeeded!
```

Example failure message:
```text
Build 1 failed!
```

## Customization

- **Jenkins Configuration**: Modify the `jenkins.yaml` file to change Jenkins settings, add more credentials, or modify the Jenkins environment.
- **Terraform Configuration**: Edit the `newuser.tfvars` file to adjust AWS configuration, EC2 settings, or IAM roles.
- **Docker Configuration**: You can modify the `docker-compose.yml` to change the services or configuration for your application.

## Conclusion

This repository automates the deployment of Jenkins, Docker, and NGINX with an integrated pipeline for AWS. It ensures that all stages—cloning, building, deploying, and notifying—are done automatically, with minimal manual intervention. The system is extensible, allowing you to customize it for your specific needs, whether for local development or cloud deployments.
