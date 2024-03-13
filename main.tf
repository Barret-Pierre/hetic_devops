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
  region = var.region
}

###### MONGO #######

data "aws_instances" "existing_mongo" {
  instance_tags = {
    Name = "aws_docker_mongo"
  }
}

resource "aws_instance" "mongodb-docker" {
  count         = length(data.aws_instances.existing_mongo.ids) > 0 ? 0 : 1
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  tags = {
    Name = "aws_docker_mongo"
  }
  vpc_security_group_ids = [ var.vpc_security_group_id ]

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Faire attention, change en fonction des AIM
    private_key = var.private_key
    host        = self.public_ip
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
  count         = length(data.aws_instances.existing_mongo.ids) > 0 ? 0 : 1
  depends_on = [aws_instance.mongodb-docker]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.private_key
    host        = aws_instance.app_server[0].public_ip
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

resource "null_resource" "update_mongo" {
  count         = length(data.aws_instances.existing_mongo.ids) > 0 ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.private_key
    host        = data.aws_instances.existing_mongo.public_ips[0]
  }

  provisioner "file" {
    source      = "./mongo/docker-compose-mongo.yml" 
    destination = "./docker-compose-mongo.yml"  
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker-compose -f docker-compose.yml stop",
      "docker-compose -f docker-compose-mongo.yml up --build -d"
    ]
  }
}

##### PYSPARK #####

data "aws_instances" "existing_spark_pyspark" {
  instance_tags = {
    Name = "aws_docker_pyspark"
  }
}

resource "aws_instance" "spark-pyspark" {
  count         = length(data.aws_instances.existing_spark_pyspark.ids) > 0 ? 0 : 1
  ami           = "ami-0b7282dd7deb48e78"
  instance_type = "t2.micro"
  key_name      = var.key_name
  tags = {
    Name = "aws_docker_pyspark"
  }
  vpc_security_group_ids = [ var.vpc_security_group_id ]

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Faire attention, change en fonction des AIM
    private_key = var.private_key 
    host        = self.public_ip
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

resource "null_resource" "deploy_pyspark" {
  count         = length(data.aws_instances.existing_spark_pyspark.ids) > 0 ? 0 : 1
  depends_on = [aws_instance.spark-pyspark]  

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.private_key
    host        = aws_instance.app_server[0].public_ip
  }

  provisioner "file" {
    source      = "./pyspark/" 
    destination = "./"  
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f docker-compose-spark.yml up --build -d",
    ]
  }
}

resource "null_resource" "update_pyspark" {
  count         = length(data.aws_instances.existing_spark_pyspark.ids) > 0 ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"  
    private_key = var.private_key
    host        = data.aws_instances.existing_spark_pyspark.public_ips[0]
  }

  provisioner "file" {
    source      = "./pyspark/" 
    destination = "./"  
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f docker-compose-spark.yml stop",
      "docker-compose -f docker-compose-spark.yml up --build -d",
    ]
  }
}


