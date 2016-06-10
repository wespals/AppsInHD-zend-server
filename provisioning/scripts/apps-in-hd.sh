#!/usr/bin/env bash

APPLICATION_ENV=${1}
HD_ENV=${2}
HD_DB=${3}
IP=${4}
DOMAIN=${5}
DOMAIN_COMPONENTS=(${DOMAIN//./ })
HOST=${DOMAIN_COMPONENTS[0]}
DOMAIN_COMPONENT_STR="dc=${HOST},dc=${DOMAIN_COMPONENTS[1]},dc=${DOMAIN_COMPONENTS[2]},dc=${DOMAIN_COMPONENTS[3]}"
O=${6}
OU=${7}
HD_USER=${8}
PASS=${9}
HD_APP_USER=${10}
APP_ROOT=${11}
HDE_KEY="HD Testing Key"
CFG_ROOT=${APP_ROOT}"Database/DB${HD_ENV}/configs/"
WEB_CONF_DIR="/etc/apache2/sites-available/"
WEB_CONF_FILE="AppsInHD.conf"
WEB_CONF=${WEB_CONF_DIR}${WEB_CONF_FILE}

echo "Provisioning AppsInHD..."

no_user=$(id -u ${HD_USER} > /dev/null 2>&1; echo $?)
if [ no_user ]
    then
    echo "Creating user ${HD_USER}"
    useradd -m -s /bin/bash ${HD_USER}
    echo ${HD_USER}:${PASS} | chpasswd
    usermod -a -G ${HD_USER} www-data

    echo "Configuring ${HD_USER} SSH"
    sudo -u ${HD_USER} mkdir /home/${HD_USER}/.ssh
    cp /vagrant/provisioning/config/appsInHD/ssh_config /home/${HD_USER}/.ssh/config
    chmod 400 /home/${HD_USER}/.ssh/config
    cp /vagrant/provisioning/config/appsInHD/id_rsa /home/${HD_USER}/.ssh
    chmod 600 /home/${HD_USER}/.ssh/id_rsa
    cp /vagrant/provisioning/config/appsInHD/id_rsa.pub /home/${HD_USER}/.ssh
    chmod 600 /home/${HD_USER}/.ssh/id_rsa.pub
    chown -R ${HD_USER}:${HD_USER} /home/${HD_USER}/.ssh
fi

echo "User ${HD_USER} created"

no_user=$(id -u ${HD_DB} > /dev/null 2>&1; echo $?)
if [ no_user ]
    then
    echo "Creating user ${HD_DB}"
    useradd -m -s /bin/bash ${HD_DB}
    echo ${HD_DB}:${PASS} | chpasswd
fi

echo "User ${HD_DB} created"

if [ ! -d ${APP_ROOT} ]
    then
    echo "Cloning AppsInHD"
    sudo -u ${HD_USER} mkdir ${APP_ROOT}
    sudo -u ${HD_USER} git clone ssh://harrisdata@linuxdev/var/AppsInHD ${APP_ROOT}

    echo "Creating AppsInHD public extension directory"
    sudo -u ${HD_USER} mkdir -p ${APP_ROOT}Gateway/public/ext/sw${HD_ENV}
    chown -R ${HD_DB}:${HD_USER} ${APP_ROOT}Gateway/public/ext/sw${HD_ENV}
fi

echo "AppsInHD Installed"

if [ ! -d /etc/apache2/ssl ]
    then
    echo "Configuring SSL"
    a2enmod ssl
    service apache2 restart
    mkdir /etc/apache2/ssl
    openssl req -new -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/apache2/ssl/ssl.key -out /etc/apache2/ssl/ssl.crt -subj /CN=${DOMAIN}
fi

echo "Completed SSL config"

if [ ! -f ${WEB_CONF} ]
    then
    echo "Configuring AppsInHD vhost"
    cp /vagrant/provisioning/config/apache2/AppsInHD.conf ${WEB_CONF}
    sed -i -e "s/APPLICATION_ENV_VAL/${APPLICATION_ENV}/g; s/HD_ENV_VAL/${HD_ENV}/g; s/SERVER_NAME_VAL/${HOST}/g; s#APP_ROOT_VAL#${APP_ROOT}#g" ${WEB_CONF}
    a2ensite ${WEB_CONF_FILE}
    service apache2 restart
fi

echo "Completed AppsInHD vhost"

if [ ! -d ${CFG_ROOT} ]
    then
    echo "Creating AppsInHD configs"
    sudo -u ${HD_USER} mkdir -p ${CFG_ROOT}
    #cause Install/SetupDB.php doesnt create the files
    touch ${CFG_ROOT}HD_${HD_ENV}_DB.txt
    touch ${CFG_ROOT}LDAP.txt
    touch ${CFG_ROOT}BSI_${HD_ENV}.txt
    touch ${CFG_ROOT}DB_${HD_ENV}.xml
    /usr/local/zend/bin/php ${APP_ROOT}Install/SetupDB.php "${HD_ENV}::${PASS}::$DB2Name::$SysName::$LHost::$LPort::$basedn::$ldapuser::$SSLYN::$gatewayu::$importu::$importSource::$cognosServer::${APP_ROOT}::${HDE_KEY}::$useAccPrc::$useICoPrc::$autoAdjSpnTrn::$altKeySep::$attachu::$authu::$formsu::$mdu::$searchu::$transu::$baseurl::$DBType::$adminu::$ldappwd::$bsidataset::$bsiuser::$bsipwd::$bsiver::$allowldapmaint"
    cp /vagrant/provisioning/config/appsInHD/DB.xml ${CFG_ROOT}DB_${HD_ENV}.xml
    sed -i -e "s/HD_DB_VAL/${HD_DB}/g; s/HOST_VAL/${HOST}/g; s/OU_VAL/${OU}/g; s/O_VAL/${O}/g; s/DOMAIN_COMPONENT_STR_VAL/${DOMAIN_COMPONENT_STR}/g; s/DOMAIN_VAL/${DOMAIN}/g" ${CFG_ROOT}DB_${HD_ENV}.xml
    chown -R ${HD_DB}:${HD_USER} ${APP_ROOT}"Database/DB"${HD_ENV}
fi

echo "Settting AppsInHD permissions"
chmod -R 770 ${APP_ROOT}
echo "Completed AppsInHD configs"

result=`mysqlshow -uroot -p${PASS} | grep -v Wildcard | grep -o ${HD_DB}`
if [ "$result" != ${HD_DB} ]
    then
    echo "Creating database ${HD_DB}"
    mysql -uroot -p${PASS} -e "CREATE DATABASE IF NOT EXISTS ${HD_DB};"

    echo "Creating user ${HD_DB}"
    Q1="CREATE USER IF NOT EXISTS '${HD_DB}'@'%' IDENTIFIED BY '${PASS}';"
    Q2="GRANT ALL PRIVILEGES ON ${HD_DB}.* TO ${HD_DB}@'%';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    mysql -uroot -p${PASS} -e "${SQL}"

    echo "Creating ${HD_DB} tables"
    mysql -uroot -p${PASS} ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateTables.sql

    echo "Creating ${HD_DB} views"
    mysql -uroot -p${PASS} -f ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateViews.sql

    echo "Creating ${HD_DB} default data"
    mysql -uroot -p${PASS} ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateDefaultData.sql

    echo "Creating ${HD_DB} foreign keys"
    mysql -uroot -p${PASS} ${HD_DB} < ${APP_ROOT}Install/MYSQL_CreateTablesFK.sql

    echo "Creating ${HD_APP_USER} user"
    SQL="INSERT INTO ${HD_DB}.HdUser (USER_ID, AUTHORIZED_USER, DESCRIPTION, EMPLOYEE_ID, SYSTEM_MANAGER_AUTHORITY, COMMUNITY_USER, COMMUNITY_USER_PASSWORD, STATUS, ALTERNATE_KEY) VALUES (1,'${HD_APP_USER}','harrisdata',NULL,3,'harrisdata','harrisdata',1,NULL);"
    mysql -uroot -p${PASS} -e "${SQL}"

    SQL="INSERT INTO ${HD_DB}.HdAuthorizationPolicy (AUTHORIZATION_POLICY_ID, AUTHORIZATION_TYPE, USER_ID, ROLE_ID, ENTITY_TYPE_ID, ACTION_TYPE, SECURITY_DOMAIN_ENTITY_TYPE_ID, SECURITY_FILTER, SYSTEM_GENERATED) VALUES (1,'G',1,NULL,NULL,NULL,NULL,NULL,0);"
    mysql -uroot -p${PASS} -e "${SQL}"
fi

echo "Database ${HD_DB} installed"