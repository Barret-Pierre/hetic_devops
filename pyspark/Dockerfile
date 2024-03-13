FROM python:3.8

# Installer Java
RUN apt-get update && \
    apt-get install -y default-jdk && \
    rm -rf /var/lib/apt/lists/*

# Définir JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/default-java

WORKDIR /app

COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt


COPY ./app/main.py /app

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]