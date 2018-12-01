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

# Configuraciones
DBHOST="192.168.0.10"
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
    sudo apt-get install -y vim git debconf-utils upower >> /var/log/vm_build.log 2>&1
}

function InstallFirewall(){
    echo -e "$Cyan \n--- {Instalando Firewall [UFW]} ---\n $Color_Off"
    # Instalando Firewall
    sudo apt-get install -y ufw >> /var/log/vm_build.log 2>&1

    # Permitiendo el tráfico
    sudo ufw allow http >> /var/log/vm_build.log 2>&1
    sudo ufw allow https >> /var/log/vm_build.log 2>&1
}

function InstallMySQL(){
    echo -e "$Cyan \n--- {Instalando MySQL [Iniciando las configuraciones entrantes sobre las credenciales del SGDB]} ---\n $Color_Off"
    # Iniciando las configuraciones entrantes sobre las credenciales del SGDB
    export DEBIAN_FRONTEND="noninteractive"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

    echo -e "$Cyan \n--- {Instalando MySQL [MySQL Server]} ---\n $Color_Off"
    # Instalando el SGDB MySQL Server
    sudo apt-get install -y mysql-server >> /var/log/vm_build.log 2>&1

    InstallFirewall
}

function ConfigureMySQL(){
    echo -e "$Cyan \n--- {Configurando MySQL [Crear base de datos y usuario con máximos privilegios]} ---\n $Color_Off"
    # Instalando el SGDB MySQL Server
    sudo mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /var/log/vm_build.log 2>&1
    sudo mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'$DBHOST' identified by '$DBPASSWD' WITH GRANT OPTION" > /var/log/vm_build.log 2>&1
    sudo mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to 'root'@'%' identified by '$DBPASSWD' WITH GRANT OPTION" > /var/log/vm_build.log 2>&1

    echo -e "$Cyan \n--- {Configurando MySQL [Cambiando la dirección de host]} ---\n $Color_Off"
    # Configurando la dirección de host
    sudo sed -i "s/127.0.0.1/$DBHOST/" /etc/mysql/mysql.conf.d/mysqld.cnf

    echo -e "$Cyan \n--- {Configurando MySQL [Reiniciando el servicio]} ---\n $Color_Off"
    # Reiniciando el servicio MySQL
    sudo service mysql restart
}

function ConfigSSH(){
    echo -e "$Cyan \n--- {Configurando SSH Server [Habilitando las directivas: PasswordAuthentication, PermitRootLogin]} ---\n $Color_Off"
    sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo service ssh restart
}

function AssignUserPassword(){
    echo -e "$Cyan \n--- {Asignando contraseña a un usuario [Credenciales-> Username: $2, Password: $1]} ---\n $Color_Off"
    echo -e "$1\n$1\n" | sudo passwd $2 >> /var/log/vm_build.log 2>&1
}

function CreateSwap(){
    echo -e "$Cyan \n--- {Creando área de intercambio} ---\n $Color_Off"
    # Crea un fichero de intercambio de 0.5GB
    sudo fallocate -l 0.5G /swap 
    # Cambiando permisos al fichero (Solo accecible por el usuario root)    
    sudo chmod 600 /swap            
    # Convierte el fichero como área de intercambio
    sudo mkswap /swap >> /var/log/vm_build.log 2>&1
    # habilita el fichero de intercambio
    sudo swapon /swap
    #Agrega el fichero creado a /etc/fstab (El espacio de intercambio estará disponible en todo momento) 
    sudo echo "swap     /swap   swap    defaults    0 0" >> /etc/fstab
    echo -e "$Green \n--- {El área de intercambio ha sido creado correctamente} ---\n $Color_Off"
}

function Finish(){
    echo -e "$Yellow \n--- {Instalación Finalizada [FIN del proceso]} ---\n $Color_Off"
}

UpdateHost
BasePackages
InstallMySQL
ConfigureMySQL
ConfigSSH
AssignUserPassword 123 root
CreateSwap
Finish