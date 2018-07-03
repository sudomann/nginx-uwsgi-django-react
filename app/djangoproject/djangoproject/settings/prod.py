from .base import *
DEBUG = config('DEBUG', default=False, cast=bool)

STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "assets"),
]

WEBPACK_LOADER = {
    'DEFAULT': {
            'BUNDLE_DIR_NAME': 'bundles/',
            'STATS_FILE': os.path.join(BASE_DIR, 'webpack-stats.prod.json'),
        }
}
SECRET_KEY = config('SECRET_KEY')
STATIC_ROOT = config('STATIC_ROOT')
