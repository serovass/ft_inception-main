# Predicate that returns exit status 0 if the database root password
# is set, a nonzero exit status otherwise.
is_mysql_root_password_set() {
  ! mysqladmin --host=localhost --user=root status > /dev/null 2>&1
}

# Predicate that returns exit status 0 if the mysql(1) command is available,
# nonzero exit status otherwise.
is_mysql_command_available() {
  which mysql > /dev/null 2>&1
}

#sed -i "s|skip-networking|# skip-networking|g" /etc/mysql/mariadb.conf.d/50-server.cnf
#sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

sed -i "s|#port|port|g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql start
sleep 1s

if ! is_mysql_command_available; then
  echo "The MySQL/MariaDB client mysql(1) is not installed."
  exit 1
fi

if ! is_mysql_root_password_set; then
  mysql --host=localhost --user=root --password="$MYSQL_ROOT_PASS" <<_EOF_
    UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASS}') WHERE User='root';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
_EOF_
  echo Secure setup complete!
fi

if [ ! -d "/var/lib/mysql/$MYSQL_DB_NAME" ]; then 
  mysql --host=localhost --user=root --password="$MYSQL_ROOT_PASS" <<_EOF_
    CREATE DATABASE ${MYSQL_DB_NAME} CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci;
    GRANT ALL ON ${MYSQL_DB_NAME}.* TO '${MYSQL_USER_LOGIN}'@'%' IDENTIFIED BY '${MYSQL_USER_PASS}';
    FLUSH PRIVILEGES;
_EOF_
  echo MariaDB setup complete!
fi

if ! mysql --host=localhost --user="$MYSQL_USER_LOGIN" --password="$MYSQL_USER_PASS" -e 'SHOW DATABASES;'; then 
  mysql --host=localhost --user=root --password="$MYSQL_ROOT_PASS" <<_EOF_
    GRANT ALL ON ${MYSQL_DB_NAME}.* TO '${MYSQL_USER_LOGIN}'@'%' IDENTIFIED BY '${MYSQL_USER_PASS}';
    FLUSH PRIVILEGES;
_EOF_
  echo User setup complete!
fi

sleep 1s
service mysql stop
sleep 1s

exec "$@"