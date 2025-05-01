FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libxslt-dev \
    libmcrypt-dev \
    zlib1g-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    libmagickwand-dev --no-install-recommends

# Enable Apache mods
RUN a2enmod rewrite headers

# Install PHP extensions required by Moodle
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
    gd \
    intl \
    mbstring \
    xml \
    xmlrpc \
    soap \
    zip \
    pdo \
    pdo_mysql \
    opcache \
    mysqli \
    xsl \
    curl \
    exif

# Optional: Install and enable Imagick (used by Moodle for better image processing)
RUN pecl install imagick && docker-php-ext-enable imagick

# Set recommended PHP configuration values for Moodle
COPY moodle-php.ini /usr/local/etc/php/conf.d/moodle-php.ini

# Create moodledata directory
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 770 /var/www/moodledata

# Set working directory
WORKDIR /var/www/html
