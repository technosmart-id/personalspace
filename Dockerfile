FROM php:8.2-apache

# Suppress Apache ServerName warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql opcache xml

# Enable Apache mods
RUN a2enmod rewrite headers

# Configure PHP upload limits
RUN echo "upload_max_filesize = 100M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "file_uploads = On" >> /usr/local/etc/php/conf.d/uploads.ini

# Set working directory
WORKDIR /var/www/html

# Copy WordPress files
COPY . /var/www/html/

# Make files writable by Apache
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
