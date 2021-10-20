
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install java-1.8.0 -y
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo service jenkins start
