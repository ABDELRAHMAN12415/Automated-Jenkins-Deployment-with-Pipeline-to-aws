provider "aws" {
  region = "eu-north-1"
}

# Createing a VPC
resource "aws_vpc" "testing" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "testing-vpc"
  }
}

# Createing an Internet Gateway
resource "aws_internet_gateway" "jenkins_gw" {
  vpc_id = aws_vpc.testing.id
}

# Createing a Subnet
resource "aws_subnet" "jenkins_subnet" {
  vpc_id            = aws_vpc.testing.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create a Route Table and Associate it with the Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.testing.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_gw.id
  }
}
resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.public.id
}

# Createing a Security Group for the master instance
resource "aws_security_group" "jenkins_master_sg" {
  vpc_id = aws_vpc.testing.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Jenkins web interface access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outgoing traffic
  }

}

# Createing a Security Group for the node instances
resource "aws_security_group" "jenkins_agents_sg" {
  name = "jenkins-agents-sg"
  vpc_id = aws_vpc.testing.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating IAM role for jenkins to prevent hard coding aws credentials and easier access # Attach the AmazonEC2FullAccess policy to the IAM role
resource "aws_iam_role" "jenkins_role" {
  name               = "jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "jenkins_ec2_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Creating IAM instance profile for jenkins
resource "aws_iam_instance_profile" "jenkins_master_profile" {
  name = "jenkins-master-profile"
  role = aws_iam_role.jenkins_role.name
}

# Uploading the public key to AWS
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = var.jenkins_ssh_public_key                            # tls_private_key.jenkins_key.public_key_openssh
}

# Createing an EC2 instance
resource "aws_instance" "jenkins_master" {
  ami           = "ami-097c5c21a18dc59ea"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.jenkins_subnet.id
  security_groups = [aws_security_group.jenkins_master_sg.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_master_profile.name
  key_name      = aws_key_pair.jenkins_key.key_name

  user_data = <<-EOF
              #!/bin/bash

              # Jenkins user
              sudo useradd -m -s /bin/bash jenkins
              sudo usermod -aG sudo jenkins

              # Create Jenkins home directory
              sudo mkdir -p /var/lib/jenkins
              sudo chown -R jenkins:jenkins /var/lib/jenkins
              sudo chmod 755 /var/lib/jenkins
              export JENKINS_HOME="/var/lib/jenkins" 

              # Update the package repository
              sudo yum update -y

              # Install Java (OpenJDK)
              sudo yum install -y java-17-amazon-corretto

              # Install git
              sudo yum install -y git

              # Install Jenkins
              sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum install -y jenkins
              
              # Assign Jenkins Variables
              export JENKINS_URL="http://localhost:8080"
              export JENKINS_CLI="/usr/local/bin/jenkins-cli.jar"

              # Download the Plugin Installation Manager
              sudo wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar -O /usr/local/bin/pim.jar
              sudo chown root:root /usr/local/bin/pim.jar
              sudo chmod 755 /usr/local/bin/pim.jar

              # Create the jenkins.yaml file with the provided configurations
              cat <<EOT > /var/lib/jenkins/jenkins.yaml
              ${templatefile("jenkins.yaml.tpl", {
                jenkins_username = var.jenkins_username,
                jenkins_password = var.jenkins_password,
                slack_token = var.slack_token,
                region = var.region,
                agent_ami = var.agent_ami,
                agents_instance_cap = var.agents_instance_cap,
                agents_instance_min = var.agents_instance_min,
                slack_domain = var.slack_domain,
                slack_workspace = var.slack_workspace,  
                job_name = var.job_name,
                github_pipeline_uri = var.github_pipeline_uri,
                agent_num_executors = var.agent_num_executors,  
                agents_subnet_id = aws_subnet.jenkins_subnet.id,
              })}
              EOT

              sudo chmod 644 /var/lib/jenkins/jenkins.yaml
              sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml        

              # Create dir for plugins
              sudo mkdir -p /var/lib/jenkins/plugins
              sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
              sudo chmod -R 755 /var/lib/jenkins/plugins

              # Install the specific version of the matrix-project plugin to prevent conflicts
              sudo java -jar /usr/local/bin/pim.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins/ --plugins matrix-project:839.vff91cd7e3a_b_2

              # Install plugins
              for plugin in ${join(" ", var.jenkins_plugins)}; do
                sudo java -jar /usr/local/bin/pim.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins/ --plugins $plugin
              done 

              # Start and enable Jenkins service
              sudo systemctl start jenkins
              sudo systemctl enable jenkins 

              # Install Jenkins CLI
              sudo wget $JENKINS_URL/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI     

              # Upload and apply the ssh.xml file
              echo '${replace(file("credentials.xml"), "'", "'\\''")}' > /var/lib/jenkins/credentials.xml
              sudo chown jenkins:jenkins /var/lib/jenkins/credentials.xml
              sudo chmod 644 /var/lib/jenkins/credentials.xml
              java -jar $JENKINS_CLI -s $JENKINS_URL -auth ${var.jenkins_username}:${var.jenkins_password} create-credentials-by-xml system::system::jenkins _ < /var/lib/jenkins/credentials.xml

        EOF
}

# Terminate Agents when jenkins master gets destroyed
resource "null_resource" "cleanup_nodes" {
    depends_on = [aws_instance.jenkins_master]

    provisioner "local-exec" {
        command = <<EOT
            # Fetch instance IDs by security group
            INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=instance.group-id,Values=${aws_security_group.jenkins_agents_sg.id}" --query "Reservations[*].Instances[*].InstanceId" --output text)
            if [ -n "$INSTANCE_IDS" ]; then
                aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
            fi
        EOT
    }
}

# Output the Jenkins URL
output "jenkins_url" {
  value = "http://${aws_instance.jenkins_master.public_ip}:8080"
}
