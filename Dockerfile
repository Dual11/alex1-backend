# Etapa 1: Instalamos Composer y dependencias (multi-stage para imagen ligera)
FROM composer:2 AS composer

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    --no-interaction \
    --no-scripts \
    --no-autoloader \
    --prefer-dist \
    --no-dev

# Etapa 2: Imagen final con PHP + extensiones necesarias para Laravel
FROM php:8.3-fpm-alpine

# Instalamos dependencias del sistema y extensiones PHP (las más comunes en Laravel 2026)
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        pdo \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        xml \
        dom \
        zip \
        intl \
        curl \
    && apk del --no-cache libpng-dev libjpeg-turbo-dev freetype-dev

# Copiamos Composer desde la etapa anterior
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copiamos el proyecto
WORKDIR /var/www

COPY --from=composer /app/vendor ./vendor
COPY . .

# Generamos autoload y optimizamos (después de copiar todo)
RUN composer dump-autoload --optimize --classmap-authoritative --no-dev

# Permisos para Laravel (muy importante en producción)
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Puerto para PHP-FPM
EXPOSE 9000

# Comando por defecto
CMD ["php-fpm"]
