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
# 3.a - INSTALL postgresql client so that psycopg will be enable to connect to postgresql (also add jpeg-dev for image)
# 3.b - INSTALL virtual dependancy package. Groups the packages that will be installed to .tmp-build-deps (also add zlib zlib-dev for image)
# 4 - Install all requirements
# 5 - If DEV, install requirements-dev
# 6 - Remove tmp directory, remove extra dependancies so that it is lightweight.
# 7 - Remove .tmp-build-deps inside dockerfile so that this will be lightweight and clean
# 8 - Add user inside image. DO NOT USE the root user when running the application.
# 9 and 10 - Add directories for static and media files
# 11 - change owner of the directory and subdirectories. -R means recursive
# 12 - change mode/permission: owner and group can make changes in that directory
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

ENV PATH="/py/bin:$PATH"

# Username: django-user
USER django-user
