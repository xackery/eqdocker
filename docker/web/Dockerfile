FROM php:5.6-apache
MAINTAINER Xackery <xackery@gmail.com>

RUN a2enmod rewrite
RUN a2enmod expires
RUN a2enmod headers
RUN docker-php-ext-install pdo pdo_mysql mysqli
# Enable Shortcodes
#RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/5.6/apache2/php.ini

# Define default command.
#CMD ["/bin/bash"]