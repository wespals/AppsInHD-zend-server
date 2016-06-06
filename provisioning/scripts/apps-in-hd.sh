#!/usr/bin/env bash

APPLICATION_ENV=$1
HD_ENV=$2
HD_DB=$3
IP=$4
DOMAIN=$5
DOMAIN_COMPONENTS=(${DOMAIN//./ })
HOST=${DOMAIN_COMPONENTS[0]}
DOMAIN_COMPONENT_STR="dc=$HOST,dc=${DOMAIN_COMPONENTS[1]},dc=${DOMAIN_COMPONENTS[2]},dc=${DOMAIN_COMPONENTS[3]}"
O=$6
OU=$7
PASS=$8

APP_ROOT="/var/www/AppsInHD/"
CFG_ROOT=${APP_ROOT}"Database/"DB${HD_ENV}"/configs/"

WEB_CONF_DIR="/etc/apache2/sites-available/"
WEB_CONF_FILE="AppsInHD.conf"
WEB_CONF=${WEB_CONF_DIR}${WEB_CONF_FILE}

echo "Provisioning AppsInHD..."

if [ ! -d ${APP_ROOT} ]
    then
    echo "Cloning AppsInHD"
    #git clone ssh://harrisdata@linuxdev/var/AppsInHD ${APP_ROOT}
fi

echo "AppsInHD Installed"

if [ ! -f ${WEB_CONF} ]
    then
    echo "Configuring AppsInHD vhost"
    cp /vagrant/provisioning/config/apache2/AppsInHD.conf ${WEB_CONF}
    sed -i -e "s/APPLICATION_ENV_VAL/$APPLICATION_ENV/; s/HD_ENV_VAL/$HD_ENV/; s/APP_ROOT_VAL/\/var\/www\/AppsInHD\//" ${WEB_CONF}
    a2ensite ${WEB_CONF_FILE}
    service apache2 restart
fi

echo "Completed AppsInHD vhost"

if [ ! -d ${CFG_ROOT} ]
    then
    echo "Creating AppsInHD configs"
    mkdir -p ${CFG_ROOT}
    cp /vagrant/provisioning/config/appsInHD/DB.xml ${CFG_ROOT}DB_${HD_ENV}.xml
    sed -i -e "s/HD_DB_VAL/$HD_DB/; s/HOST_VAL/$HOST/; s/OU_VAL/$OU/; s/O_VAL/$O/; s/DOMAIN_COMPONENT_STR_VAL/$DOMAIN_COMPONENT_STR/; s/DOMAIN_VAL/$IP/" ${CFG_ROOT}DB_${HD_ENV}.xml
    echo ${PASS} > ${CFG_ROOT}LDAP.txt
    chown -R www-data:www-data ${APP_ROOT}"Database/"
fi

echo "Completed AppsInHD configs"


# check if database is installed
#==> default: mysqlshow: Access denied for user 'root'@'localhost' (using password: NO)
result=`mysqlshow --user=root ${HD_DB} | grep -v Wildcard | grep -o ${HD_DB}`
if [ "$result" != ${HD_DB} ]
    then
    echo "Creating database $HD_DB"
    mysql -uroot -p${PASS} -e "CREATE DATABASE IF NOT EXISTS $HD_DB;"

    echo "Creating user $HD_DB"
    Q1="CREATE USER '${HD_DB}'@'%' IDENTIFIED BY '${PASS}';"
    Q2="GRANT ALL PRIVILEGES ON ${HD_DB}.* TO ${HD_DB}@'%';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    mysql -uroot -p${PASS} -e "$SQL"

    echo "Creating $HD_DB tables"
    mysql -uroot -p${PASS} ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateTables.sql

    echo "Creating $HD_DB views"
    mysql -uroot -p${PASS} -f ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateViews.sql

    echo "Creating $HD_DB default data"
    mysql -uroot -p${PASS} ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateDefaultData.sql

    echo "Creating $HD_DB foreign keys"
    #mysql -uroot -p${PASS} ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateTablesFK.sql

    #INSERT INTO `HdUser` (`USER_ID`,`AUTHORIZED_USER`,`DESCRIPTION`,`EMPLOYEE_ID`,`SYSTEM_MANAGER_AUTHORITY`,`COMMUNITY_USER`,`COMMUNITY_USER_PASSWORD`,`STATUS`,`ALTERNATE_KEY`,`LAST_UPDATED`) VALUES (1,'HDDemo','harrisdata',NULL,3,'harrisdata','harrisdata',1,NULL,'2016-04-21 12:39:04.054444');
fi

echo "Database $HD_DB installed"