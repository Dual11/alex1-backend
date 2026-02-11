FROM php:8.2-fpm

# Instalamos NGINX + dependencias
RUN apt-get update && apt-get install -y \
    nginx \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libicu-dev libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl gd intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiamos configuración NGINX básica
COPY nginx.conf /etc/nginx/sites-available/default

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --optimize-autoloader --no-dev --no-interaction

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Puerto HTTP que Render espera
EXPOSE 80

# Comando: arranca NGINX + PHP-FPM
CMD service nginx start && php-fpm
