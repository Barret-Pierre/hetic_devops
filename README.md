# Hetic Devops

Welcome on hetic devops, this repository is used for launch a mongodb database and a Apache Spark Cluster.
It will execute a python script in a venv using docker compose.

## Prerequest

- Install [Docker](https://docs.docker.com/engine/install/)
- Install [Docker-Compose](https://docs.docker.com/compose/install/)
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## Project architecure

Here a view of the project architecture

![Project Architecture](Project)

## Install and run the project localy

1. Clone the repo

```
git clone https://github.com/Barret-Pierre/hetic_devops.git
```

2. Go to the root folder

3. ⚠️ Open your Docker Desktop

4. Run all the containers with docker compose

```
docker-compose up --build
```

This command run an **Apache Spark Cluster**, a **Mongo database** with **UI** and a **Python Application**.

The python application is connected to the Apache Spark Cluster.

### Mongo DB

- MongoDB run on port **:27017** it's not accessible directly but you can go to the UI mongo on `http://localhost:8081`.

### Apache Spark Cluster

- There are two Spark cluster, the first one is the master and the second the worker.
- You can access to Master on `http://localhost:8080`.

### Python Application

- The python container is mount by dockerfile local image. During build dockerfile use `requirements.txt` that regroupe all the python packages necessary.
- The python scrypt in /app folder run a REST API where the Apache Spark Cluster is alive.
- The python application is accessible on `http://localhost:8000`.

## Deploy the project on AWS

This section explain how to esealy deploy the project. For this we use Terraform.
This project contains **two** terraform configs, the root one is for deploy from your local to AWS and other is using by github actions for the CD. This part talking about deploy to AWS from your loacl. If you want to configure your CI/CD go to [CI / CD](#ci--cd).

### First thing first

With this terraform configuration you can deploy Mongo, Spark and the API on AWS EC2, for this you need:

- An AWS Acount
- Install Terraform CLI

### Loggin AWS CLI

For loggin AWS Acount you can use this tutorial [Prerequisites AWS for Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build#prerequisites)

### Configure AWS

For use the terraform you need to configure some element on your AWS Dashbord.

1. Choose the AWS Region, this terraform config is based on `eu-west-3`

2. Create a key-pair it will download a .pem file, you need to save this file in this root folder

3. Create a security group and configure the next endpoint:

- type : SSH
- Port : 22
- Source : Custom 0.0.0.0/0

This will allowed SSH connection with terraform for deploy project.

4. Create a VCP configuration

### Configure your terraform

For run the terraform configuration, you need to update `variables.tf`

1. Update the `vpc_security_group_id` in you terraform variable with your VCP secutiry group id.

2. Update the `key_name` in you terraform variable with the name of the key pair

3. Update the `private_key` in you terraform variable with path of your .pem file link to the key pair

You can esealy change the **region** and the **ami** id in the `varaible.tf` too.

### Deploy from local

On your local, go to root folder of the project

6. Init your terraform

```
terraform init
```

7. Verify your plan

```
terraform plan
```

8. Apply your terraform

```
terraform apply
```

Here you go ! Your cluster are deployed and functionnal for access to your clusters [next section](#mongo).

## Deploy architecure

Here a view of the project architecture

![Deploy Architecture](deploy)

### Mongo

The mongo compose configuration deploy on the MongoDb cluster.
This configuration deploy mongoDB and Mongo Express to interract with mongo.

Where the cluster is up you can access to:

- Mongo Express on `http://<cluster-ip>:8081`

Change the `cluster-ip` by your cluster-ip, accessible on AWS EC2 instance dashboard named **aws_docker_mongo**.

### Spark and Python API

The spark compose configuration deploy on the Spark cluster.
This configuration deploy a Spark Master, one Spark Worker and the Python API.

Where the cluster is up you can access to:

- Spark Master on `http://<cluster-ip>:8080`.
- Python API on `http://<cluster-ip>:8000`.

Change the `cluster-ip` by your cluster-ip, accessible on AWS EC2 instance dashboard named **aws_docker_pyspark**.

## CI / CD

If you want to update your Python APP on the AWS cluster and run test on it automaticaly it's possible. We use Github Actions for that. Read the next section to configure this parts.

### CI and test

The CI is controle by the test.yml file in the workflows directory.
The application is test with Unittest package. The `test_scrypt.py` test an example function to show how it work.

The test will run all the time the project is pushed on the github. You can see the workflows run on Actions section to github.

### CD and terraform deployment

The CD is controle by the deploy.yml file in the workflows directory.
This workflow run two jobs:

- Test
- Deploy

Deploy depends on the test passed. Before use the CD you need to configure your repository.

### Configure Github Repository

In the settings pannel of your repository go to the security section.
Add the next secrets variables:

- AWS_ACCESS_KEY_ID: Your AWS access Key ID
- AWS_SECRET_ACCESS_KEY: Your AWS secret access Key
- AWS_SSH_KEY_NAME: Your AWS key pair name
- AWS_SSH_KEY_PRIVATE: Your AWS private key pair
- AWS_VPC_SECURITY_GROUP_ID: Your AWS VPC security group id

All this secrets variable will be injected in the `deploy.yml` and passed to the terraform variables.

### Push and use

Where you push on the **main** branche, the `deploy.yml` will run.
If the AWS instances already exist terraform will **stop** the container and **update** the application runing on AWS instance.
If not, terraform will **create** the instance, install docker and docker compose and build the image app.

You can see the run logs in the github actions section of your repository.

### Workflow CI / CD

Here a graphic view of the workflow in place

![CI/CD Workflows](workflow)
