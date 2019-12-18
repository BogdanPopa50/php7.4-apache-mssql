FROM php:7.4-apache

MAINTAINER Sonal Bendle <sonal.bendle@gmail.com>

RUN a2enmod rewrite

# MSSQL drivers version
ARG MSSQL_DRIVER_VER=5.6

# Install the PHP Driver for SQL Server
RUN apt-get update -yqq \
        && apt-get install -y apt-transport-https gnupg \
        && curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
        && curl -s https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
        && apt-get update -yqq \
        && ACCEPT_EULA=Y apt-get install -y unixodbc unixodbc-dev libgss3 odbcinst msodbcsql17 locales \
        && echo "en_US.UTF-8 zh_CN.UTF-8 UTF-8" > /etc/locale.gen \
        && locale-gen

# Install pdo_sqlsrv and sqlsrv
RUN pecl install -f pdo_sqlsrv-${MSSQL_DRIVER_VER} sqlsrv-${MSSQL_DRIVER_VER} \
        && docker-php-ext-enable pdo_sqlsrv sqlsrv

# Fix Permission
RUN usermod -u 1000 www-data

WORKDIR /var/www/html

COPY app/ .

EXPOSE 80
