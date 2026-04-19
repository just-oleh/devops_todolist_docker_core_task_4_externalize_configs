# Stage 1: Build Stage
ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION} as builder

# Set the working directory
WORKDIR /app
COPY . .

# Stage 2: Run Stage
FROM python:${PYTHON_VERSION} as run

WORKDIR /app

ENV PYTHONUNBUFFERED=1

COPY --from=builder /app .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

EXPOSE 8080

# Wait for MySQL to be ready, then migrate and start
ENTRYPOINT ["sh", "-c", "until python -c \"import mysql.connector; mysql.connector.connect(host='$HOST', port=$PORT, user='$USER', password='$PASSWORD')\" 2>/dev/null; do echo 'Waiting for MySQL...'; sleep 2; done && python manage.py migrate && python manage.py runserver 0.0.0.0:8080"]