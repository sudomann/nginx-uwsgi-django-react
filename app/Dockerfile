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

COPY requirements.txt $APP_SERVICE_ROOT_DIR/
# run pip install BEFORE adding the rest of your code
# this will prevent Docker's caching mechanism from re-installing (all your)
# dependencies when you make small changes to you requirements.txt file
RUN pip3 install -r $APP_SERVICE_ROOT_DIR/requirements.txt

WORKDIR $APP_SERVICE_ROOT_DIR/
COPY $DJANGO_PROJECT_NAME $APP_SERVICE_ROOT_DIR/$DJANGO_PROJECT_NAME/
COPY uwsgi.ini $APP_SERVICE_ROOT_DIR

ARG CURRENT_ENV
COPY app-entrypoint-$CURRENT_ENV.sh $APP_SERVICE_ROOT_DIR/$DJANGO_PROJECT_NAME/
RUN chmod +x $APP_SERVICE_ROOT_DIR/$DJANGO_PROJECT_NAME/app-entrypoint-$CURRENT_ENV.sh
