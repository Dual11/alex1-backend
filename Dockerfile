FROM php:8.3-fpm-alpine

# Solo instalamos lo mínimo para Laravel + PostgreSQL
RUN apk add --no-cache \
    postgresql-dev \
    && docker-php-ext-install pdo_pgsql

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Permisos
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
