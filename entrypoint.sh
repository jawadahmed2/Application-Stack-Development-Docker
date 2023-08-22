#!/bin/bash

# Start php8.1-fpm and nginx
service php7.4-fpm start
nginx -g "daemon off;" &

# Run the Python script
python3 app.py &

# Run the Node.js application
node index.js &

cd /app/vue-project && npm install && npm run dev