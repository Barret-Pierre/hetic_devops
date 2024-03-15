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

resource "aws_instance" "mongodb-docker" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  tags = {
    Name = "aws_docker_mongo"
  }
  vpc_security_group_ids = [var.vpc_security_group_id]
  monitoring             = true

  connection {
    type        = "ssh"
    user        = "ec2-user" # Faire attention, change en fonction des AIM
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./install_docker.sh"    # Chemin de la source
    destination = "/tmp/install_docker.sh" # Le chemin sur l'instance EC2 où copier le fichier
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh", # Assure que le scrypt soit executable
      "/tmp/install_docker.sh"           # Exécute le script shell
    ]
  }
}

resource "null_resource" "deploy_mongo" {
  depends_on = [aws_instance.mongodb-docker]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
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

##### PYSPARK #####

resource "aws_instance" "spark-pyspark" {
  ami           = "ami-0b7282dd7deb48e78"
  instance_type = "t2.micro"
  key_name      = var.key_name
  tags = {
    Name = "aws_docker_pyspark"
  }
  vpc_security_group_ids = [var.vpc_security_group_id]
  monitoring             = true

  connection {
    type        = "ssh"
    user        = "ec2-user" # Faire attention, change en fonction des AMI
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./install_docker.sh"    # Chemin de la source
    destination = "/tmp/install_docker.sh" # Le chemin sur l'instance EC2 où copier le fichier
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh", # Assure que le scrypt soit executable
      "/tmp/install_docker.sh"           # Exécute le script shell
    ]
  }
}

resource "null_resource" "deploy_pyspark" {
  depends_on = [aws_instance.spark-pyspark]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.spark-pyspark.public_ip
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

# Cloudwatch Monitoring
resource "aws_cloudwatch_metric_alarm" "mongodb_cpu_utilization_alarm" {
  alarm_name          = "mongodb-cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors CPU utilization on MongoDB instance"

  dimensions = {
    InstanceId = aws_instance.mongodb-docker[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "spark_pyspark_cpu_utilization_alarm" {
  alarm_name          = "spark-pyspark-cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors CPU utilization for Spark PySpark instance"

  dimensions = {
    InstanceId = aws_instance.spark-pyspark[0].id
  }
}

