terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "mongodb-docker" {
  ami           = "ami-0eb5115914ccc4bc2"
  instance_type = "t2.micro"
  key_name      = "docker_aws_key"
  tags = {
    Name = "aws-docker-mongodb"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo yum install -y git",
      "git clone https://github.com/docker/compose.git /tmp/docker-compose",
      "sudo cp /tmp/docker-compose/bin/docker-compose /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo mkdir -p /opt/docker-compose",
      "sudo chown -R ec2-user:ec2-user /opt/docker-compose",
      "sudo chmod -R 775 /opt/docker-compose",
      "exit"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/lounisord/.ssh/docker_aws_key.pem") 
    host        = self.public_ip
  }
}

resource "null_resource" "copy_docker_compose" {
  depends_on = [aws_instance.mongodb-docker]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/lounisord/.ssh/docker_aws_key.pem") 
    host        = aws_instance.mongodb-docker.public_ip
  }

  provisioner "file" {
    source      = "./docker-compose-mongodb.yml" 
    destination = "/tmp/docker-compose/docker-compose.yml"
  }
}
