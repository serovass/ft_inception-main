FROM debian:buster

WORKDIR /home

RUN apt update && apt install -y nginx openssl
RUN rm /etc/nginx/sites-enabled/*

COPY gnaida.42.fr /etc/nginx/sites-available/gnaida.42.fr

RUN ln -s /etc/nginx/sites-available/gnaida.42.fr /etc/nginx/sites-enabled/

RUN	chmod -R 777 /var/www/*
RUN	chown -R www-data:www-data /var/www/*

RUN openssl req -x509 -nodes -days 365 \
	-subj "/C=RU/ST=MOSCOW/L=MOSCOW/O=21SCHOOL/OU=gnaida" \
	-newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key \
	-out /etc/ssl/nginx-selfsigned.crt

EXPOSE 80
EXPOSE 443

#ENTRYPOINT ["/bin/bash"]

CMD ["nginx", "-g", "daemon off;"]
