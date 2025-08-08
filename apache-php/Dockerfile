FROM php:7.4-apache

# Установка расширения для работы с MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Включаем mod_rewrite (на всякий случай)
RUN a2enmod rewrite