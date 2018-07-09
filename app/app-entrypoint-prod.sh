#!/bin/sh
set -e

python3 $DJANGO_PROJECT_NAME/manage.py migrate --setting=$DJANGO_PROJECT_NAME.settings.${CURRENT_ENV} --no-input
python3 $DJANGO_PROJECT_NAME/manage.py collectstatic --setting=$DJANGO_PROJECT_NAME.settings.${CURRENT_ENV} --no-input

# start uwsgi server
uwsgi --master --ini $APP_SERVICE_ROOT_DIR/uwsgi.ini
