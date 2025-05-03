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
    nano \
    curl \
    wget \
    cron \
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

# Download and install Moosh
RUN cd /opt && \
    wget https://moodle.org/plugins/download.php/33902/moosh_moodle45_2024111400.zip && \
    unzip moosh_moodle45_2024111400.zip && \
    ln -s /opt/moosh/moosh.php /usr/local/bin/moosh && \
    rm moosh_moodle45_2024111400.zip  # Clean up zip file


# Install Redis extension
RUN pecl install redis && \
    docker-php-ext-enable redis

# Optional: Install and enable Imagick (used by Moodle for better image processing)
RUN pecl install imagick && docker-php-ext-enable imagick

# Set recommended PHP configuration values for Moodle
COPY moodle-php.ini /usr/local/etc/php/conf.d/moodle-php.ini

# Create moodledata directory
RUN mkdir -p /var/www/moodledata && \
    # chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 770 /var/www/moodledata


# Set up Moodle cron job
COPY moodle-cron /etc/cron.d/moodle-cron
RUN chmod 0644 /etc/cron.d/moodle-cron && \
    crontab /etc/cron.d/moodle-cron

# Create startup script to run cron and apache
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Set working directory
WORKDIR /var/www/html

# Set entrypoint to our startup script
ENTRYPOINT ["/usr/local/bin/start.sh"]

