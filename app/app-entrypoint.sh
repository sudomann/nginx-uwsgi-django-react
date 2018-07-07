#!/bin/sh
set -e

# start uwsgi server
uwsgi --master --ini $APP_SERVICE_ROOT_DIR/uwsgi.ini
