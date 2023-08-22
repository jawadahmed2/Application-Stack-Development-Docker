# Application-Stack-Development-Docker
Develop a full-stack application using Docker, Nginx, Postgres, MongoDB, Redis, and Python.

### Here we use the ubuntu:20.04 image

### 1. Python
	Following are the commands used
	```# First install the libraries of python3 and flask```
  ```RUN pip install flask```
	```COPY app.py /app/app.py```
	```COPY templates /app/templates```
	

### 2. Node
 	The following Commands are used to configure and run Node 
	```WORKDIR /app```
 	```Copy package.json and package-lock.json to the working directory```
	```COPY package*.json ./```
	```RUN npm install```
    	```RUN npm install express```

### 3. Vue.js
	Vue.js project was made using the following commands
		npm install -g vue-cli
		vue init webpack my-vue-project
		cd my-vue-project
		npm install
		npm run dev
	and it was configured in the Dockerfile using
	```Node project is configured in Dockerfile using the following commands.
	```COPY my-vue-project /app/my-vue-project
### 4. Laravel
	```RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
	```# Configure PHP-FPM
	```RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php/7.4/fpm/pool.d/www.conf
	```# Create Laravel project directory
	```RUN composer create-project --prefer-dist laravel/laravel /var/www/laravel
	
### The entrypoint of the Dockerfile is defined using: 
	```# Set the entrypoint script
	```COPY entrypoint.sh /app/entrypoint.sh
	```RUN chmod +x /app/entrypoint.sh
	```# Run the entrypoint script
	```ENTRYPOINT ["/app/entrypoint.sh"]
	
	
## docker-compose.yml

docker-compose.yml file consists of configuration for
### 1. all-apps container
	all-apps is configured using the following commands
	services:
  all-apps:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: mongo
    restart: always
### 2. mongo container
	Mongo is configured using the following commands
	services:
  all-apps:
    build:
      context: ./mongodocker
      dockerfile: Dockerfile
    container_name: mongodb
    restart: always
### 3. postgreSql container
	postgreSql is configured using the following commands
	services:
  all-apps:
    build:
      context: ./postgreSql
      dockerfile: Dockerfile
    container_name: postgreSql
    restart: always
### 4. redis container
	redis is configured using the following commands
	services:
  all-apps:
    build:
      context: ./redis
      dockerfile: Dockerfile
    container_name: redis
    restart: always

## Nginx Server configurations
Laravel Project is running on default '/' path
pyhton project is running on '/python'
node project is running on '/node'
Vue.js project is running on '/vue'

Nginx configuration is done using:
		location /"route" {
			proxy_pass http://localhost:8080/;  # Assuming the project runs on port 8080
			proxy_set_header Host $host;
		    }

