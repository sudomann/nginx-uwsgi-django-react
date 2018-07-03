# nginx-uwsgi-django-react
A multi container setup for a nginx-uwsgi-django deployment (construction in progress)

####INCOMPLETE, needs planning and complete rewrite
*TODO and notes as im going*: might need to instruct to remote .git folder, so npm doesn't stop you from ejecting and require git commit untracked changes
        after modularizing settings, you need to wrap the value of BASE_DIR with one more `os.path.dirname()`

##Requirements##
- Docker and Docker Compose
  `Docker version 18.05.0-ce` was used in building this repository
  After being installed, Docker might require root privileges to run
- Python3 and pip3
  Some distributions don't bundle pip3 with their python3 so ensure you have it by running `pip3 --version`
- Django
  It's normally recommended to install from your distribution's package manager, but those are usually not as current as the version you'll get by installing from pip
- npm and npx
- git

### How to deploy your application
  While it's not required for this repository, it's recommended to create a virtual environment so packages installed from here don't interfere with your system packages. That, and installing npm, npx, pip, git and modifying system configuration so Docker does not run as root (as is good practice) are out of the scope of this exercise, so I won't go into how to do any of that.

Clone this repository to your desired work directory on your machine with
```
git clone https://github.com/sudomann/nginx-uwsgi-django-react.git
```

Then move into the right directory
```
cd nginx-uwsgi-django-react/app/
```

Start a Django project,
```
django-admin startproject yourprojectname
python3 yourprojectname/manage.py runserver
```
and ensure it's OK by visiting http://127.0.0.1 in your browser. If you see a default Django page, thens its okay and you can stop the Django development server using CTRL-C in terminal.

Modularize your django project settings (so it's easy to switch from a development to production environment, etc.)

```
cd yourprojectname/yourprojectname
mv
```


###INTRODUCING REACT
We won't be directly writing webpack configuration ourselves though, we will use create-react-app to generate the project boilerplate with all the configurations in it. Think of create-react-app as django-admin startproject command you used to initialize you django project.

For this, first we will install create-react-app sytem-wide using npm. Because we are installing system-wide, we will need superuser permissions.

$ sudo npm install -g create-react-app
