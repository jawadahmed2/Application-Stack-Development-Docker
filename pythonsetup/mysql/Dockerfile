# Use the official MySQL image
FROM mysql:8.1

# Set environment variables
ENV MYSQL_ROOT_PASSWORD=password
ENV MYSQL_DATABASE=mydatabase

# Expose the default MySQL port
EXPOSE 3306

# Define a volume for MySQL data
VOLUME /var/lib/mysql

# Start MySQL service
CMD ["mysqld"]
