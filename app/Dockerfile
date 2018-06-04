FROM alpine:3.7

RUN apk update && apk add \
  bash \
  python3 \
	python3-dev \
	gcc \
	build-base \
	linux-headers \
	pcre-dev \
	musl-dev \
	libxml2-dev \
	libxslt-dev \
	curl \
	supervisor && \
	python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache

# install uwsgi before any further changes, since this takes a while
RUN pip3 install uwsgi

# copy requirements.txt file in the directory containing this
# Dockerfile (on host machine) to /home/app/ in the container's file system
# and install its contents
COPY requirements.txt /home/app/
# and then run pip install BEFORE adding the rest of your code
# this will prevent Docker's caching mechanism from re-installing (all your)
# dependencies when you make small changes to you requirements.txt file
RUN pip3 install -r /home/app/requirements.txt

# copy all files in the directory containing this Dockerfile (on host machine)
# to /home/app/ in the container's file system
COPY . /home/app/

WORKDIR /home/app/

# the `startproject` command below is only here to have the
# default django page show up on first run
# (if this repository has not been modified) thus confirming
# this setup works.
# Normally, you would copy your app folder into /home/app/ (in container)
RUN django-admin.py startproject mydjangoproject
# and then remove this^ command

# start uwsgi
ENTRYPOINT uwsgi --master --ini /home/app/uwsgi.ini
