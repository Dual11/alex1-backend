# Usamos una imagen base con PHP 8.3 + Alpine (ligera y rápida)
FROM php:8.3-fpm-alpine

# Instalamos dependencias del sistema y extensiones de PHP necesarias
RUN apk add --no-cache \
    git \
    unzip \
    curl \
    postgresql-dev \
    libzip-dev \
    && docker-php-ext-install pdo pdo_pgsql zip exif pcntl

# Instalamos Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www

# Copiamos todo el proyecto
COPY . .

# Instalamos dependencias de PHP (sin paquetes de desarrollo)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Permisos correctos para Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Puerto que usará PHP-FPM (Render lo redirige después)
EXPOSE 9000

# Comando por defecto: PHP-FPM
CMD ["php-fpm"]
