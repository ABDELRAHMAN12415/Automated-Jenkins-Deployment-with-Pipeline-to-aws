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
resource "aws_subnet" "sub1" {
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
  subnet_id      = aws_subnet.sub1.id
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
# resource "aws_security_group" "jenkins_agents_sg" {
#   name = "jenkins-agents-sg"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Creating IAM role for jenkins to prevent hard coding aws credentials and easier access # Attach the AmazonEC2FullAccess policy to the IAM role
resource "aws_iam_role" "jenkins_role" {
  name               = "jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"  # or specify the Jenkins instance here
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

# Createing ssh key pair
resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Uploading the public key to AWS
# resource "aws_key_pair" "jenkins_key" {
#   key_name   = "jenkins-ssh-key"
#   public_key = tls_private_key.jenkins_key.public_key_openssh
# }

# Createing an EC2 instance
resource "aws_instance" "jenkins_master" {
  ami           = "ami-097c5c21a18dc59ea"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.sub1.id
  security_groups = [aws_security_group.jenkins_master_sg.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_master_profile.name
  # credit_specification {
  #    cpu_credits = "standard"
  # }

  user_data = <<-EOF
              #!/bin/bash

              # Jenkins user
              sudo useradd -m -s /bin/bash jenkins
              sudo usermod -aG sudo jenkins

              # Create Jenkins home directory
              sudo mkdir -p /var/lib/jenkins
              sudo chown -R jenkins:jenkins /var/lib/jenkins

              # Update the package repository
              sudo yum update -y

              # Install Java (OpenJDK)
              sudo yum install -y java-17-amazon-corretto

              # Install git
              sudo yum install -y git

              # Add the Jenkins repo to Yum
              sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

              # Install Jenkins
              sudo yum install -y jenkins

              # Start Jenkins service
              sudo systemctl start jenkins

              # Enable Jenkins to start on boot
              sudo systemctl enable jenkins

              # Assign Jenkins Variables
              export JENKINS_URL="http://localhost:8080"
              export JENKINS_CLI="/usr/local/bin/jenkins-cli.jar"
              export INITIAL_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)              

              # Wait for Jenkins to start
              while ! curl -s $JENKINS_URL > /dev/null; do
                sleep 3
              done

              # Install Jenkins CLI
              sudo wget $JENKINS_URL/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI

              # Create a Jenkins user
              echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"${var.jenkins_username}\", \"${var.jenkins_password}\")" | \
              java -jar $JENKINS_CLI -s $JENKINS_URL -auth admin:$INITIAL_ADMIN_PASSWORD groovy =

              # Install plugins
              for plugin in ${join(" ", var.jenkins_plugins)}; do
                java -jar $JENKINS_CLI -s $JENKINS_URL -auth ${var.jenkins_username}:${var.jenkins_password} install-plugin $plugin
              done          

              # Wait for Jenkins to restart
              sudo systemctl restart jenkins
              while ! curl -s $JENKINS_URL > /dev/null; do
                sleep 3
              done

              # Download the initial-job config.xml file
              sudo curl -o /tmp/config.xml ${var.github_job_uri}

              # Download the cloud-node casc.yaml file
              sudo curl -o /var/lib/jenkins/casc.yaml ${var.github_cloud_node_uri}

              # Set permissions for config.xml and casc.yaml files
              sudo chmod 644 /tmp/config.xml
              sudo chown jenkins:jenkins /tmp/config.xml
              sudo chmod 644 /var/lib/jenkins/casc.yaml
              sudo chown jenkins:jenkins /var/lib/jenkins/casc.yaml

              # Update Jenkins service with environment variables
              sudo mkdir -p /etc/systemd/system/jenkins.service.d
              sudo bash -c 'cat << EOF > /etc/systemd/system/jenkins.service.d/override.conf
              [Service]
              Environment="JENKINS_JAVA_OPTIONS=-Djenkins.install.runSetupWizard=false"
              Environment="JENKINS_CASC_JENKINS_CONFIG=/var/lib/jenkins/casc.yaml"
              Environment="JAVA_ARGS=-Djava.awt.headless=true"
              EOF'

              # Reload systemd to apply the changes
              sudo systemctl daemon-reload

              # Restart Jenkins to apply new settings
              sudo systemctl restart jenkins
              while ! curl -s $JENKINS_URL > /dev/null; do
                sleep 3
              done

              # After downloading and applying the casc.yaml configuration
              java -jar $JENKINS_CLI -s $JENKINS_URL -auth ${var.jenkins_username}:${var.jenkins_password} reload-jcasc-configuration

              # Run the Jenkins CLI command to create a job using the downloaded config.xml
              java -jar $JENKINS_CLI -s $JENKINS_URL -auth ${var.jenkins_username}:${var.jenkins_password} create-job initial_job < /tmp/config.xml

              # Inject the public key generated by Terraform
              sudo mkdir -p /home/jenkins/.ssh
              sudo chown -R jenkins:jenkins /home/jenkins/.ssh
              sudo chmod 700 /home/jenkins/.ssh
              echo "${tls_private_key.jenkins_key.public_key_openssh}" | sudo tee /home/jenkins/.ssh/authorized_keys > /dev/null
              sudo chmod 600 /home/jenkins/.ssh/authorized_keys
              sudo chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys

        EOF

  # Provisioner to run commands after instance creation
  provisioner "remote-exec" {
    inline = [
      "echo 'instance provisioning and configurations is done'",
    ]

    connection {
      type        = "ssh"
      user        = "jenkins"  # Change to the appropriate user
      private_key = tls_private_key.jenkins_key.private_key_pem
      host        = self.public_ip
    }
  }
}

# Output the Jenkins URL
output "jenkins_url" {
  value = "http://${aws_instance.jenkins_master.public_ip}:8080"
}

#java -jar /usr/local/bin/jenkins-cli.jar -s http://localhost:8080 -auth a:a list-jobs
# # Disable master node
# java -jar $JENKINS_CLI -s $JENKINS_URL -auth ${var.jenkins_username}:${var.jenkins_password} offline-node "(master)" -m "Disabling master node"
# sudo systemctl edit jenkins
# sudo java -jar /usr/local/bin/jenkins-cli.jar -s http://localhost:8080/ -auth a:a configuration-as-code apply /var/lib/jenkins/casc.yaml
