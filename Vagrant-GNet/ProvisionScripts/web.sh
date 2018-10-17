#!/usr/bin/env bash

# Ruta absoluta donde se agregará el proyecto.
DirStorage="/var/www/html/GNet"

# Ruta del directorio compartido
DirShared="/vagrant/GNet"

# Configuraciones
DBHOST=10.0.100.102
DBNAME=gnet
DBUSER=root
DBPASSWD=root

#Crea los directorios que conforman la ruta $DirStorage
function CreateDirs(){
	# Si la ruta no existe, la crea, directorios y subdirectorios
	[ ! -d $DirStorage ] && mkdir -p ${DirStorage}

    # Se habilita un enlace simbólico del proyecto
    ln -fs $DirShared $DirStorage

	# Se asignan permisos recursivo 777 a $PathAdsolute | Silencioso -f
	chmod 0777 -R -f $(dirname $(dirname $DirStorage))
}

function UpdateHost(){
    echo -e "\n--- {Actualizando la lista de paquetes y el sistema} ---\n"
    sudo apt-get update && sudo apt-get upgrade >> /var/log/vm_build.log 2>&1
}

function BasePackages(){
    echo -e "\n--- {Instalando paquetes base [vim y git]} ---\n"
    sudo apt-get install -y vim git >> /var/log/vm_build.log 2>&1
}

function InstallWebServer(){
    echo -e "\n--- {Instalando el servicio web [Apache]} ---\n"
    sudo apt-get install -y apache2 >> /var/log/vm_build.log 2>&1
}

function InstallPHP(){
    echo -e "\n--- {Instalando PHP [add-apt-repository ppa:ondrej/php]} ---\n"
    # Agregando a la lista de paquetes
    sudo add-apt-repository ppa:ondrej/php -y
    
    echo -e "\n--- {Repitiendo esta acción} ---\n"
    # Actualizar lista de paquetes
    UpdateHost
    
    echo -e "\n--- {Instalando PHP [php7.0, libapache2-mod-php7.0]} ---\n"
    # Instalación de PHP y el módulo Apache
    sudo apt-get install -y php7.0 \
        libapache2-mod-php7.0 >> /var/log/vm_build.log 2>&1

    echo -e "\n--- {Instalando PHP [Buscando en la caché]} ---\n"
    # Busca en la caché los paquetes de PHP en la versión 7.0
    sudo apt-cache search php7.0 >> /var/log/vm_build.log 2>&1
    
    echo -e "\n--- {Instalando PHP [php7.0-{packages}]} ---\n"
    # Instala los conectores al SGDB y otras librerías
    sudo apt-get install -y php7.0-{mysqli,mysql,curl,gd,intl,imagick,imap,mcrypt,memcache,pspell,recode,sqlite3,tidy,xmlrpc,xsl,mbstring,gettext} >> /var/log/vm_build.log 2>&1
    
    echo -e "\n--- {Instalando PHP [php-ssh2} ---\n"
    # Instala la librería SSH2
    sudo apt-get install -y php-ssh2 >> /var/log/vm_build.log 2>&1
}

function InstallPHPMyAdmin(){
    echo -e "\n--- {Instalando PHP [PHPMyAdmi - Configurando entrada sobre las credenciales]} ---\n"
    # Configura las credenciales que pide en paquete
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

    echo -e "\n--- {Instalando PHP [Instalando PHPMyAdmin]} ---\n"
    # Instala PHPMyAdmin
    sudo apt-get install -y phpmyadmin >> /var/log/vm_build.log 2>&1
}

function ConfigurePHP(){
    echo -e "\n--- {Configurando PHP [a2enmod rewrite]} ---\n"
    # Habilitando mod-rewrite
    a2enmod rewrite >> /var/log/vm_build.log 2>&1

    echo -e "\n--- {Configurando PHP [Apache Override All]} ---\n"
    # Permitiendo a Apache Override All
    sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

    echo -e "\n--- {Configurando PHP [Reiniciando Apache]} ---\n"
    # Reiniciar Apache
    service apache2 restart >> /var/log/vm_build.log 2>&1
}

UpdateHost
BasePackages
InstallWebServer
CreateDirs
InstallPHP
InstallPHPMyAdmin