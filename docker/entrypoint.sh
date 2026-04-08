#!/bin/sh
set -e

cd /var/www/html

echo "Configuring Apache for Render..."

# Remove default configs completely
rm -f /etc/apache2/sites-enabled/000-default.conf
rm -f /etc/apache2/sites-available/000-default.conf

# Force correct port binding
echo "Listen ${PORT}" > /etc/apache2/ports.conf

# Create fresh virtual host
cat <<EOF > /etc/apache2/sites-available/app.conf
<VirtualHost *:${PORT}>
    ServerName localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Enable new config
a2ensite app.conf

echo "Starting Laravel container..."

php artisan config:clear

echo "Running migrations and seeders..."
php artisan migrate --seed --force --no-interaction

echo "Optimizing Laravel..."
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Starting Apache on port ${PORT}..."
exec apache2ctl -D FOREGROUND
