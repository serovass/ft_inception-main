FROM debian:buster

WORKDIR /home

RUN apt update && apt install -y mariadb-server

COPY mariadb_install.sh .

ENTRYPOINT ["sh", "mariadb_install.sh"]
#ENTRYPOINT ["/bin/bash"]

CMD ["mysqld_safe"]
