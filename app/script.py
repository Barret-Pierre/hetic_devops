from pyspark.sql import SparkSession

SparkSession.builder.master("local[*]").getOrCreate().stop()
