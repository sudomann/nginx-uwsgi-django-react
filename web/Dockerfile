FROM nginx:1.14.0-alpine
#this^ was the stable as of 12:40 EST June 02 2018
#FROM alpine:3.7

RUN apk update && apk add nginx

# setup all the configfiles
COPY nginx.conf /etc/nginx/nginx.conf
COPY uwsgi_params /etc/nginx/
COPY nginx-app.conf /etc/nginx/conf.d/default.conf


#STOPSIGNAL SIGTERM

ENTRYPOINT ["nginx", "-g", "daemon off;"]
