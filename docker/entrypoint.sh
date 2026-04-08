#!/bin/sh
set -e

cd /var/www/html

echo "Starting Laravel container..."

# Clear cached config (important for env vars)
php artisan config:clear
php artisan cache:clear

# Run migrations and seeders
echo "Running migrations and seeders..."
php artisan migrate --seed --force --no-interaction

# Optimize Laravel
echo "Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Starting Apache..."
exec apache2-foreground