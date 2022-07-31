# R2-D2 - log server

### Function description

Provide logging services for the full line of Easy Flyer products

### Code syntax
The backend is written in coffee


### Startup project

- start mongoDB
- start redis
- sudo npm install
- sudo npm install pm2 (package.json does not need to write pm2 configuration)
- bower install
- gulp

### Release to official version
````
gulp build-pro
````

### Start in production environment:

````
pm2 start package.json
````

### Front-end tools

  1. Use webpack to manage js code dependencies, package and publish js
  2. gulp build and publish css

### Restart service function
The service must be started in pm2 mode to be effective