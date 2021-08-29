#The last docker image is based on Debian GNU/Linux 11 (bullseye) and at this moment multiarch-support is missing.
#We need multiarch-support so we must install it.
#sqlsrv version is updated to 5.9

FROM php:7.4-apache

RUN a2enmod rewrite

RUN apt-get update \
&& apt-get -y install apt-utils \
&& apt-get -y install dialog \
&& apt-get -y install curl \
&& apt-get -y install git \
&& apt-get -y install apt-transport-https \
&& apt-get -y install wget \
&& apt-get -y install ca-certificates   \
&& apt-get -y install gnupg

#multiarch-support is missing in debian 11
RUN wget http://ftp.br.debian.org/debian/pool/main/g/glibc/multiarch-support_2.28-10_amd64.deb -P /tmp
RUN apt-get install  /tmp/multiarch-support_2.28-10_amd64.deb

# MSSQL drivers version
ARG MSSQL_DRIVER_VER=5.9

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

RUN  service apache2 restart

WORKDIR /var/www/html 

COPY app/ .

EXPOSE 80
