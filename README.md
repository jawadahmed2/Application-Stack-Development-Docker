# Application-Stack-Development-Docker
- Develop a full-stack application using Docker, Nginx, Postgres, MongoDB, Redis, and Python.

### Here I used the ubuntu:20.04 image as the base image

### 1. Python
	Following are the commands used to run the Python server
	
   ```python
     # First install the libraries of python3 and flask
      RUN pip install flask
      COPY app.py /app/app.py
      COPY templates /app/templates
   ```
	

### 2. Node
 	The following Commands are used to configure and run Node 
   ```javascript
       WORKDIR /app
 	   Copy package.json and package-lock.json to the working directory
	   COPY package*.json ./
	   RUN npm install
       RUN npm install express
   ```

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

### 4. PHP Laravel
 ```bash
    RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin -- 
    filename=composer
	# Configure PHP-FPM
    RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php/7.4/fpm/pool.d/www.conf
	# Create Laravel project directory
	RUN composer create-project --prefer-dist laravel/laravel /var/www/laravel
  ```

### Entrypoint: 
    # Create the entrypoint in order to run the different servers in the background
   ```bash
      # Set the entrypoint script
	  COPY entrypoint.sh /app/entrypoint.sh
	  RUN chmod +x /app/entrypoint.sh
	  # Run the entrypoint script
	  ENTRYPOINT ["/app/entrypoint.sh"]
   ```
	
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
## Nginx Configuration for Different Paths:
 -  I configured Nginx to proxy different applications running on different paths. 
    - Laravel: /php
    ```yaml
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
    # Proxy configuration for Python app
    location /python {
        proxy_pass http://all-apps:5000/;  # Assuming the Python app runs on port 5000
        proxy_set_header Host $host;
    }
     ```
    - Node.js: /node
    ```yaml
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
