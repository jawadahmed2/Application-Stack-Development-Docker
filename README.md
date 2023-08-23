# Application-Stack-Development-Docker
- Develop a full-stack application using Docker, Nginx, Postgres, MongoDB, Redis, and Python.

### Here I used the ubuntu:20.04 image as the base image

### 1. Python
	Following are the commands used to configure the Python server
	
   ```python
     # First install the libraries of python3 and flask
      RUN pip install flask
      COPY app.py /app/app.py
      COPY templates /app/templates
   ```
The above commands configure a Python server using Flask by first installing the Flask library to enable web application development. Subsequently, the commands copy the app.py Python script and the templates directory into the Docker image. The app.py likely contains the application's route definitions and request-handling logic, while the templates directory holds HTML templates used for rendering dynamic content. This setup facilitates running the Flask application within a Docker container.
	

### 2. Node
 	The following Commands are used to configure and run Node 
   ```javascript
       WORKDIR /app
 	   Copy package.json and package-lock.json to the working directory
	   COPY package*.json ./
	   RUN npm install
       RUN npm install express
   ```
The above commands configure and launch a Node.js application using Express within a Docker container. They set the working directory to /app, copy the package.json and package-lock.json files to that directory, and subsequently install the application's dependencies, including the Express framework. This setup prepares the Docker image to effectively run the Node.js application, enabling easy web application development and request handling.

### 3. Vue.js
	Following Commands are used to configure the Vue Js project
  ```javascript		
      npm install -g vue-cli
		vue init webpack vue-project
		cd vue-project
		npm install
		npm run dev
	  and it was configured in the Dockerfile using
	  Node project is configured in Dockerfile using the following commands.
	  COPY vue-project /app/vue-project 
   ```
The above commands configure a Vue.js project within a Docker container by first installing the Vue CLI globally, initializing a new Vue.js project using the Webpack template, installing project dependencies, and running a local development server. Additionally, the project is configured in a Dockerfile by copying the Vue.js project's directory into the Docker image's /app directory. This setup facilitates both local development and Docker-based deployment of the Vue.js application.

### 4. PHP Laravel
 ```bash
    RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin -- 
    filename=composer
	# Configure PHP-FPM
    RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php/7.4/fpm/pool.d/www.conf
	# Create Laravel project directory
	RUN composer create-project --prefer-dist laravel/laravel /var/www/laravel
  ```
The above commands configure a PHP Laravel project within a Docker container. They initiate Composer installation by fetching the installer script and placing it in the /usr/local/bin directory as 'composer'. The PHP-FPM configuration is adjusted to prevent environment clearing, and a Laravel project directory is created using Composer, favoring a distribution package, within the /var/www/laravel path. This series of commands sets up Composer, configures PHP-FPM, and creates a Laravel project directory within a Docker image, facilitating the establishment of a PHP Laravel environment.

### Entrypoint: 
    # Create the entrypoint in order to run the different servers in the background
   ```bash
      # Set the entrypoint script
	  COPY entrypoint.sh /app/entrypoint.sh
	  RUN chmod +x /app/entrypoint.sh
	  # Run the entrypoint script
	  ENTRYPOINT ["/app/entrypoint.sh"]
   ```
The above commands define an entry point for a Docker container, allowing various servers to run concurrently in the background. An entrypoint script named 'entrypoint.sh' is copied into the /app directory within the container. This script is granted executable permissions using chmod +x, and it is set as the entrypoint for the container. When the container starts, the specified entrypoint script, containing the necessary commands, will be executed, effectively initiating and managing the background execution of different servers.

## Docker Compose File
   ### docker-compose.yml file contains the below configuration for Dockerfile and other databases
### 1. All Servers Container
   - all-apps are configured using the following commands in yaml:
  ```yaml
service:
  all-apps:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: all-apps
    restart: always
    environment:
      MONGODB_URI: mongodb://mongodb:27017
    networks:
      - custom_network
    depends_on:
      - mongodb
      - redis
      - custom-postgres
  ```
The above YAML configuration sets up a Docker container named "all-apps" that encompasses multiple applications. This container is built using the specified Dockerfile from the current context and is ensured to restart automatically in case of failures. It is connected to a custom network named "custom_network" and depends on other services such as MongoDB, Redis, and a custom Postgres database. The environment variable MONGODB_URI is configured to establish a connection to a MongoDB instance running on port 27017. The configuration consolidates various applications into a single container, coordinating their interactions and dependencies while utilizing a custom network setup.

### 2. Mongodb container
 - Mongo is configured using the following commands in docker compose file:
 ```yaml
 mongodb:
    build:
      context: ./nodeMongo/MongoDocker
      dockerfile: Dockerfile
    container_name: mongodb
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: rootpassword
    volumes:
      - mongodb-data:/data/db
    networks:
      - custom_network
   ```

The above Docker Compose configuration establishes a MongoDB container referred to as "mongodb". This container is constructed using the specified Dockerfile located in the "MongoDocker" directory. It ensures persistent behavior through restarts, with its credentials configured as the root user and password ("root" and "rootpassword" respectively). Data storage is facilitated using a volume named "mongodb-data" mapped to the "/data/db" directory within the container. The MongoDB container is integrated into the "custom_network" and is part of a multi-container setup, allowing for the organized deployment and management of a MongoDB instance within a specified context.

### 3. Postgresql container
   - PostgreSQL is configured using the following commands:
  ```yaml  
 custom-postgres:
    build:
      context: ./laravel/postgre
      dockerfile: Dockerfile
    container_name: custom-postgres
    restart: always
    networks:
      - custom_network
   ```
The above YAML configuration sets up a PostgreSQL container referred to as "custom-postgres". This container is constructed using the specified Dockerfile found in the "postgre" directory within the Laravel context. It guarantees continuous operation through restarts and is integrated into the "custom_network". This configuration establishes a PostgreSQL database container, which is integral to the overall system setup and facilitates database-related operations within the defined Docker environment.

### 4. Redis container
  - Redis is configured using the following commands:
```yaml
  redis:
    image: redis:latest
    container_name: redis
    restart: always
    networks:
      - custom_network
```
The above YAML configuration establishes a Redis container named "redis". This container utilizes the latest version of the Redis image available on Docker Hub. It is set to restart automatically upon failures and is integrated into the "custom_network". This configuration ensures the deployment of a Redis instance within a containerized environment, enabling the use of Redis-based features and functionalities within the overall system architecture.

## Nginx Configuration for Different Paths:
 -  The Nginx configuration provided sets up reverse proxying for different applications running on various paths. For the Laravel application at "/php", the configuration manages routing to PHP files using the specified FastCGI settings, while also ensuring security through blocking access to .ht files. For the Python application at "/python" and the Node.js application at "/node", the configuration proxies requests to the corresponding ports of the "all-apps" container, with additional settings to support WebSockets for Node.js. Lastly, for the Vue.js application at "/vueapp", two configurations are presented: one for direct proxying to the Vue.js server on port 8080, and another for serving static files using an alias to facilitate Vue Router's client-side routing. Overall, this comprehensive Nginx configuration effectively routes incoming requests to different paths, each directing to the respective application's intended functionality.
 -  
 -  I configured Nginx to proxy different applications running on different paths.
   
    - Laravel: /php
    ```yaml
    #  This Nginx configuration for the Laravel application at the "/php" path sets up routing and handling of PHP files,
    including directing requests through FastCGI to the PHP-FPM service, ensuring secure behavior by denying access to .ht files.
    
    root /var/www/laravel/public;

    index index.php index.html index.htm;
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }      
    ```
    - Python: /python
    ```yaml
    #This Nginx configuration for the Python application at the "/python" path sets up a proxy to forward requests to the "all-apps" container on
    port 5000 where the Python app is assumed to be running.
    # Proxy configuration for Python app
    location /python {
        proxy_pass http://all-apps:5000/;  # Assuming the Python app runs on port 5000
        proxy_set_header Host $host;
    }
     ```
    - Node.js: /node
    ```yaml
    # This Nginx configuration for the Node.js application at the "/node" path sets up a proxy to redirect requests to the "all-apps"
       container on port 3000, and includes settings to support WebSockets and caching bypass for seamless communication with the Node.js app.
    
    # Proxy configuration for Node.js app
    location /node {
        proxy_pass http://all-apps:3000/;  # Assuming the Node.js app runs on port 3000
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    ```
    - Vue.js: /vueapp
    ```yaml
    # This Nginx configuration for the Vue.js application at the "/vueapp" path either proxies requests to the Vue.js server on port 8080 or
    serves static files using an alias, accommodating different deployment approaches for the Vue.js app.
    
    # Serve the Vue.js project
    location /vueapp {
        proxy_pass http://localhost:8080/;  # Assuming the vue app runs on port 8080
        proxy_set_header Host $host;
    }

    # Or we can also configure the vueapp using alias
     location /vueapp {
        alias /path/to/your/vue-app/dist;  # Replace with the actual path to your Vue.js app's build directory
        try_files $uri $uri/ /index.html;
    }
    ```
    
## OUTPUT/ Result:
  - In order to run the above application I run the following commands in the Linux Terminal
    ```bash
        sudo docker-compose build #It is used to build the image
        sudo docker-compose up #It is used to up the image and run the container
    ```
  - Following are the IP used to see the result in the browser
     - 127.0.0.1:500  #default nginx
     - 127.0.0.1:500/python #python server
     - 127.0.0.1:500/node   #node server
     - 127.0.0.1:500/php    #laravel server
     - 127.0.0.1:500/vueapp #vuejs server
