# Use PHP 8.2 as the base image
FROM php:8.2-apache

# Install required packages and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    zlib1g-dev \
    libbz2-dev \
    libonig-dev \
    libxml2-dev \
    libpng-dev \
    curl \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
       bcmath \
       intl \
       zip \
       pdo_mysql \
       mbstring \
       gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Composer from the official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Set permissions for writable directories
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Set Apache server name to avoid warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Enable Apache modules
RUN a2enmod rewrite

# Install Node.js and npm (if your app requires it)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global npm@latest

# Install front-end dependencies and build assets (if applicable)
RUN if [ -f package.json ]; then npm install && npm run build; fi

# Expose port 80
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
