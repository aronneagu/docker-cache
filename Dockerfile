FROM ubuntu:20.04
WORKDIR /code
COPY main.py /code
RUN ["python","main.py"]
