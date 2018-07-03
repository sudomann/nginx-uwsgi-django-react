ARG APP_SERVICE_BASE_IMG_TAG
FROM alpine:$APP_SERVICE_BASE_IMG_TAG

RUN apk update && apk add \
  bash \
  python3 \
	python3-dev \
	gcc \
	build-base \
	linux-headers \
	pcre-dev \
	nodejs \
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

# install uwsgi and create react app before any further changes, since these take a while
RUN pip3 install uwsgi

ARG APP_SERVICE_ROOT_DIR
ARG DJANGO_PROJECT_NAME

# copy requirements.txt file in the directory containing this
# Dockerfile (on host machine) to $APP_SERVICE_ROOT_DIR/ in the container's file system
# and install its contents
COPY requirements.txt $APP_SERVICE_ROOT_DIR/
# and then run pip install BEFORE adding the rest of your code
# this will prevent Docker's caching mechanism from re-installing (all your)
# dependencies when you make small changes to you requirements.txt file
RUN pip3 install -r $APP_SERVICE_ROOT_DIR/requirements.txt

WORKDIR $APP_SERVICE_ROOT_DIR/
# copy all files in the directory containing this Dockerfile (on host machine)
# to $APP_SERVICE_ROOT_DIR/ in the container's file system

COPY $DJANGO_PROJECT_NAME $APP_SERVICE_ROOT_DIR/$DJANGO_PROJECT_NAME/
COPY requirements.txt uwsgi.ini app-entrypoint.sh $APP_SERVICE_ROOT_DIR
RUN chmod +x app-entrypoint.sh
#COPY $DJANGO_PROJECT_NAME/static_dir/ $DJANGO_PROJECT_NAME/static_dir/

#these should be run in dev and not done in docker
#RUN python3 $APP_SERVICE_ROOT_DIR/$DJANGO_PROJECT_NAME/manage.py migrate
#RUN python3 $APP_SERVICE_ROOT_DIR/$DJANGO_PROJECT_NAME/manage.py collectstatic

# start uwsgi
#ENTRYPOINT $APP_SERVICE_ROOT_DIR/app-entrypoint.sh
ENTRYPOINT uwsgi --master --ini $APP_SERVICE_ROOT_DIR/uwsgi.ini
