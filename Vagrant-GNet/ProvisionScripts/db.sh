#!/usr/bin/env bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

export DEBIAN_FRONTEND="noninteractive"

# Configuraciones
DBHOST=10.0.100.102
HOSTWEB=10.0.100.101
DBNAME=gnet
DBUSER=root
DBPASSWD=root

function UpdateHost(){
    echo -e "$Cyan \n--- {Actualizando la lista de paquetes y el sistema} ---\n $Color_Off"
    sudo apt-get -y update >> /var/log/vm_build.log 2>&1
    sudo apt-get -y upgrade >> /var/log/vm_build.log 2>&1
}

function BasePackages(){
    echo -e "$Cyan \n--- {Instalando paquetes base [vim, git y debconf-utils]} ---\n $Color_Off"
    sudo apt-get install -y vim git debconf-utils >> /var/log/vm_build.log 2>&1
}

function InstallMySQL(){
    echo -e "$Cyan \n--- {Instalando MySQL [Iniciando las configuraciones entrantes sobre las credenciales del SGDB]} ---\n $Color_Off"
    # Iniciando las configuraciones entrantes sobre las credenciales del SGDB
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

    echo -e "$Cyan \n--- {Instalando MySQL [MySQL Server]} ---\n $Color_Off"
    # Instalando el SGDB MySQL Server
    sudo apt-get install -y mysql-server >> /var/log/vm_build.log 2>&1
}

function ConfigureMySQL(){
    echo -e "$Cyan \n--- {Configurando MySQL [Crear base de datos y usuario con máximos privilegios]} ---\n $Color_Off"
    # Instalando el SGDB MySQL Server
    mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /var/log/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'$DBHOST' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to 'root'@'$HOSTWEB' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1

    echo -e "$Cyan \n--- {Configurando MySQL [Cambiando la dirección de host]} ---\n $Color_Off"
    # Configurando la dirección de host
    sed -i "s/127.0.0.1/$DBHOST/" /etc/mysql/mysql.conf.d/mysqld.cnf

    echo -e "$Cyan \n--- {Configurando MySQL [Reiniciando el servicio]} ---\n $Color_Off"
    # Reiniciando el servicio MySQL
    systemctl restart mysql.service
}

UpdateHost
BasePackages
InstallMySQL
ConfigureMySQL