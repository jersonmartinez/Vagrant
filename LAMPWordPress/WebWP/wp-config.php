<?php
/** 
 * Configuración básica de WordPress.
 *
 * Este archivo contiene las siguientes configuraciones: ajustes de MySQL, prefijo de tablas,
 * claves secretas, idioma de WordPress y ABSPATH. Para obtener más información,
 * visita la página del Codex{@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} . Los ajustes de MySQL te los proporcionará tu proveedor de alojamiento web.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** Ajustes de MySQL. Solicita estos datos a tu proveedor de alojamiento web. ** //
/** El nombre de tu base de datos de WordPress */
define('DB_NAME', 'wordpress');

/** Tu nombre de usuario de MySQL */
define('DB_USER', 'root');

/** Tu contraseña de MySQL */
define('DB_PASSWORD', 'root');

/** Host de MySQL (es muy probable que no necesites cambiarlo) */
define('DB_HOST', '127.0.0.1');

/** Codificación de caracteres para la base de datos. */
define('DB_CHARSET', 'utf8mb4');

/** Cotejamiento de la base de datos. No lo modifiques si tienes dudas. */
define('DB_COLLATE', '');

/**#@+
 * Claves únicas de autentificación.
 *
 * Define cada clave secreta con una frase aleatoria distinta.
 * Puedes generarlas usando el {@link https://api.wordpress.org/secret-key/1.1/salt/ servicio de claves secretas de WordPress}
 * Puedes cambiar las claves en cualquier momento para invalidar todas las cookies existentes. Esto forzará a todos los usuarios a volver a hacer login.
 *
 * @since 2.6.0
 */
define('AUTH_KEY', 'o$z;s7R`v@`4cS=S(KV%ZT=%(cKN)X&`7b`qu85}o5,~X*Bx(z5#)kN|1J1a[bP5');
define('SECURE_AUTH_KEY', '~OU?-u5@.dSdag<5fJEX;i]t3oQ#:h%w(dUfFe15e#jM]U<l^v{X]y(sR>s6$k&O');
define('LOGGED_IN_KEY', 'r!j&cMOL{ZW>bB[!ir=A}cM  H@,SO(*ISfyQu@uvsX!;aC@Gl.HiPRb:,t_^* l');
define('NONCE_KEY', ';X[#<9It&?{!4o-ZiO55>lX01pz cGT0UI}&5)Egd}%DS:63li??kXP/=U0hqQDy');
define('AUTH_SALT', 'd@Sp2n*g8r$,ehEx1iD~p(pi+4qlxXe&5oxN<Q].iBst574MRMA#>T#;BT`Y=kq~');
define('SECURE_AUTH_SALT', 'p3^bP:u+<Lmt}$W|?2p7Z[fTa!_O3]dYJJ*#mkDoIC7K~GKHP27kT?$ZujB YE[n');
define('LOGGED_IN_SALT', 'O>)k$2ZcFz*sv_Sz+z-1EMHny[<iCc$M#KE5|SY3~;z*mX)28c<#Xs>T#XQQcXTu');
define('NONCE_SALT', 't#Qq/qqP<H^gk.hE(!qJdST)r9Y1`. A}K.$,%>EuTR3S,6GX&y|LZiDzxiqH1c/');

/**#@-*/

/**
 * Prefijo de la base de datos de WordPress.
 *
 * Cambia el prefijo si deseas instalar multiples blogs en una sola base de datos.
 * Emplea solo números, letras y guión bajo.
 */
$table_prefix  = 'wp_';


/**
 * Para desarrolladores: modo debug de WordPress.
 *
 * Cambia esto a true para activar la muestra de avisos durante el desarrollo.
 * Se recomienda encarecidamente a los desarrolladores de temas y plugins que usen WP_DEBUG
 * en sus entornos de desarrollo.
 */
define('WP_DEBUG', false);

/* ¡Eso es todo, deja de editar! Feliz blogging */

/** WordPress absolute path to the Wordpress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');

