sleep 5s

while ! $(mysql --host=$MYSQL_HOST --user=$MYSQL_USER_LOGIN --password=$MYSQL_USER_PASS -e "USE $MYSQL_DB_NAME;"); do
    echo "Waiting MariaDB startup..."
    sleep 3s
done

if [ ! -d "/var/www/html/$WP_SITE_URL" ]
then
    rm -rf "/var/www/html/$WP_SITE_URL"
    mkdir -p "/var/www/html/$WP_SITE_URL"
    wp core download --path="/var/www/html/$WP_SITE_URL" --force --allow-root
    echo "Wordpress downloading SUCCESS!"
fi

if [ ! -f "/var/www/html/$WP_SITE_URL/wp-config.php" ]
then
    wp config create --dbhost="$MYSQL_HOST" \
                     --dbname="$MYSQL_DB_NAME" \
                     --dbuser="$MYSQL_USER_LOGIN" \
                     --dbpass="$MYSQL_USER_PASS" \
                     --path="/var/www/html/$WP_SITE_URL" \
                     --force --allow-root
    echo "Wordpress configuration SUCCESS!"
fi

if ! $(wp core is-installed --path="/var/www/html/$WP_SITE_URL" --allow-root);
then
    wp core install --url="$WP_SITE_URL" \
                    --title="$WP_SITE_TITLE" \
                    --admin_user="$WP_ADMIN_LOGIN" \
                    --admin_password="$WP_ADMIN_PASS" \
                    --admin_email="$WP_ADMIN_EMAIL" \
                    --path="/var/www/html/$WP_SITE_URL" \
                    --allow-root
    echo "Wordpress installation SUCCESS!"
fi

if $(wp core is-installed --path="/var/www/html/$WP_SITE_URL" --allow-root);
then
    service php7.3-fpm start
    sleep 1s
    service php7.3-fpm stop
    sleep 1s
    sed -i "s|listen = /run/php/php7.3-fpm.sock|listen = 9000|g" /etc/php/7.3/fpm/pool.d/www.conf
    echo "Wordpress launching!"
    exec "$@"
fi
