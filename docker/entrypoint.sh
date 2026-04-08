#!/bin/sh
set -e

cd /var/www/html

echo "Configuring Apache for Render..."

# 🔥 IMPORTANT: Make Apache use Render's PORT
sed -i "s/80/${PORT}/g" /etc/apache2/ports.conf
sed -i "s/80/${PORT}/g" /etc/apache2/sites-available/000-default.conf

# Optional (removes warning)
echo "ServerName localhost" >> /etc/apache2/apache2.conf

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
