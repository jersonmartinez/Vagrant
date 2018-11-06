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

# Ruta absoluta donde se agregará el proyecto.
DirStorage="/var/www/html"

# Ruta del directorio compartido
DirShared="/vagrant/GNet"

#Crea los directorios que conforman la ruta $DirStorage
function LinkDirs(){
    echo -e "$Cyan \n--- {Asignando permisos y creando un enlace simbólico} ---\n $Color_Off"
    # Asignando permisos y creando un enlace simbólico
    sudo chmod 777 -R -f $DirShared
    sudo chmod 777 -R -f $DirStorage
    sudo ln -fs $DirShared $DirStorage
}

function UpdateHost(){
    echo -e "$Cyan \n--- {Actualizando la lista de paquetes y el sistema} ---\n $Color_Off"
    sudo apt-get -y update >> /var/log/vm_build.log 2>&1
    sudo apt-get -y upgrade >> /var/log/vm_build.log 2>&1
}

function BasePackages(){
    echo -e "$Cyan \n--- {Instalando paquetes base [vim, git y debconf-utils]} ---\n $Color_Off"
    sudo apt-get install -y vim git debconf-utils >> /var/log/vm_build.log 2>&1
}

function InstallWebServer(){
    echo -e "$Cyan \n--- {Instalando el servicio web [Apache]} ---\n $Color_Off"
    sudo apt-get install -y apache2 >> /var/log/vm_build.log 2>&1

    InstallFirewall
}

function InstallFirewall(){
    echo -e "$Cyan \n--- {Instalando Firewall [UFW]} ---\n $Color_Off"
    # Instalando Firewall
    sudo apt-get install -y ufw >> /var/log/vm_build.log 2>&1

    # Permitiendo el tráfico
    sudo ufw allow http >> /var/log/vm_build.log 2>&1
    sudo ufw allow https >> /var/log/vm_build.log 2>&1
}

function InstallPHP(){
    echo -e "$Cyan \n--- {Instalando PHP [add-apt-repository ppa:ondrej/php]} ---\n $Color_Off"
    # Agregando a la lista de paquetes
    sudo add-apt-repository ppa:ondrej/php -y >> /var/log/vm_build.log 2>&1
    
    echo -e "$Cyan \n--- {Repitiendo esta acción} ---\n $Color_Off"
    # Actualizar lista de paquetes
    UpdateHost
    
    echo -e "$Cyan \n--- {Instalando PHP [php7.0, libapache2-mod-php7.0]} ---\n $Color_Off"
    # Instalación de PHP y el módulo Apache
    sudo apt-get install -y php7.0 \
        libapache2-mod-php7.0 \
        php-pear >> /var/log/vm_build.log 2>&1

    echo -e "$Cyan \n--- {Instalando PHP [Buscando en la caché]} ---\n $Color_Off"
    # Busca en la caché los paquetes de PHP en la versión 7.0
    sudo apt-cache search php7.0 >> /var/log/vm_build.log 2>&1
    
    echo -e "$Cyan \n--- {Instalando PHP [php7.0-{packages}]} ---\n $Color_Off"
    # Instala los conectores al SGDB y otras librerías
    sudo apt-get install -y php7.0-{mysqli,mysql,curl,gd,intl,imagick,imap,mcrypt,memcache,pspell,recode,sqlite3,tidy,xmlrpc,xsl,mbstring,gettext,json,cgi} >> /var/log/vm_build.log 2>&1
    
    echo -e "$Cyan \n--- {Instalando PHP [php-ssh2} ---\n $Color_Off"
    # Instala la librería SSH2
    sudo apt-get install -y php-ssh2 >> /var/log/vm_build.log 2>&1
}

function ConfigurePHP(){
    echo -e "$Cyan \n--- {Configurando PHP [a2enmod rewrite]} ---\n $Color_Off"
    # Habilitando mod-rewrite
    sudo a2enmod rewrite >> /var/log/vm_build.log 2>&1

    echo -e "$Cyan \n--- {Configurando PHP [Apache Override All]} ---\n $Color_Off"
    # Permitiendo a Apache Override All
    sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

    # Permisos
    echo -e "$Cyan \n--- Permiso para /var/www ---\n $Color_Off"
    sudo chown -R www-data:www-data /var/www/html/
    echo -e "$Green \n--- Permisos establecidos ---\n $Color_Off"

    echo -e "$Cyan \n--- {Configurando PHP [Reiniciando Apache]} ---\n $Color_Off"
    # Reiniciar Apache
    sudo service apache2 restart
}

function InstallPHPMyAdmin(){
    export DEBIAN_FRONTEND="noninteractive"

    echo -e "$Cyan \n--- {Instalando PHP [Instalando PHPMyAdmin]} ---\n $Color_Off"
    # Instala PHPMyAdmin
    sudo apt-get install -yq phpmyadmin
    
    echo -e "$Cyan \n--- {Instalando PHP [PHPMyAdmin - Configurando entrada sobre las credenciales]} ---\n $Color_Off"
    # Configura las credenciales que pide en paquete
    sudo dpkg-reconfigure --frontend=noninteractive phpmyadmin
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
}

function Finish(){
    echo -e "$Yellow \n--- {Instalación Finalizada [FIN del proceso]} ---\n $Color_Off"
}

UpdateHost
BasePackages
InstallWebServer
LinkDirs
InstallPHP
ConfigurePHP
Finish