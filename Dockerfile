# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: hboudarr <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/03/03 16:24:56 by hboudarr          #+#    #+#              #
#    Updated: 2020/03/12 14:26:55 by hboudarr         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster
MAINTAINER Hboudarr <hboudarr@student.42.fr>

# INSTALLATION
COPY	/srcs/info.php /var/www/html

RUN	apt-get update && apt-get -y upgrade
RUN	apt-get -y install wget nginx 
RUN apt-get -y install mariadb-server mariadb-client
RUN apt-get -y install php7.3 php7.3-fpm php7.3-mysql

# CONFIGURATION DE NGINX

COPY	/srcs/index.html /var/www/html/
COPY 	./srcs/nginx.conf /etc/nginx/sites-available/localhost
RUN		ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
RUN		rm /etc/nginx/sites-enabled/default

# CONFIGURATION DE LA BASE DE DONNEE MYSQL

RUN		service mysql start

# CONFIGURATION SSL

COPY	./srcs/dhparam.pem /etc/nginx/
COPY	./srcs/nginx-selfsigned.crt /etc/ssl/certs/
COPY	./srcs/nginx-selfsigned.key /etc/ssl/private/
COPY	./srcs/self-signed.conf /etc/nginx/snippets/
COPY	./srcs/ssl-params.conf /etc/nginx/snippets/

# CONFIGURATION DE PHP

RUN 	service php7.3-fpm start
RUN		mkdir -p var/www/html/phpmyadmin
RUN		wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN		tar -zxvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin
COPY	./srcs/config.inc.php var/www/html/phpmyadmin
COPY 	./srcs/info.php /var/www/html/info.php

# CONFIG WORDPRESS

RUN		mkdir -p /var/www/html/wordpress
RUN		wget https://wordpress.org/latest.tar.gz 
RUN		tar -zxvf latest.tar.gz --strip-components=1 -C /var/www/html/wordpress
RUN		chown -R www-data:www-data /var/www/html/wordpress
COPY	./srcs/wp-config.php /var/www/html/wordpress

# CREATION ET RESTAURATION DE LA BDD, wordpress_user / password

COPY  	./srcs/database.sql ./tmp
COPY  	./srcs/wordpress.sql ./tmp
COPY   ./srcs/init.sh ./

# EXECUTION

CMD  bash init.sh

# docker build -t name .
# docker run -it -p 80:80 -p 443:443 name
