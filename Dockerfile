FROM nginx:1.13.10-alpine

# Install required packages and remove the apt packages cache when done.
#apk update && apk upgrade && \
RUN apk update && apk add \
    bash=4.4.19-r1 \
    git=2.15.0-r1 \
	openssh=7.5_p1-r8 \
	python3=3.6.3-r9 \
	python3-dev=3.6.3-r9 \
	build-base=0.5-r0 \
	linux-headers=4.4.6-r2 \
	postgresql-dev=10.3-r0 \
	musl-dev=1.1.18-r3 \
	libxml2-dev=2.9.7-r0 \
	supervisor=3.3.3-r1 && \
	python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache && \
    pip3 install uwsgi

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.project.default.conf /etc/nginx/conf.d/default.conf

# Allow HTTPS traffic in/out of container
EXPOSE 443
# port 80 was already opened in nginx:1.13.10-alpine Dockerfile 