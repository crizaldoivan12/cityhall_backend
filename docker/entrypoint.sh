#!/bin/sh
set -e

cd /var/www/html

echo "Starting Laravel container..."

# Clear config ONLY (safe before DB)
php artisan config:clear

# Run migrations first (creates tables)
echo "Running migrations and seeders..."
php artisan migrate --seed --force --no-interaction

# NOW it's safe to touch cache
echo "Optimizing Laravel..."
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Starting Apache..."
exec apache2-foreground