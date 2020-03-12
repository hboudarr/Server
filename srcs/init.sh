service mysql start

mysql -u root < ./tmp/database.sql
mysql -u root -D wordpress < ./tmp/wordpress.sql

service nginx restart
service mysql restart
service php7.3-fpm restart


bash
