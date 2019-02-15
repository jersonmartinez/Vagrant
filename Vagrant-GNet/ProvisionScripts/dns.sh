#!/bin/bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

IPDNS="192.168.2.30"
IPWeb="192.168.2.20"

function UpdateHost(){
    echo -e "$Cyan \n--- {Actualizando la lista de paquetes en el sistema} ---\n $Color_Off"
    sudo apt-get -y update >> /var/log/vm_build.log 2>&1
    dpkg --configure -a >> /var/log/vm_build.log 2>&1
}

function BasePackages(){
    echo -e "$Cyan \n--- {Paquetes base [Instalando: vim, git, debconf-utils y upower]} ---\n $Color_Off"
    sudo apt-get install -y git debconf-utils build-essential binutils-doc upower >> /var/log/vm_build.log 2>&1
}

function InstallDnsServer(){
    echo -e "$Cyan \n--- {Bind9 [Instalando servicio]} ---\n $Color_Off"
    sudo apt-get install -y bind9 >> /var/log/vm_build.log 2>&1
}

function CreateZone(){
    echo -e "$Cyan \n--- {DNS [Creando zona: gnet.local]} ---\n $Color_Off"
    sudo echo " " >> /etc/bind/named.conf.local
    sudo echo 'zone "gnet.local" {
    type master;
    file "/etc/bind/db.gnet.local";
    allow-transfer {none;};
    allow-query {any;};
};' >> /etc/bind/named.conf.local
} 

function TranslationsFile(){
    echo -e "$Cyan \n--- {DNS [Configurando fichero de zona (Traducciones) ]} ---\n $Color_Off"
    sudo echo "\$TTL 604800
@       IN      SOA     gnet.local. root.gnet.local. (
                        2
                        604800
                        86400
                        2419200
                        604800 )    
@       IN      NS      gnet.local.
@       IN      A       $IPDNS
www     IN      A       $IPWeb
db      IN      A       $IPWeb" > /etc/bind/db.gnet.local
    sudo service bind9 restart >> /var/log/vm_build.log 2>&1
    echo -e "$Green \n--- {DNS [Configuración finalizada con éxito]} ---\n $Color_Off"
}

function ConfigSSH(){
    echo -e "$Cyan \n--- {SSH Server [Habilitando las directivas: PasswordAuthentication, PermitRootLogin]} ---\n $Color_Off"
    sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo service ssh restart >> /var/log/vm_build.log 2>&1
}

function AssignUserPassword(){
    echo -e "$Cyan \n--- {Asignando contraseña al usuario [Credenciales-> Username: $2, Password: $1]} ---\n $Color_Off"
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
InstallDnsServer
CreateZone
TranslationsFile
ConfigSSH
AssignUserPassword 123 root
CreateSwap
Finish