# Etapa 1: Composer (instala dependencias sin ejecutar en Alpine problemático)
FROM composer:2 AS composer

WORKDIR /app

COPY composer.json composer.lock* ./

RUN composer install \
    --no-interaction \
    --no-scripts \
    --no-autoloader \
    --prefer-dist \
    --no-dev \
    --ignore-platform-reqs   # ← Ignora requisitos de plataforma para build

# Etapa 2: Imagen final PHP 8.3 Alpine con extensiones
FROM php:8.3-fpm-alpine

# Instalamos paquetes RUNTIME + BUILD (dev)
RUN apk add --no-cache \
    # Runtime necesarios (sin -dev, para que GD funcione en runtime)
    libpng \
    libjpeg-turbo \
    freetype \
    libxml2 \
    libzip \
    icu-libs \
    postgresql-libs \
    # Build deps (solo durante instalación)
    --virtual .build-deps \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    libzip-dev \
    icu-dev \
    postgresql-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
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
    && apk del .build-deps   # Borra build deps para mantener imagen ligera

# Copiamos Composer y vendor de la etapa 1
COPY --from=composer /app/vendor /var/www/vendor

# Copiamos el resto del proyecto
WORKDIR /var/www
COPY . .

# Autoload y optimizaciones
RUN composer dump-autoload --optimize --classmap-authoritative --no-dev \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
