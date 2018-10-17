#!/usr/bin/env bash

# Configuraciones
DBHOST=10.0.100.102
HOSTWEB=10.0.100.101
DBNAME=gnet
DBUSER=root
DBPASSWD=root

function UpdateHost(){
    echo -e "\n--- {Actualizando la lista de paquetes y el sistema} ---\n"
    sudo apt-get update && sudo apt-get upgrade
}

function BasePackages(){
    echo -e "\n--- {Instalando paquetes base [vim y git]} ---\n"
    sudo apt-get install -y vim git >> /var/log/vm_build.log 2>&1
}

function InstallMySQL(){
    echo -e "\n--- {Instalando MySQL [Iniciando las configuraciones entrantes sobre las credenciales del SGDB]} ---\n"
    # Iniciando las configuraciones entrantes sobre las credenciales del SGDB
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

    echo -e "\n--- {Instalando MySQL [MySQL Server]} ---\n"
    # Instalando el SGDB MySQL Server
    sudo apt-get install -y mysql-server >> /var/log/vm_build.log 2>&1
}

function ConfigureMySQL(){
    echo -e "\n--- {Configurando MySQL [Crear base de datos y usuario con máximos privilegios]} ---\n"
    # Instalando el SGDB MySQL Server
    mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /var/log/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'$DBHOST' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to 'root'@'$HOSTWEB' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1

    echo -e "\n--- {Configurando MySQL [Cambiando la dirección de host]} ---\n"
    # Configurando la dirección de host
    sed -i "s/127.0.0.1/$DBHOST/" /etc/mysql/mysql.conf.d/mysqld.cnf

    echo -e "\n--- {Configurando MySQL [Reiniciando el servicio]} ---\n"
    # Reiniciando el servicio MySQL
    systemctl restart mysql.service
}

UpdateHost
BasePackages
InstallMySQL
ConfigureMySQL