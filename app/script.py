import os
from pyspark.sql import SparkSession


# Variables d'environnement
spark_master = os.environ["SPARK_MASTER"]

# Connection au cluster Apache Spark
SparkSession.builder.master(spark_master).getOrCreate().stop()
print("Spark connected")
