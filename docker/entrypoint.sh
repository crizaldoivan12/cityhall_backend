#!/bin/sh
set -e

cd /var/www/html

echo "Configuring Apache for Render..."

# Force Apache to listen on all interfaces and correct port
echo "Listen 0.0.0.0:${PORT}" > /etc/apache2/ports.conf

cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:${PORT}>
    ServerName localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

echo "Starting Laravel container..."

php artisan config:clear

echo "Running migrations and seeders..."
php artisan migrate --seed --force --no-interaction

echo "Optimizing Laravel..."
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Starting Apache..."
exec apache2-foreground
