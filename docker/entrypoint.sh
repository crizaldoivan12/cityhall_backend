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

if [ ! -f .env ] && [ -f .env.example ]; then
    echo "No .env found. Copying from .env.example..."
    cp .env.example .env
fi

if [ -z "${APP_KEY}" ] && ! grep -q '^APP_KEY=' .env 2>/dev/null; then
    echo "APP_KEY is missing. Generating one..."
    php artisan key:generate --force --no-interaction
fi

php artisan optimize:clear

echo "Running migrations..."
php artisan migrate --force --no-interaction

if [ "${RUN_SEEDERS:-false}" = "true" ]; then
    echo "RUN_SEEDERS=true detected. Running seeders..."
    php artisan db:seed --force --no-interaction
fi

echo "Optimizing Laravel..."
php artisan config:cache
php artisan view:cache

echo "Starting Apache on port ${PORT}..."
exec apache2ctl -D FOREGROUND
