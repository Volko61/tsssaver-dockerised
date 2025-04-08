FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (adjust based on TSSSaver requirements)
RUN docker-php-ext-install pdo_mysql

# Set working directory
WORKDIR /var/www

# Clone the TSSSaver repository into a subdirectory
RUN git clone https://github.com/TSSSaver/TSSSaver.git tssaver

# Install Composer dependencies (if required)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www/tssaver
RUN composer install --no-dev --optimize-autoloader || true

# Copy the custom config.php into the inc/ directory
COPY inc/config.php /var/www/tssaver/inc/config.php

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Expose port
EXPOSE 80

# Start PHP-FPM and Nginx
CMD service nginx start && php-fpm