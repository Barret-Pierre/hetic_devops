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
  region = "eu-west-3"
}

resource "aws_instance" "mongodb-docker" {
  ami           = "ami-0b7282dd7deb48e78"
  instance_type = "t2.micro"
  key_name      = "tp_devops"
  tags = {
    Name = "aws_docker_mongo"
  }
  vpc_security_group_ids = [ "sg-0b382662fbf5c3b45" ]
}

resource "null_resource" "install_docker" {
  depends_on = [aws_instance.mongodb-docker]

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Faire attention, change en fonction des AIM
    private_key = file("./tp_devops.pem")  # Fichier de la clé privée
    host        = aws_instance.mongodb-docker.public_ip
  }

  provisioner "file" {
    source      = "./install_docker.sh"  # Chemin de la source
    destination = "/tmp/install_docker.sh"  # Le chemin sur l'instance EC2 où copier le fichier
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh", # Assure que le scrypt soit executable
      "/tmp/install_docker.sh" # Exécute le script shell
    ]
  }
}

resource "null_resource" "deploy_mongo" {
  depends_on = [null_resource.install_docker]

  count = 1
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./tp_devops.pem") 
    host        = aws_instance.mongodb-docker.public_ip
  }

  provisioner "file" {
    source      = "./mongo/docker-compose-mongo.yml" 
    destination = "./docker-compose-mongo.yml"  
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f docker-compose-mongo.yml up --build -d",
    ]
  }
}


