# Base Debian (como tu local)
FROM php:8.2-fpm

# Instalamos dependencias mínimas para Laravel + PostgreSQL
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libicu-dev libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl gd intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www

# Copiamos el proyecto
COPY . .

# Instalamos dependencias PHP (sin dev)
RUN composer install --optimize-autoloader --no-dev --no-interaction

# Permisos
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Puerto para PHP-FPM
EXPOSE 9000

# Comando: solo PHP-FPM (Render lo expone con NGINX o proxy)
CMD ["php-fpm"]
