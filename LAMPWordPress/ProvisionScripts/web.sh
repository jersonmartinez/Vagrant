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

DBPassword="root"
DBIPHost="192.168.10.100"
# Servidor Web utilizado
WebServer="apache2"

# Ruta absoluta donde se agregará el proyecto.
DirStorage="/var/www/html"

# Ruta del directorio compartido
DirShared="/vagrant/WebWP"

#Crea los directorios que conforman la ruta $DirStorage
function LinkDirs(){
    echo -e "$Cyan \n--- {Asignando permisos y creando un enlace simbólico} ---\n $Color_Off"
    # Asignando permisos y creando un enlace simbólico
    sudo chmod 777 -R -f $DirShared
    sudo chmod 777 -R -f $DirStorage
    sudo ln -fs $DirShared $DirStorage
}

function UpdateHost(){
    echo -e "$Cyan \n--- {Actualizando la lista de paquetes en el sistema} ---\n $Color_Off"
    sudo apt-get -y update >> /var/log/vm_build.log 2>&1
    sudo apt-get -y upgrade >> /var/log/vm_build.log 2>&1
}

function BasePackages(){
    echo -e "$Cyan \n--- {Paquetes base [Instalando: vim, git, debconf-utils y upower]} ---\n $Color_Off"
    sudo apt-get install -y git debconf-utils build-essential binutils-doc upower >> /var/log/vm_build.log 2>&1
}

function InstallWebServer(){
    echo -e "$Cyan \n--- {Apache [Instalando servicio]} ---\n $Color_Off"
    sudo apt-get install -y apache2 >> /var/log/vm_build.log 2>&1

    InstallFirewall
}

function InstallFirewall(){
    # Instalando Firewall
    echo -e "$Cyan \n--- {Instalando Firewall [UFW]} ---\n $Color_Off"
    sudo apt-get install -y ufw >> /var/log/vm_build.log 2>&1

    # Permitiendo el tráfico
    sudo ufw allow http >> /var/log/vm_build.log 2>&1
    sudo ufw allow https >> /var/log/vm_build.log 2>&1
}

function InstallPHP(){
    # Agregando a la lista de paquetes
    echo -e "$Cyan \n--- {PHP [add-apt-repository ppa:ondrej/php]} ---\n $Color_Off"
    sudo add-apt-repository ppa:ondrej/php -y >> /var/log/vm_build.log 2>&1
    
    # Actualizar lista de paquetes
    UpdateHost
    
    # Instalación de PHP y el módulo Apache
    echo -e "$Cyan \n--- {PHP [Instalando PHP 7.0]} ---\n $Color_Off"
    sudo apt-get install -y php7.0 \
        libapache2-mod-php7.0 \
        php-pear >> /var/log/vm_build.log 2>&1

    # Busca en la caché los paquetes de PHP en la versión 7.0
    echo -e "$Cyan \n--- {PHP [Buscando en la caché]} ---\n $Color_Off"
    sudo apt-cache search php7.0 >> /var/log/vm_build.log 2>&1
    
    # Instala los conectores al SGDB y otras librerías
    echo -e "$Cyan \n--- {PHP [Instalando extensiones php7.0-{packages}]} ---\n $Color_Off"
    sudo apt-get install -y php7.0-{mysqli,mysql,curl,gd,intl,imagick,imap,mcrypt,memcache,pspell,recode,sqlite3,tidy,xmlrpc,xsl,mbstring,gettext,json,cgi} >> /var/log/vm_build.log 2>&1

    sudo /etc/init.d/apache2 restart >> /var/log/vm_build.log 2>&1
}

function ConfigurePHP(){
    # Habilitando mod-rewrite
    echo -e "$Cyan \n--- {PHP [Configurando: a2enmod rewrite]} ---\n $Color_Off"
    sudo a2enmod rewrite >> /var/log/vm_build.log 2>&1

    # Permitiendo a Apache Override All
    echo -e "$Cyan \n--- {PHP [Configurando: Apache Override All]} ---\n $Color_Off"
    sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

    # Asignando permisos
    echo -e "$Cyan \n--- Estableciendo permisos para /var/www/html, /vagrant/WebWP ---\n $Color_Off"
    sudo chown -R www-data:www-data $DirStorage
    sudo chown -R www-data:www-data $DirShared

    # Reiniciar Apache
    echo -e "$Cyan \n--- {PHP [Reiniciando Apache]} ---\n $Color_Off"
    sudo service apache2 restart
}

function InstallPHPMyAdmin(){
    #Limpiar las configuraciones desatendidas sobre la base de datos
    echo -e "$Cyan \n--- {Debconf [FixDB para aplicar instalación desatendida]} ---\n $Color_Off"
    sudo /usr/share/debconf/fix_db.pl

    # Configurar las credenciales e instalar MySQL Client y Server
    echo -e "$Cyan \n--- {Instalando MySQL [Client & Server para PHPMyAdmin]} ---\n $Color_Off"
    echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
    sudo apt-get install mysql-client mysql-server -y >> /var/log/vm_build.log 2>&1

    # Configura las credenciales que pide en paquete
    echo -e "$Cyan \n--- {PHPMyAdmin desatendido [Credenciales -> DBPass: $DBPassword, WebServer: $WebServer]} ---\n $Color_Off"
    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/app-password-confirm password $DBPassword' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password $DBPassword' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password $DBPassword' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect $WebServer' | sudo debconf-set-selections
    
    # Instala PHPMyAdmin
    echo -e "$Cyan \n--- {PHPMyAdmin [Instalación desatendida]} ---\n $Color_Off"
    sudo apt-get install -y phpmyadmin >> /var/log/vm_build.log 2>&1

    echo -e "$Cyan \n--- {PHPMyAdmin [Configurando ervidor remoto de base de datos: $DBIPHost]} ---\n $Color_Off"
    sudo sed -i.bak -e "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = \$dbserver;/\$cfg['Servers'][\$i]['host'] = '$DBIPHost';/" /etc/phpmyadmin/config.inc.php

    # Creación de enlace simbólico a phpmyadmin
    ln -s /usr/share/phpmyadmin/ $DirStorage
}

function ConfigSSH(){
    echo -e "$Cyan \n--- {SSH Server [Habilitando las directivas: PasswordAuthentication, PermitRootLogin]} ---\n $Color_Off"
    sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo service ssh restart
}

function AssignUserPassword(){
    echo -e "$Cyan \n--- {Asignando contraseña al usuario [Credenciales-> Username: $2, Password: $1]} ---\n $Color_Off"
    echo -e "$1\n$1\n" | sudo passwd $2 >> /var/log/vm_build.log 2>&1
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
InstallPHPMyAdmin
ConfigSSH
AssignUserPassword 123 root
Finish