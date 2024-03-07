# Hetic Devops

Welcome on hetic devops, this repository is used for launch a mongodb database and a Apache Spark Cluster.
It will execute a python script in a venv using docker compose.

## Prerequest

- Install [Docker](https://docker)
- Install [Docker-Compose](<(https://docker)>)
- Install [Docker Desktop](<(https://docker)>)

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

This command run an **Apache Spark Cluster**, a **Mongo database** and a **Python environement** for execute the **scrypt.py** in /app folder.

The scrypt.py create first conneciton with Apache Spark Cluster.
