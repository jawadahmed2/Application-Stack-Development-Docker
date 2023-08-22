FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get install -y \
    nginx \
    php7.4-fpm \
    php7.4-cli \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-curl \
    postgresql-client \
    composer \
    nodejs \
    npm \
    python3 \
    python3-pip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Configure PHP-FPM
RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php/7.4/fpm/pool.d/www.conf

# Create Laravel project directory
RUN composer create-project --prefer-dist laravel/laravel /var/www/laravel

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies
RUN npm install

# Install the 'express' module
RUN npm install express

# Copy Vue.js project files
COPY vue-project /app/vue-project

# Build the Vue.js project (you may need to customize this based on your Vue.js project's build process)

# Copy Flask application
COPY app.py /app/app.py
COPY templates /app/templates

# Install Python dependencies
RUN pip install flask mysql.connector mysql-connector-python

# Copy all source code to the working directory
COPY . .

# Copy index.php file to Laravel public directory
COPY index.php /var/www/laravel/public

# Copy Nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Set PostgreSQL environment variables for Laravel
ENV PG_HOST postgres-container
ENV PG_DATABASE mydatabase
ENV PG_USER myuser
ENV PG_PASSWORD mypassword

# Define environment variables for MySQL connection
ENV MYSQL_HOST=mysql \
    MYSQL_USER=root \
    MYSQL_PASSWORD=password \
    MYSQL_DB=mydatabase

# Expose port 8080 for Laravel
EXPOSE 8000

# Set the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Run the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
