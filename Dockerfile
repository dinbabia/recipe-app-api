FROM python:3.9-alpine3.13
LABEL maintainer="dinbabia.pythonanywhere.com"

# RECOMMENDED: When running python in docker container
# Do not buffer the output in python
# Output from python will be printed directly to the console
# which prevents any delays of messages getting from python's running application
# to the screen. See logs immediately in the screen during running
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# This will change to true in docker-compose.yml - build > args
ARG DEV=false

# 1 - create env. In case there is conflict
# 2 - Update pip
# 3 - Install all requirements
# 4 - Remove tmp directory, remove extra dependancies so that it is lightweight.
# 5 - Add user inside image. DO NOT USE the root user when running the application.
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

# Username: django-user
USER django-user
