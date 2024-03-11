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

resource "aws_instance" "spark-docker" {
  ami           = "ami-0eb5115914ccc4bc2"
  instance_type = "t2.micro"
  key_name      = "default_key"
  tags = {
    Name = "aws-docker-spark"
  }

  vpc_security_group_ids = ["sg-00eb0fd0b00206c5f"]
  
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
    private_key = file("C:/Users/Maxen/.ssh/id_rsa")  # A changer
    host        = self.public_ip
  }
}

resource "null_resource" "install_docker_compose" {
  depends_on = [aws_instance.spark-docker]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Maxen/.ssh/id_rsa")  # A changer
    host        = aws_instance.spark-docker.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "docker-compose --version",  
    ]
  }
}


resource "null_resource" "copy_docker_compose" {
  depends_on = [null_resource.install_docker_compose]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Maxen/.ssh/id_rsa")  # A changer
    host        = aws_instance.spark-docker.public_ip
  }

  provisioner "file" {
    source      = "./docker-compose-spark.yml" 
    destination = "/home/ec2-user/docker-compose-spark.yml"
  }

  provisioner "file" {
    source      = "./requirements.txt"
    destination = "/home/ec2-user/requirements.txt"
  }

  provisioner "file" {
    source      = "./Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
  }

  provisioner "file" {
    source      = "./script.py"
    destination = "/home/ec2-user/script.py"
  }
}

resource "null_resource" "execute_docker_compose" {
  depends_on = [null_resource.copy_docker_compose]

  count = 1
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Maxen/.ssh/id_rsa")  # A changer
    host        = aws_instance.spark-docker.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "docker-compose -f docker-compose-spark.yml up --build -d",
    ]
  }
}