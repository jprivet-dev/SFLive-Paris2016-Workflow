FROM php:7.2-fpm-alpine

ARG USERID
ARG GROUPID

RUN apk --update add \
        git \
        openssh && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

RUN addgroup -g ${GROUPID:-1000} -S docker && \
    adduser -u ${USERID:-1000} -S docker -G docker && \
    apk add zlib-dev --update-cache --repository http://dl-4.alpinelinux.org/alpine/v3.5/community/ --allow-untrusted && \
    apk add php7-zip && \
    docker-php-ext-install pdo pdo_mysql && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install zip && \
    printf '[PHP]\ndate.timezone = "Europe/Paris"\n' > /usr/local/etc/php/conf.d/tzone.ini

VOLUME /var/www/html
WORKDIR /var/www/html

ENV COMPOSER_MEMORY_LIMIT -1
ENV COMPOSER_HOME /home/docker/.composer

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

EXPOSE 9000
USER docker