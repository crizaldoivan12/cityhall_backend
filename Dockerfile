FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Copy project
COPY . .

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
RUN composer install

# Set Apache to serve Laravel public folder
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite

EXPOSE 80