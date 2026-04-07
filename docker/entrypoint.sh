#!/bin/sh
set -e

cd /var/www/html

echo "Starting Laravel container..."

# Run migrations and seeders on startup.
php artisan migrate --seed --force --no-interaction

php artisan config:clear
php artisan cache:clear
php artisan config:cache

exec apache2-foreground
