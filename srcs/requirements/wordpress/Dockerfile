FROM debian:buster

WORKDIR /home

RUN apt update && apt install -y php php-cli php-fpm php-mysql php-json php-opcache php-mbstring php-xml php-gd php-curl curl mariadb-client
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY wordpress_install.sh .

EXPOSE 9000

ENTRYPOINT ["sh", "wordpress_install.sh"]
#ENTRYPOINT ["/bin/bash"]

CMD ["php-fpm7.3", "--nodaemonize"]
