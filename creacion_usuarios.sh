#!/bin/bash

# Verificamos si el script ya fue ejecutado
if [ -f "/tmp/configuracion_flag.txt" ]; then
	echo "Ya se ha ejecutado previamente el script en este servidor"
	exit 1
fi

# Creamos un registro de los comandos ejecutados
log_file="/tmp/configuracion_log.txt"
touch $log_file

# Creamos una funcion para registrar comandos en el log
log_command() {
	echo "Comando ejecutado: $1" >> $log_file
}

# Creamos los usuarios
echo "Introduce los nombres de los 4 usuarios y sus respectivas contraseñas:"
for i in {1..4}; do
	read -p "Nombre del usuario $i: " username
	read -p "Contraseña para $username: " password
	
	echo

	echo "Creando el usuario"
	useradd -m $username
	#echo -e "$password\n$password" | passwd $username
	
	# Añadimos el usuario al grupo www
	echo "Añadiendo usuario al grupo www"
	usermod -aG www $username
	echo "Usuario añadido al grupo"

	# Creamos el archivo servidor.conf para el usuario
	echo "Creando el archivo servidor.conf"
	touch /home/$username/servidor.conf
	echo "Archivo servidor.conf creado"

	# Establecemos los permisos para el fichero
	echo "Estableciendo permisos para el archivo servidor.conf"
	chmod 754 /home/$username/servidor.conf
	echo "Permisos establecidos"

	# Creamos el enlace al escritorio
	echo "Creando enlace al escritorio"
	ln -s /home/$username/servidor.conf /home/$username/Escritorio/servidor.conf
	echo "Enlace creado"

	log_command "useradd -m $username"
	log_command "echo -e "$password\n$password" | passwd $username"
	log_command "usermod -aG www $username"
	log_command "touch /home/$username/servidor.conf"
	log_command "chmod 754 /home/$username/servidor.conf"
	log_command "ln -s /home/$username/servidor.conf /home/$username/Escritorio/servidor.conf"
done

# Instalamos Apache y PHP
echo "Instalando Apache y PHP"

apt update
apt install -y apache2 php

log_command "apt update"
log_command "apt install -y apache2 php"

echo "Apache y PHP instalados"

# Descargamos e instalamos Apache Tomcat
echo "Descargando e instalando Apache Tomcat"

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz -P /tmp
tar -xzvf /tmp/apache-tomcat-9.0.56.tar.gz -C /opt

log_command "wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz -P /tmp"
log_command "tar -xzvf /tmp/apache-tomcat-9.0.56.tar.gz -C /opt"

echo "Apache Tomcat descargado e instalado"

# Registramos la configuracion
touch "/tmp/configuracion_flag.txt"
echo "Configuración completada"

# Mostramos los comandos que se han ejecutado
echo "Registro de comandos ejecutados:"
cat $log_file