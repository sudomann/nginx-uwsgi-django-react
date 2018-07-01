#!/bin/#!/usr/bin/env bash
set -e

# start uwsgi server using django's production_settings
env DJANGO_SETTINGS_MODULE=sampledjangoproject.production_settings uwsgi --master --ini $APP_SERVICE_ROOT_DIR/uwsgi.ini
