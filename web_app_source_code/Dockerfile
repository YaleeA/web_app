FROM python:3.12-slim

WORKDIR /web_app_elk
COPY . .
RUN apt-get update -y && apt-get upgrade -y
RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "web_app.py"]


