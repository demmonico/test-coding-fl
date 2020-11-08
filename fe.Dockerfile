FROM php:7.4-fpm
LABEL maintainer="demmonico@gmail.com"
LABEL service="app"
LABEL env="prod"

COPY infra/common/php/php.ini /usr/local/etc/php/
COPY infra/common/php/php-fpm.conf /usr/local/etc/
COPY infra/common/php/www.conf /usr/local/etc/php-fpm.d/

# setup logs
RUN mkdir -p /var/log/php \
    && touch /var/log/php/php.log \
    && chmod -R 777 /var/log/php \
    && tail -f /var/log/php/php.log >/proc/1/fd/1 &

COPY code-fe /app
WORKDIR /app

CMD ["php-fpm"]
