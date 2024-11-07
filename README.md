# Automated-Deployment-Pipeline-with-Jenkins-and-Docker
Develop a pipeline to automate the build, testing, and deployment of a sample application. Utilize Jenkins for continuous integration, Docker for containerization, and Ansible for configuration management. Implement automated testing and deployment to a cloud environment.

# first you need to install Docker on the local machine  

## Step 1: Update Your Package Indexftyufr
Open your terminal and run:

```
sudo apt update
```

## Step 2: Install Required Packages
Install packages that allow apt to use repositories over HTTPS:

```
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```
## Step 3: Add Docker’s Official GPG Key
Add Docker’s official GPG key to ensure the authenticity of the packages:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

## Step 4: Add Docker Repository
Add the Docker repository to your APT sources:
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
## Step 5: Update Package Index Again
Update the package index again to include the Docker packages:

``` sudo apt update ```
Step 6: Install Docker
Now, install Docker:

```
sudo apt install docker-ce
```
## Step 7: Start and Enable Docker
Start the Docker service and enable it to start at boot:

```
sudo systemctl start docker
sudo systemctl enable docker
```

## Step 8: Verify Docker Installation
Check if Docker is installed correctly by running:

```
sudo docker --version
```

## Step 9: Manage Docker as a Non-Root User
To run Docker commands without sudo, add your user to the docker group:

```
sudo usermod -aG docker $USER
```
You will need to log out and back in for the group change to take effect.

## Step 10: Test Docker
Finally, test your Docker installation with:

```
docker run hello-world
```
# Second we need to install Jenkins as a container 
  ```
 docker run -d -p 8080:8080 -p 5000:5000 -it  -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --name jenkins --restart always -u root jenkins/jenkins:lts
  ```
## Step 2: Installing Plugins via Jenkins Web UI, Access Jenkins Dashboard
    Open your web browser and go to your Jenkins URL. It typically looks like http://localhost:8080 if running locally.
    Log in using your Jenkins credentials.
## Navigate to the Plugin Manager:
     From the Jenkins Dashboard, go to "Manage Jenkins" on the left side.
    Click on "Manage Plugins".
## Search and Install Plugins:
   Go to the Available tab to see all available plugins.
   Use the search bar to find the plugin you want to install.
   Check the checkbox next to the plugin.
   Click on "Install without restart" to install the plugin right away, or "Download now and install after restart" if you prefer to install it after restarting Jenkins.
