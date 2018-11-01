#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2018 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

# This script acts as the machine provisioner during the Vagrant box build process for MySQL database service.

PRODUCT=$1
echo "product is: ${PRODUCT}"
# set variables
DB_USER=root
DB_PASSWORD=wso2carbon
SCRIPTS_DIRECTORY=/home/vagrant/scripts

# set and export environment variables
export DEBIAN_FRONTEND=noninteractive
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# set MySQL root password configuration using debconf
echo debconf mysql-server/root_password password $DB_PASSWORD | \
  sudo debconf-set-selections
echo debconf mysql-server/root_password_again password $DB_PASSWORD | \
  sudo debconf-set-selections

# run package updates
apt-get update

# install mysql
apt-get -y install mysql-server-5.7

# set the bind address from loopback address to all IPv4 addresses of the host
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# restart the MySQL server
systemctl restart mysql.service


# run product db script
if [ "$PRODUCT" == "apim" ]
then
    echo "product is API Manager"
    echo "Execute the database scripts..."
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_CARBON_DB.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_MB_STORE_DB.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_METRICS_DB.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2AM_DB.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2AM_STATS_DB.sql"
    echo "Successfully executed the database scripts."

elif [ "$PRODUCT" == "sp" ]
then
    echo "product is Stream processor"
    echo "Execute the database scripts..."
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_CARBON_DB.sql"
    echo "Successfully executed the database scripts."

elif [ "$PRODUCT" == "is" ]
then
    echo "product is Identity server"
    echo "Execute the database scripts..."
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_CARBON_DB.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_METRICS_DB.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/BPS_DS.sql"
    echo "Successfully executed the database scripts."

elif [ "$PRODUCT" == "ei" ]
then
    echo "product is Identity server"
    echo "Execute the database scripts..."
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/ACTIVITI_DB_BPS.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/BPS_DS_BPS.sql"
    mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_CARBON_DB_BPS.sql"
        mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_CARBON_DB_BROKER.sql"
        mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_CARBON_DB_CORE.sql"
        mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_MB_STORE_DB_BROKER.sql"
        mysql -u${DB_USER} -p${DB_PASSWORD} -e "source ${SCRIPTS_DIRECTORY}/${PRODUCT}/WSO2_METRICS_DB_BROKER.sql"
    echo "Successfully executed the database scripts."

else
    echo "user given product name is not matched"
fi


# grants root access to MySQL server from any host
echo "Create user..."
mysql -u${DB_USER} -p${DB_PASSWORD} -e "create user 'root'@'%' identified by 'wso2carbon';"
echo "Successfully created the user."

echo "Grant access to the user..."
mysql -u${DB_USER} -p${DB_PASSWORD} -e "grant all privileges on *.* to 'root'@'%' with grant option;"
mysql -u${DB_USER} -p${DB_PASSWORD} -e "flush privileges;"
echo "Successfully granted access to the user."

echo "Removing configurations directories."
#rm -rf ${WORKING_DIRECTORY}/mysql

#mysql -V

# remove the APT cache
apt-get clean

# clear the bash history and exit
cat /dev/null > ${WORKING_DIRECTORY}/.bash_history && history -c
