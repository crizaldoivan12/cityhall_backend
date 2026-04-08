FROM php:8.2-apache

WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    curl \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set Laravel public folder
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Allow .htaccess overrides
RUN echo '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
</Directory>' >> /etc/apache2/apache2.conf

# Set ServerName to remove warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy project files
COPY . .

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Fix permissions
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache
RUN chmod +x /usr/local/bin/entrypoint.sh

# IMPORTANT: Do NOT rely on EXPOSE 80 for Render

# Start using entrypoint
CMD ["/usr/local/bin/entrypoint.sh"]
