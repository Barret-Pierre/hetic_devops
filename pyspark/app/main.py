import os
from pyspark.sql import SparkSession
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    # Variables d'environnement
    spark_master = os.environ["SPARK_MASTER"]

    # Connection au cluster Apache Spark
    SparkSession.builder.master(spark_master).getOrCreate().stop()
    return "Hello World Spark is connected"

def is_odd(n: int):
    return n % 2 != 0