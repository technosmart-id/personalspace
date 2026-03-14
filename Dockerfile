FROM php:8.2-apache

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

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy WordPress files
COPY . /var/www/html/

# Create wp-config.php from environment variables
RUN mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.tmp

# Create a script to generate wp-config.php with HTTPS support
RUN echo '<?php' > /tmp/setup-wp-config.php && \
    echo '$config = file_get_contents("/var/www/html/wp-config.php.tmp");' >> /tmp/setup-wp-config.php && \
    echo '$config = str_replace("database_name_here", getenv("WORDPRESS_DB_NAME"), $config);' >> /tmp/setup-wp-config.php && \
    echo '$config = str_replace("username_here", getenv("WORDPRESS_DB_USER"), $config);' >> /tmp/setup-wp-config.php && \
    echo '$config = str_replace("password_here", getenv("WORDPRESS_DB_PASSWORD"), $config);' >> /tmp/setup-wp-config.php && \
    echo '$config = str_replace("localhost", getenv("WORDPRESS_DB_HOST"), $config);' >> /tmp/setup-wp-config.php && \
    echo '$https_config = "define('\''WP_DEBUG'\'', false);\ndefine('\''FS_METHOD'\'', '\''direct'\'');\ndefine('\''WP_HOME'\'', '\''https://'\'' . getenv('\''SERVER_NAME'\'') . '\'\'');\ndefine('\''WP_SITEURL'\'', '\''https://'\'' . getenv('\''SERVER_NAME'\'') . '\'\'');\ndefine('\''FORCE_SSL_ADMIN'\'', true);\$_SERVER'\''['\''REQUEST_SCHEME'\''] = '\''https'\'';";' >> /tmp/setup-wp-config.php && \
    echo '$config = str_replace("define( '\''WP_DEBUG'\'' , false);", $https_config, $config);' >> /tmp/setup-wp-config.php && \
    echo 'file_put_contents("/var/www/html/wp-config.php", $config);' >> /tmp/setup-wp-config.php && \
    echo '?>' >> /tmp/setup-wp-config.php

# Create entrypoint script
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'php /tmp/setup-wp-config.php' >> /entrypoint.sh && \
    echo 'apache2-foreground' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
