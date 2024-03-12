# Hetic Devops

Welcome on hetic devops, this repository is used for launch a mongodb database and a Apache Spark Cluster.
It will execute a python script in a venv using docker compose.

## Prerequest

- Install [Docker](https://docs.docker.com/engine/install/)
- Install [Docker-Compose](https://docs.docker.com/compose/install/)
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## Install and run the project

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

This command run an **Apache Spark Cluster**, a **Mongo database** with **UI** and a **Python environement** for execute the **scrypt.py** in /app folder.

The scrypt.py create first conneciton with the Apache Spark Cluster.

### Mongo DB

- MongoDB run on port **:27017** it's not accessible directly but you can go to the UI mongo on `http://localhost:8081`.

### Apache Spark Cluster

- There are two Spark cluster, the first one is the master and the second the worker.
- You can access to Master on `http://localhost:8080`.

### Python Script

- The python container is mount by dockerfile local image. During build dockerfile use `requirements.txt` that regroupe all the python packages necessary.
- The python script in /app folder run one time where the DB ans Apache Spark Cluster are alive.
- The python container is accessible by docker desktop.

![image](./docs/docker_desktop.png)

- You can reload the execution of the python scrypt in docker desktop.

![image](./docs/reload_python.png)

### Docker compose

Voici un petit rapelle des commande de base.

- Executer un fichier docker compose en particulier

```
docker-compose -f <chemin_du_fichier_docker_compose.yml> up --build
```

- Executer un service en particulier dans un fichier en particulier

```
docker-compose -f <chemin_du_fichier_docker_compose.yml> run <nom_du_service>
```

- Afficher les containers qui tournent

```
docker ps
```

- Afficher tout les containers

```
docker ps -a
```

- Down le docker en cours avec **Ctrl + c**

- Supprimer les ressources inutilisées

```
docker prune
```

## Deploy the project

This section explain how to esealy deploy the project.

### Prerequist

With this terraform configuration you can deploy mongo and spark on AWS EC2, for this you need:

- An AWS Acount
- Install Terraform CLI

### Loggin AWS CLI

For loggin AWS Acount you can use this tutorial [Prerequisites AWS for Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build#prerequisites)

### Deploy Part

For use the terraform you need to configure some element on your AWS Dashbord.

1. Choose the AWS Region this terraform config is based on `eu-west-3`

2. Create a key-pair named `tp_devops` it will download the .pem file, you need to save this file in this root folder

3. Create a security group and configure the next endpoint:

- type : SSH
- Port : 22
- Source : Custom 0.0.0.0/0

This will allowed SSH connection with terraform for deploy project.

4. Update the `vpc_security_group_ids` in you terraform configuration

5. On your local, go to root folder of the project

6. Init your terraform

```
terraform init
```

7. Apply your terraform

```
terraform apply
```

Here you go ! Your cluster are deployed and functionnal for access to your clusters **read the next section**.

### Mongo

The mongo compose configuration deploy on the MongoDb cluster.
This configuration deploy mongoDB and Mongo Express to interract with mongo.

Where the cluster is up you can access to Mongo Express on `http://<cluster-ip>:8081`. Cluster-ip is accessible on AWS EC2 instance dashboard named **aws_docker_mongo**.

### Spark

The spark compose configuration deploy on the Spark cluster.
This configuration deploy a Spark Master, one Spark Worker, a Python envrionnement and create a first connection running the scrypt.py.

Where the cluster is up you can access to Spark Master on `http://<cluster-ip>:8080`. Cluster-ip is accessible on AWS EC2 instance dashboard named **aws_docker_pyspark**.
