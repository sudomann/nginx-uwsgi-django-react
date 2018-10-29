# [DEPRECATED] nginx-uwsgi-django-react
A multi container setup for a nginx-uwsgi-django deployment
*This repositiory is not actively developed anymore*

### Requirements
- Docker and Docker Compose
  - *`Docker version 18.05.0-ce` was used in building this repository*
  - *After being installed, Docker might require root privileges to run*
- Python3 and pip3
  - *Some distributions don't bundle pip3 with their python3 so ensure you have it by running `pip3 --version`*
- npm
- git

### How to deploy your application
  While it's not required for this repository, it's recommended to create a virtual environment so packages installed from here don't interfere with your system packages. That, and installing npm, pip, git and modifying system configuration so Docker does not run as root (as is good practice) are out of the scope of this exercise, so I won't go into how to do any of that.

Clone this repository to your desired work directory on your machine with
```
git clone https://github.com/sudomann/nginx-uwsgi-django-react.git
```
Then move into the right directory
```
cd nginx-uwsgi-django-react/app/djangoproject
```

### Integrating React, Webpack, and Django
We won't be directly writing webpack configuration ourselves though, we will use `create-react-app` to generate the project boilerplate with all the configurations in it. Think of `create-react-app` as `django-admin startproject` command you used to initialize you django project.

For this, first we will install `create-react-app` sytem-wide using `npm`. Because we are installing system-wide, we will need superuser permissions.
```
sudo npm install -g create-react-app
```

Now we create a react application and then `eject` so we can edit the config files.
If you want, you can name your react project something else other than `frontend`, but wherever you see `frontend` from now on, you'll have to replace it with whatever name you chose
```
create-react-app frontend
cd frontend
npm run eject
```
Now check to confirm the following file structure is in place:
```
.
├── config
│   ├── env.js
│   ├── jest
│   │   ├── cssTransform.js
│   │   └── fileTransform.js
│   ├── paths.js
│   ├── polyfills.js
│   ├── webpack.config.dev.js
│   ├── webpack.config.prod.js
│   └── webpackDevServer.config.js
├── package.json
├── public
│   ├── favicon.ico
│   ├── index.html
│   └── manifest.json
├── README.md
├── scripts
│   ├── build.js
│   ├── start.js
│   └── test.js
└── src
    ├── App.css
    ├── App.js
    ├── App.test.js
    ├── index.css
    ├── index.js
    ├── logo.svg
    └── registerServiceWorker.js
```

Now test to see if it works by running `npm run start`
A browser should be launched, and a default page shown at http://localhost:3000
![alt text](http://v1k45.com/images/modern-django-1-react-welcome.png "create-react-app default page")
"This development server has hot loading enabled by default. This means any changes you do in you source files will be instantly reflected in the browser without you having to refresh the page manually again and again."
Leave it running.

If you need to, open a new terminal, and go into the `frontend` folder and run
```
npm install webpack-bundle-tracker --save-dev
```
This installs a plugin that generates a file that Django uses in rendering the react page.

Now, we will be making some react configuration changes for it to work with Django.
*Anytime you're unsure of where to make an edit, consult the `reference` folder at the root of this repository. CTRL-f is your friend :)*

Now, in your `frontend/config/paths.js` add the following key and value in the module.exports object.
```
module.exports = {
  // ... other values
  statsRoot: resolveApp('../'),
}
```
In `frontend/config/webpack.config.dev.js` change `publicPath` and `publicUrl` to http://localhost:3000/ as shown below:
```
const publicPath = 'http://localhost:3000/';
const publicUrl = 'http://localhost:3000/';
```
In the same file, import `webpack-bundle-tracker` and include `BundleTracker` in webpack `plugins` and replace `webpackHotDevClient` line with the other two modules (they are commented out by default.
```
const BundleTracker = require('webpack-bundle-tracker');

module.exports = {
  entry: [
    // ... KEEP OTHER VALUES
    // this will be found near line 30 of the file
    require.resolve('webpack-dev-server/client') + '?http://localhost:3000',
    require.resolve('webpack/hot/dev-server'),
    // require.resolve('react-dev-utils/webpackHotDevClient'),
  ],
  plugins: [
    // this will be found near line 215-220 of the file.
    // ... other plugins
    new BundleTracker({path: paths.statsRoot, filename: 'webpack-stats.dev.json'}),
  ],
}
```

"The reason of replacing `webpackHotDevClient`, `publicPath` and `publicUrl` is that we are going to serve webpack dev server's bundle on a Django page, and we don't want webpack hot loader to send requests to wrong url/host.

Now in `frontend/config/webpackDevServer.config.js` we need to allow the server to accept requests from external origins. http://127.0.01:8000 (Django server) will send XHR requests to http://localhost:3000 webpack server to check for source file changes.

Put `headers` object seen below in the object returned by the `exported` function. This object is to be placed at the same level of `https` and `host` properties."
```
headers: {
  'Access-Control-Allow-Origin': '*'
},
```

Remember doing `npm run start` and leaving it running? Stop that server, and run it again. Then, using another shell if you need to, go back into the directory where `manage.py` is located, and run `python3 manage.py runserver` you should see the same react welcome page as you did after running `npm run start`.

Now, any changes you do in `src/App.js` file will be instantly reflected on the opened page in browser through hot loading.
Replace whatever is in the `App.js` file with the following and save. You can parts of the text and save, and see how it's immediately updated in the browser.
```
import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to My Django-React App!</h1>
        </header>
        <p className="App-intro">
            A react app with django as a backend.
        </p>
      </div>
    );
  }
}

export default App;
```



### Production configuration
Remember "... the Django server will send XHR requests to http://localhost:3000 webpack server to check for source file changes..."?
Well this works so far because when the browser loads the template, it checks for the necessary .js and .css files on the current machine. That's a problem in production, because it means in a browser, your template would be trying to load js and css files from the machine of users who loaded your site. This is only ideal for development, so we're gonna change that.

Notice the directory `assets/bundles/` in Django's base directory. This directory will store all our static assets. The `bundles` sub-directory will be used as build target; Webpack will save all the build files to `assets/bundles/`.
We make this change by modifying webpack's build output dir to `assets/bundles`. In `frontend/config/paths.js` change the `appBuild` value as shown below:
```
// config after eject: we're in ./config/
module.exports = {
  // .. KEEP OTHER VALUES
  appBuild: resolveApp('../assets/bundles/'),
};
```

Now in `frontend/config/webpack.config.prod.js` make the following changes. Some of these will have to be added, others already exist, and will simply need to be modified. Consult the `reference` folder at the root of this repository if you need to, and CTRL-f is your friend :D
```
const BundleTracker = require('webpack-bundle-tracker');

const publicPath = "/static/bundles/";

const cssFilename = 'css/[name].[contenthash:8].css';

module.exports = {
  // KEEP OTHER VALUES
  output: {
    // NEAR LINE 67

    // Generated JS file names (with nested folders).
    // There will be one main bundle, and one file per asynchronous chunk.
    // We don't currently advertise code splitting but Webpack supports it.
    filename: 'js/[name].[chunkhash:8].js',
    chunkFilename: 'js/[name].[chunkhash:8].chunk.js',
  },
  module: {
    // .. KEEP OTHER VALUES, ONLY UPDATE THE FOLLOWING VALUES
    rules: [
      {
        oneOf: [
          // LINE 140
          {
            options: {
              limit: 10000,
              name: 'media/[name].[hash:8].[ext]',
            },
          },
          {
            // LINE 220
            options: {
              name: 'media/[name].[hash:8].[ext]',
            },
          },
        ],
      },
    ],
  },
  plugins: [
    // KEEP OTHER VALUES
    // LINE 320
    new BundleTracker({path: paths.statsRoot, filename: 'webpack-stats.prod.json'}),
  ],
}
```
Here we configured webpack to set `static/bundles/` as `publicPath` because the build files will be stored in `assets/bundles` and `/static/` url (in Django settings) points to the `assets` directory. We also remove static prefixes from filenames and path to prevent unnecessary nesting of build files.

This configures webpack to build all files' directories into `assets/bundles` without creating an additional `static` directory in it.

After saving the the modified `webpack.config.prod.js` file, we can build the project files using the following command:
```
npm run build
```

This will create bunch of files in `assets/bundles` and a `webpack-stats.prod.json` file right outside your `frontend` react project folder (in Django's base directory).

To check if everything was setup properly, we can run Django's development server using production settings with webpack server stopped (remember `npm run start`? stop that server).
```
python manage.py runserver --settings=djangoproject.settings.prod
```

If you check http://127.0.0.1:8000/, you'll see the same page which was rendered when webpack server was running. If you check the source code of the webpage, you'll see the js files are now being served directly through Django and not webpack (the browser looking for the `.js` and `.css` files at `localhost`).

### Important Points
It is better to `build` on your CI server or your deployment server instead of including in version control or source code.

In your development sure to run `python3 manage.py collectstatic` after you build the js files, otherwise your webserver (NGINX, Apache, etc) might not find the build files.

Make sure your build generates a `webpack-stats.prod.json` file. If you are deploy by building the files manually, make sure you also include it when you're copying files from your machine to server.

All the directory and file names specified above are not enforced in any sense. Feel free to change the directory location or file names to your liking, but make sure all config files are properly updated.

Docker-compose files are already configured and ready to with this. Showing how to use docker-compose is out of the scope of this exercise. Docker has extensive reference and documentation at https://docs.docker.com/compose/compose-file/. See the the `.yml` files at the root of this repository to learn more about how to deploy in various environments.

WARNING: In the current state of their configuration, processes in the alpine based containers run with higher privileges than they need. Consider adding users and performing whatever other changes necessary to abide to the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).


Please see http://v1k45.com/blog/modern-django-part-1-setting-up-django-and-react/ for a little more insightful explanation of this react configuration, and subsequent tutorials to extend the functionality of your project.
