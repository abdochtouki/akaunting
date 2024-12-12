# Utiliser l'image Apache de base
FROM php:8.2-apache

# Installer Node.js et npm
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

# Copier votre code dans le conteneur (assurez-vous que vous avez les bons fichiers)
COPY . /var/www/html/

# Accéder au répertoire de votre projet où se trouve package.json
WORKDIR /var/www/html

# Installer les dépendances npm
RUN npm install

# Exécuter npm run dev en arrière-plan et démarrer Apache
CMD npm run dev & apache2-foreground
