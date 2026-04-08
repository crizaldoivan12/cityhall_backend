#!/bin/sh
set -e

cd /var/www/html

echo "Starting Laravel container..."

# Wait for database to be ready
echo "Waiting for database connection..."
until php artisan migrate:status > /dev/null 2>&1
do
  echo "Database not ready... retrying in 2 seconds"
  sleep 2
done

echo "Database is ready!"

# Run migrations and seeders safely
echo "Running migrations and seeders..."
php artisan migrate --seed --force --no-interaction || {
  echo "Migration or seeding failed!"
  exit 1
}

# Optimize Laravel (clear caches properly)
echo "Optimizing Laravel..."
php artisan config:clear
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Starting Apache..."
exec apache2-foreground