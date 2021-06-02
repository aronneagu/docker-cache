FROM python:3.8.10
WORKDIR /code
COPY main.py /code
RUN ["python","main.py"]
