# Use PHP 8.2 as the base image
FROM php:8.2-apache

# Install required packages and PHP extensions
RUN apt-get update && apt-get install -y \
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
       gd

# Install Node.js (includes npm)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Copy Composer from the official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install front-end dependencies and build assets (if applicable)
RUN if [ -f package.json ]; then npm install && npm run build || echo "No build needed"; fi

# Enable Apache modules
RUN a2enmod rewrite

# Expose port 80
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
