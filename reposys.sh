#!/bin/bash
#===============================================================================
# PROGRAM GENERAL INFORMATION
#===============================================================================
# TYPE:				Bash script
# NAME:				reposys.sh
# VERSION:			1.1
# RELEASE DATE:		12/05/2014
# DESCRIPTION:		Performs some packages administration tasks and manages
#					mini-repos for Debian based distros
# AUTHOR:			Leodanis Pozo Ramos (lpozo)
# COMMUNITY:		Grupo de Usuarios de Tecnologías Libres (GUTL)
#					http://gutl.jovenclub.cu
# COUNTRY:			Cuba
# LICENSE:			GNU GPL v2 (http://www.gnu.org/licenses/gpl.html)
# INSTALLATION:		Copy into ~/ or into ~/.gnome2/nautilus-scripts or into
#					any place with write access, and add execution permissions
# USAGE:			Run under GNOME/Unity/Cinnamon/Mate and follow the
#					instructions
# TESTED ON:		Ubuntu/Linux Mint
# CMD LINE OPTIONS:	None

# LEGAL DECLARATIONS
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License (http://www.gnu.org/licenses/gpl.html)
# for more details.

# DEPENDENCIES
#	aptitude
#	apt-get
#	AptOnCD
#	bash
#	dpkg
#	dpkg-deb
#	dpkg-dev
#	gksudo
#	gzip
#	wget
#	zenity

# DEBUGGING TOOLS
# uncomment this line to debug the script
# set -u This option treats unset variables as an error when they are expanded
# set -x
#===============================================================================
# GENERAL VARIABLES INITIALIZATION
#===============================================================================

################################################################################
# SCRIPT META DATA
declare -r name="Reposys"
declare -r version="1.1"

################################################################################
# PATHS
script_dir="$PWD" # Keep track of where the script is located
config_dir="$script_dir"/config # keep track of configurations files
working_dir=$(< "$config_dir"/working-dir.conf) # Keep track of working dir.
apt_cache="/var/cache/apt/archives" # Keep track of the apt cache path
sources_list_file="/etc/apt/sources.list" # Keep track of sources.list path

#===============================================================================
# INTERNATIONALIZATION (i18n) & LOCALIZATION (l10n)
#===============================================================================
case "$LANG" in
	es* )
		# Spanish (es-CU)
		# DIALOGS TITLES
			title_main_menu="$name - Menú Principal"
			title_select_destiny_dir="Seleccione el directorio destino"
			title_select_source_dir="Seleccione el directorio origen"
			title_select_iso_file="Seleccione el archivo ISO del mini-repo"
			title_select_pkgs_list_file="Seleccione el archivo con la lista de paquetes"
			title_select_mount_point="Select a mount point"
			title_msg_info="Información"
			title_msg_error="Error"
			title_msg_question="Pregunta"
			title_msg_warning="Advertencia"
			title_msg_progress="Progreso de la operación"
			title_entry_install_pkg="Instalar paquete"
		# MAIN MENU ITEMS
			menu_column_options="$name - Opciones"
			menu_option_configure_apt_sources_list="Configurar el APT \"sources.list\""
			menu_option_update_apt_database="Actualizar la base de datos APT"
			menu_option_update_system="Actualizar el sistema"
			menu_option_copy_apt_cache="Copiar la caché de APT al directorio del mini-repo"
			menu_option_clean_apt_cache="Limpiar la caché de APT"
			menu_option_clean_work_dir_verbose="Eliminar los paquetes repetidos en el directorio del mini-repo dejando solo la última versión"
			menu_option_generate_mini_repo_pkgs_list="Generar la lista de paquetes del mini-repo"
			menu_option_mini_repo_incremental_update="Actualizar el mini-repo incrementalmente"
			menu_option_update_mini_repo="Actualizar los paquetes del mini-repo a su versión mas reciente (actualizar el mini-repo)"
			menu_option_create_repo_iso_aptoncd="Crear una imagen ISO del mini-repo usando AptOnCD"
			menu_option_create_repo_scanpkgs="Crear el archivo Packages.gz del mini-repo usando dpkg-scanpackages"
			menu_option_create_repo_pc_installed_pkg="Crear mini-repo con los paquetes instalados en esta PC"
			menu_option_replicate_mini_repo="Convertir el contenido del mini-repo a otra versión de la misma distribución (ej. Ubuntu 12.04 a 12.10)"
			menu_option_mount_repo_iso="Montar el ISO del mini-repo"
			menu_option_create_mini_repo="Crear un mini-repo con aplicaciones selecionadas"
			menu_option_install_pkg="Instalar un paquete"
			menu_option_quit="Salir"
		#INFO MESSAGES
			msg_main_menu="Seleccione la acción que desea ejecutar:"
			msg_update_apt_database_success="\n\n$menu_option_update_apt_database: completado satisfactoriamente\n"
			msg_update_system_success="\n\n$menu_option_update_system: completado satisfactoriamente\n"
			msg_copy_apt_cache_success="$menu_option_copy_apt_cache: completado satisfactoriamente"
			msg_clean_apt_cache_success="$menu_option_clean_apt_cache: completado satisfactoriamente"
			msg_clean_work_dir_verbose_success="$menu_option_clean_work_dir_verbose: completado satisfactoriamente"
			msg_generate_mini_repo_pkgs_list_success="La lista de paquetes del mini-repo se ha generado satisfactoriamente en"
			msg_download_pkgs_last_version_success="$menu_option_update_mini_repo: completado satisfactoriamente"
			msg_create_repo_iso_aptoncd_success="$menu_option_create_repo_iso_aptoncd: completado satisfactoriamente"
			msg_create_repo_scanpkgs_success="$menu_option_create_repo_scanpkgs: completado satisfactoriamente. Archivo Packages.gz creado en"
			msg_mount_repo_iso_success="$menu_option_mount_repo_iso: completado satisfactoriamente"
			msg_create_mini_repo_fail="Cree una lista de aplicaciones válida e inténtelo nuevamente"
			msg_install_app=" debe ser instalado para completar esta operación. ¿Desea instalarlo?"
			msg_install_pkg_success=" se instaló satisfactoriamente\n"
			msg_pkg_already_installed="El paquete ya está instalado:"
			msg_create_repo_app_list="Para completar esta tarea debe crear un listado de aplicaciones para el mini-repo. Desea crearlo ahora?"
			msg_downloading_app_success="Descarga completada satisfactoriamente"
		#ERROR MESSAGES
			msg_error_updating_apt_database="\n\nNo se pudo actualizar la base de datos APT. Verifique su \"sources.lit\" y su conexión e inténtelo nuevamente\n"
			msg_error_updating_system="\n\nEl sistema no se pudo actualizar correctamente. Verifique su \"sources.lit\" y su conexión e inténtelo nuevamente\n"
			msg_error_cleaning_apt_cache="No se ha podido limpiar la caché de APT"
			msg_error_no_pkgs_to_download="No hay paquetes que descargar del repo on-line"
			msg_error_downloading_pkgs_last_version="Paquete no disponible en el repo on-line:"
			msg_error_creating_repo_iso_aptoncd="AptOnCD no pudo crear el ISO del mini-repo"
			msg_error_mounting_repo_iso="La imagen ISO no se pudo montar"
			msg_error_installing_pkg=" no se ha podido instalar, trate de instalarlo manualmente\n"
			msg_error_pkg_info_not_available="La información de versión del paquete no está disponible en el repo on-line:"
			msg_error_pkg_not_available_online="El paquete no está disponible en el repo on-line:"
			msg_error_pkg_not_found="No se ha encontrado el paquete, asegurese de haber escrito correctamente el nombre del paquete:"
			msg_error_no_pkgs_in_this_directory="No hay paquetes en este directorio, seleccione otro e inténtelo nuevamente"
			msg_error_no_pkgs_in_apt_cache="No hay paquetes que copiar desde la caché de APT"
			msg_error_no_repeated_pkgs_in_this_directory="No hay paquetes repetidos en este directorio"
			msg_error_copying_apt_cache="No se pudo copiar la caché de APT"
			msg_error_wrong_password="Contraseña de administración no válida"
		#WARNING MESSAGES
			msg_warning_dpkg_scanpkgs="Crear el archivo Packages.gz tomará algún tiempo y no verá nada en su pantalla hasta que el proceso no se haya concluido"
		#PROGRESS BARS MESSAGES
			msg_progress_installing_pkg="Instalando aplicación:"
			msg_progress_cleaning_work_dir="Limpiando el directorio de trabajo..."
			msg_progress_copying_apt_cache="Copiando la caché de APT..."
			msg_progress_updating_apt_database="Actualizando la base de datos APT...\n\n"
			msg_progress_sys_update="Actualizando el sistema...\n\n"
			msg_progress_cleaning_apt_cache="Limpiando la caché de APT..."
			msg_progress_downloading_pkg_online="Descargando paquetes desde el repo on-line..."
		#OTHERS DIALOGS MESSAGES
			msg_entry_install_pkg="Introduzca el nombre del paquete que desea instalar"
			msg_entry_enter_root_password="Introduzca su clave de administración"
			msg_text_info_pkgs_not_downloaded="Los paquetes siguientes no se pudieron descargar:"
		#OTHERS
			ans_yes="Sí"
			ans_no="No"
	;;

	* )
		# English (en-US)
		# DIALOGS TITLES
			title_main_menu="$name - Main Menu"
			title_select_destiny_dir="Select a destination directory"
			title_select_source_dir="Select a source directory"
			title_select_iso_file="Select a mini-repo ISO file"
			title_select_pkgs_list_file="Select the packages list file"
			title_select_mount_point="Select a mount point"
			title_msg_info="Information"
			title_msg_error="Error"
			title_msg_question="Question"
			title_msg_warning="Warning"
			title_msg_progress="Operation progress"
			title_entry_install_pkg="Install package"
		# MAIN MENU ITEMS
			menu_column_options="$name - Options"
			menu_option_configure_apt_sources_list="Configure APT \"sources.list\""
			menu_option_update_apt_database="Update APT database"
			menu_option_update_system="Update system"
			menu_option_copy_apt_cache="Copy APT cache to mini-repo directory"
			menu_option_clean_apt_cache="Clean APT cache"
			menu_option_clean_work_dir_verbose="Delete repeated packages in mini-repo directory and keep packages last version"
			menu_option_generate_mini_repo_pkgs_list="Get the mini-repo packages list"
			menu_option_mini_repo_incremental_update="Incrementally mini-repo update"
			menu_option_update_mini_repo="Update mini-repo packages to last version form an on-line repo (update mini-repo)"
			menu_option_create_repo_iso_aptoncd="Create mini-repo ISO file using AptOnCD"
			menu_option_create_repo_scanpkgs="Create mini-repo Packages.gz file using dpkg-scanpackages"
			menu_option_create_repo_pc_installed_pkg="Create mini-repo with the packages installed on this PC"
			menu_option_replicate_mini_repo="Turn a mini-repo into another version of the same distribution (e.g Ubuntu 12.04 into 12.10)"
			menu_option_mount_repo_iso="Mount a mini-repo ISO file"
			menu_option_create_mini_repo="Create a mini-repo with selected applications"
			menu_option_install_pkg="Install a package"
			menu_option_quit="Quit"
		#INFO MESSAGES
			msg_main_menu="Select the action you want to execute:"
			msg_update_apt_database_success="\n\n$menu_option_update_apt_database: done successfully\n"
			msg_update_system_success="\n\n$menu_option_update_system: done successfully\n"
			msg_copy_apt_cache_success="$menu_option_copy_apt_cache: done successfully"
			msg_clean_apt_cache_success="$menu_option_clean_apt_cache: done successfully"
			msg_clean_work_dir_verbose_success="$menu_option_clean_work_dir_verbose: done successfully"
			msg_generate_mini_repo_pkgs_list_success="The mini-repo packages list is been generated successfully in"
			msg_download_pkgs_last_version_success="$menu_option_update_mini_repo: done successfully"
			msg_create_repo_iso_aptoncd_success="$menu_option_create_repo_iso_aptoncd: done successfully"
			msg_create_repo_scanpkgs_success="$menu_option_create_repo_scanpkgs: done successfully. Packages.gz file created in"
			msg_mount_repo_iso_success="$menu_option_mount_repo_iso: done successfully"
			msg_create_mini_repo_fail="Sorry, create a valid applications list and try again"
			msg_install_app="has to be installed to complete this task. Do you want to install it?"
			msg_install_pkg_success=" was successfully installed\n"
			msg_pkg_already_installed="Package is already installed:"
			msg_create_repo_app_list="To perform this task you have to create the mini-repo applications list. Do you want to create it now?"
			msg_downloading_app_success="Download completed successfully"
		#ERROR MESSAGES
			msg_error_updating_apt_database="\n\nSorry, the APT database could not be updated. Check for your \"sources.lit\" and your connection configuration and try again\n"
			msg_error_updating_system="\n\nSorry, the system could not be updated. Check for your \"sources.lit\" and your connection configuration and try again\n"
			msg_error_cleaning_apt_cache="Sorry, APT cache could not be cleaned"
			msg_error_no_pkgs_to_download="No packages to download from on-line repo"
			msg_error_downloading_pkgs_last_version="Package not available in on-line repo:"
			msg_error_creating_repo_iso_aptoncd="Sorry, AptOnCD could not create the mini-repo ISO file"
			msg_error_mounting_repo_iso="Sorry, the ISO file could not be mounted"
			msg_error_installing_pkg=" could not be installed, try to install it manually\n"
			msg_error_pkg_info_not_available="Sorry, package version information is not available in on-line repo:"
			msg_error_pkg_not_available_online="Package is not available in on-line repo:"
			msg_error_pkg_not_found="Sorry, package not found, make sure the package name is right spelled:"
			msg_error_no_pkgs_in_this_directory="Sorry, there are no packages in this directory, select another and try again"
			msg_error_no_pkgs_in_apt_cache="Sorry, there are no packages to copy from APT cache"
			msg_error_no_repeated_pkgs_in_this_directory="Sorry, there are no repeated packages in this directory"
			msg_error_copying_apt_cache="Sorry, APT cache could not be copied"
			msg_error_wrong_password="Sorry, wrong password for root"
		#WARNING MESSAGES
			msg_warning_dpkg_scanpkgs="Creating Packages.gz file will take some time and you will see nothing on your screen until the process is finished"
		#PROGRESS BARS MESSAGES
			msg_progress_installing_pkg="Installing application:"
			msg_progress_cleaning_work_dir="Cleaning work directory..."
			msg_progress_copying_apt_cache="Copying APT cache..."
			msg_progress_updating_apt_database="Updating APT database...\n\n"
			msg_progress_sys_update="Updating system...\n\n"
			msg_progress_cleaning_apt_cache="Cleaning APT cache..."
			msg_progress_downloading_pkg_online="Downloading packages from on-line repo..."
		#OTHERS DIALOGS MESSAGES
			msg_entry_install_pkg="Enter the name of the package you want to install"
			msg_entry_enter_root_password="Enter your root password"
			msg_text_info_pkgs_not_downloaded="Following packages could not be downloaded:"
		#OTHERS
			ans_yes="Yes"
			ans_no="No"
	;;
esac

#===============================================================================
# FUNCTIONS DEFINITION BLOCK
#===============================================================================

################################################################################
# GENERAL USE FUNCTIONS

f_set_working_dir()
{
	# Keeps track of working directory (last review 04/02/14).

	# if working directory do not exists
	if [[ ! -e "$working_dir" || ! -w "$working_dir" ]]
	then
		# use home directory as working directory
		working_dir="$HOME"
		# update the working-dir.conf configuration file
		printf "$working_dir" > "$config_dir"/working-dir.conf
	fi
}

f_operation_progress_info()
{
	# Shows operation progress information (last review 16/05/14).
	
	zenity --text-info \
			--title="$title_msg_progress" \
			--width=500 \
			--height=400 # show the output of the operation
}

f_download_progress()
{
	# Shows operation progress (last review 16/05/14).
	
	# progreso de la operación
	zenity --progress \
			--title="$title_msg_progress" \
			--text="$msg_progress_downloading_pkg_online" \
			--auto-close \
			--width=500 \
			--height=60
}

f_run_as_root()
{
	# Runs any command as root. It recibes the command to execute as the $1 
	# parameter always inside double quotes (last review 28/05/14).

	gksudo --message "$msg_entry_enter_root_password" "$1"
}

f_get_dir_pkgs_list()
{
	# Gets the list of packages in any directory (last review 12/09/14).
	
	cd "$1"
	# do we need the whole package's file name?
	need_pkg_whole_name="$2" # is true or false
	if [ "$need_pkg_whole_name" = true ]
	then
		ls *.deb
	else
		ls *.deb | cut -f1 -d "_"
	fi
}

f_get_pkg_version()
{
	# Gets the version of a package (last review 22/10/14).
	# To call: f_get_pkg_version $1=$working_dir 
	# $2="local" (local pkg) or "on-line" (on line pkg) $3=pkg
	
	cd "$1" # cd to working directory
	pkg_location="$2" # is local or on-line?
	if [ $pkg_location = "local" ]
	then
		dpkg-deb --show "$3"* | cut -f2 # Gets the version of a local package
	elif [ $pkg_location = "on-line" ]
	then
		apt-cache --no-all-versions show "$3" 2>/dev/null | grep -m 1 Version: \
			| cut -f2 -d " "
	fi
}

f_download_single_pkg()
{
	# Downloads a single package (last review 12/09/14).

	# downloads the package using its uri
	wget -c $(apt-get download --print-uris "$1" | cut -f2 -d "'") &>/dev/null
}

f_download_list_of_pkgs()
{
	# Downloads a list of packages using their uris (last review 12/09/14).

	cd "$1"
	if ls *.deb &>/dev/null # look for packages
	then
		# delete the repeated packages and keep the last version
		f_clean_working_dir_silent "$1"
		i=0
		for pkg in $2
		do
			# check if package is available on-line
			if apt-cache --no-all-versions show "$pkg" &>/dev/null
			then
				# test if package's version info is available
				if [[ ! -z $(f_get_pkg_version . "on-line" "$pkg") && \
					! -z $(f_get_pkg_version . "local" "$pkg") ]]
				then
					# compare the packages versions
					if dpkg --compare-versions $(f_get_pkg_version . "on-line" "$pkg") \
						gt $(f_get_pkg_version . "local" "$pkg") &>/dev/null
					then
						# download the package fi online version is higher
						f_download_single_pkg "$pkg"
					fi
				elif [ -z $(f_get_pkg_version . "on-line" "$pkg") ]
				then
					# no encuentra la información de la version del paquete
					zenity --error \
							--title "$title_msg_error" \
							--text "$msg_error_pkg_info_not_available ("$pkg")"
					# download package anyway
					f_download_single_pkg "$pkg"
				else
					# download the package because is not in the local directory
					f_download_single_pkg "$pkg"
				fi
			else
				# el paquete no está disponible en el repo on-line
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_pkg_not_available_online ("$pkg")"
			fi
			let i="$i"+1
			# Calcula el porciento de avance de la operación
			progress_percent=$(echo "scale=2; ($i/$3*100)" | bc)
			echo "$progress_percent"
		done | f_download_progress
	else
		# download the whole packages' list
		for pkg in $2
		do
			# check if package is available on-line
			if apt-cache --no-all-versions show "$pkg" &>/dev/null
			then
				# download the package 
				f_download_single_pkg "$pkg"
			else
				# el paquete no está disponible en el repo on-line
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_pkg_not_available_online ($pkg)"
			fi
			let i="$i"+1
			# Calcula el porciento de avance de la operación
			progress_percent=$(echo "scale=2; ($i/$3*100)" | bc)
			echo "$progress_percent"
		done | f_download_progress
	fi
}

f_clean_working_dir_silent()
{
	# Deletes the repeated packages (with different version number) in the working
	# directory. It recibes the working directory as parameter
	# (last review 20/10/14).
	
	# toma el nombre de los archvos .deb repetidos en el directorio de
	# trabajo y los almacena en repeated-pkgs.txt
	[ -w "$1" ] && cd "$1" && ls *.deb | cut -f1 -d "_" | sort \
		| uniq -d 1>repeated-pkgs.txt 2>/dev/null
	# comprueba la existencia del fichero repeated-pkgs.txt y su contenido,
	# si está vacío no hay paquetes repetidos
	if [[ -e repeated-pkgs.txt && -s repeated-pkgs.txt ]]
	then
		# almacena el nombre de los paquetes repetidos en una variable
		repeated_pkgs=$(< repeated-pkgs.txt)
		rm repeated-pkgs.txt # borra el fichero temporal tmp.txt
		i=0
		# compara los ficheros repetidos y borra las versiones antiguas
		for repeated in $repeated_pkgs
		do
			# almacena cada conjunto de ficheros repetidos en la variable reps
			reps=$(find "$repeated"* | sort -V)
			j=0
			# elimina los paquetes repetidos del directorio de trabajo,
			# dejando solamente las versiones mas recientes
			for rep in $reps
			do
				pkg_whole_name[$j]="$rep"
				# la variable j debe ser mayor que cero para que no tome
				# el primer valor del array y se vaya de rango al comparar
				if [ "$j" -gt 0 ]
				then
					# obtiene la versión del paquete j ubicado en el directorio
					dir_version_j=$(dpkg-deb --show "${pkg_whole_name[$j]}" \
									| cut -f 2)
					# obtiene la versión del paquete j-1 ubicado en el directorio
					dir_version_j_1=$(dpkg-deb --show "${pkg_whole_name[$j-1]}" \
									| cut -f 2)
					# compara las versiones y borra uno u otro paqute
					if dpkg --compare-versions "$dir_version_j" gt "$dir_version_j_1"
					then
						# borra el paquete j-1 del directorio de trabajo
						rm -f --interactive=never "${pkg_whole_name[$j-1]}"
					else
						# borra el paquete j del directorio de trabajo
						rm -f --interactive=never "${pkg_whole_name[$j]}"
					fi
				fi
				let j="$j"+1
			done
			let i="$i"+1
		done
	elif [ -e repeated-pkgs.txt ] # file exists?
	then
		rm repeated-pkgs.txt # delete repeated-pkgs.txt
	fi
}

################################################################################
# SPECIFIC USE FUNCTIONS

f_install_aptitude()
{
	# Installs aptitude (last review 28/05/14).
	
	# test if aptitude is installed
	if type aptitude &> /dev/null
	then
		return 0 # return true if aptitude is already installed on the system
	elif zenity --question \
				--title "$title_msg_question" \
				--text "aptitude $msg_install_app" \
				--ok-label "$ans_yes" \
				--cancel-label "$ans_no" # install aptitude?
	then
		{
			printf "$msg_progress_installing_pkg (aptitude)...\n\n"
			f_run_as_root "apt-get install --assume-yes --force-yes aptitude"
			if [ "$?" -eq 0 ] # test if aptitude installed correctly
			then
				# aptitude is correctly installed
				printf "\n(aptitude): $msg_install_pkg_success"
				return 0 # return true if aptitude is correctly installed
			else
				# if aptitude could not be installed
				printf "\n(aptitude): $msg_error_installing_pkg"
				return 1 # return true if aptitude could not be installed
			fi
		} | f_operation_progress_info
	fi
}

f_install_required_pkg()
{
	# Installs script required pkgs (last review 26/05/14).
	
	if f_install_aptitude # test if aptitude is installed...
	then
		# test if package is already installed on the system
		if dpkg --get-selections | grep "$1" &> /dev/null
		then
			return 0 # return true if package is installed
		elif zenity --question \
					--title "$title_msg_question" \
					--text "($1): $msg_install_app" \
					--ok-label "$ans_yes" \
					--cancel-label "$ans_no"
		then
			{
				printf "$msg_progress_installing_pkg ($1)\n\n"
				# instala la aplicacion
				f_run_as_root "aptitude install --assume-yes --allow-untrusted $1"
				if [ "$?" -eq 0 ]
				then
					printf "\n($pkg): $msg_install_pkg_success"
					return 0 # return true if package is installed
				else
					printf "\n($pkg): $msg_error_installing_pkg"
					return 1 # return false if package could not be installed
				fi
			} | zenity --text-info \
						--title="$title_msg_progress" \
						--width=500 --height=400 # show progress and outputs
		fi
	fi
}

################################################################################
# MAIN MENU OPTIONS FUNCTIONS

f_configure_apt_sourses_list()
{
#=== FUNCTION ==================================================================
# NAME: 		f_configure_apt_sourses_list
# DESCRIPTION:	Open sources.list file as root for editing
#				(menu_option_configure_apt_sources_list).
# PARAMETER 1:	---
# REVISION:		30/09/14
#===============================================================================
	
	editors_list="gedit kate leafpad pluma"	# some popular GUI text editors
	for editor in $editors_list
	do
		# test if a text editor is installed
		if type "$editor" &> /dev/null
		then
			f_run_as_root "$editor $sources_list_file" # open sources.list file
			break
		fi
	done
}

f_update_apt_database()
{
	# Update apt database (menu_option_update_apt_database) (last review 03/10/14).
	
	if f_install_aptitude # test if aptitude is installed
	then
		{
			printf "$msg_progress_updating_apt_database" # beginning message
			f_run_as_root "aptitude update" 2>&1 # update apt database
			if [ "$?" -eq 0 ] # apt database is updated?
			then
				printf "$msg_update_apt_database_success" # success
			else
				printf "$msg_error_updating_apt_database" # fail
			fi
		} | f_operation_progress_info
	fi
}

f_update_system()
{
	# Update the system (menu_option_update_system) (last review 25/05/14).
	
	{
		printf "$msg_progress_sys_update" # begin the system updating
		# get root and update the system
		f_run_as_root "aptitude safe-upgrade --assume-yes --allow-untrusted"
		if [ "$?" -eq 0 ] # test if system was successfully updated
		then
			printf "$msg_update_system_success" # success
		else
			printf "$msg_error_updating_system" # fail
		fi
	} | f_operation_progress_info
}

f_copy_apt_cache()
{
	# Copia los ficheros descargados en la cache de apt al directrorio de trabajo
	# (menu_option_copy_apt_cache) (last review 01/06/14).
	
	
	cd "$apt_cache" # cd to apt cache directory
	# copia los archivos de la caché de apt para el directorio de trabajo
	if ls *.deb &> /dev/null
	then
		# selecciona el directorio de trabajo o destino
		if working_dir=$(zenity --title "$title_select_destiny_dir" \
								--file-selection \
								--directory \
								--filename="$working_dir"/)
		then
			# test if data can be written
			if [ -w $working_dir ]
			then
				# copia los paqutes de la caché de APT y muestra el progreso
				i=1
				cp -v -f "$apt_cache"/*.deb "$working_dir" &>/dev/null \
					&& i="$?" \
					| zenity --progress \
							--title="$title_msg_progress" \
							--text="$msg_progress_copying_apt_cache" \
							--auto-close \
							--no-cancel \
							--pulsate \
							--width=250 \
							--height=60
			fi
			# si ocurre un error copiando la cache...
			if [ "$i" -eq 0 ]
			then
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_copying_apt_cache"
			else
				zenity --info \
						--title "$title_msg_info" \
						--text "$msg_copy_apt_cache_success"
			fi
			f_clean_working_dir_silent "$working_dir"
		fi
	else
		zenity --error \
				--title "$title_msg_error" \
				--text "$msg_error_no_pkgs_in_apt_cache"
	fi
	cd "$working_dir" # retorna al directorio de trabajo
}

f_clean_apt_cache()
{
	# funcion que limpia la cache de apt en el sistema
	# (menu_option_clean_apt_cache) (last review 25/05/14)

	i=1
	f_run_as_root "apt-get clean" 2>"$script_dir"/error.log && i=0 \
		| zenity --progress \
				--title="$title_msg_progress" \
				--text="$msg_progress_cleaning_apt_cache" \
				--auto-close \
				--no-cancel \
				--pulsate \
				--width=250 \
				--height=60
	if [ "$i" -eq 0 ] # si no se limpió correctamente la caché
	then
		zenity --error \
				--title "$title_msg_error" \
				--text "$msg_error_cleaning_apt_cache"
	else
		zenity --info \
				--title "$title_msg_info" \
				--text "$msg_clean_apt_cache_success"
	fi
}

f_create_mini_repo()
{
	# Crea un mini-repo con las aplicaciones listadas por el usuario, descargando
	# además las dependencias (menu_option_create_mini_repo) (last review 01/06/14).
	
	if zenity --question \
				--title "$title_msg_question" \
				--text "$msg_create_repo_app_list" \
				--ok-label "$ans_yes" \
				--cancel-label "$ans_no"
	then
		# comprueba si la aplicacion esta instalada
		if type gedit &> /dev/null
		then
			gedit "$script_dir"/config/app-list.txt
		fi
		# comprueba si el fichero app-list.txt no está vacío
		if [ -s "$script_dir"/config/app-list.txt ]
		then
			# selecciona el directorio de trabajo
			if working_dir=$(zenity --title "$title_select_destiny_dir" \
									--file-selection \
									--directory \
									--filename="$working_dir"/)
			then
				cd "$working_dir" # cd to working directory
				# almacena las aplicaciones del usuario en una variable
				apps_list=$(< "$script_dir"/config/app-list.txt)
				# identifica las dependencias de los paquetes y las almacena
				# en all-depends.txt
				for app in $apps_list
				do
					# obtiene todas las dependencias de los pkgs seleccionados
					# por el usuario
					apt-cache depends "$app" \
						| grep -Ev "(Repl|Reempl|Confl|PreDep|<)" \
						| sed -r 's/^\s+?(.+: )?(.+)$/\2/g' >> all-depends.txt
				done
				if [[ -e all-depends.txt && -s all-depends.txt ]]
				then
					{
						# toma las dependencias no repetidas
						cat all-depends.txt | sort | uniq -u
						# toma una sola vez, las dependencias repetidas
						cat all-depends.txt | sort | uniq -d
					} > pkgs-to-download.txt # almacena las dependencias en pkgs-to-download.txt
					rm all-depends.txt
					if [[ -e pkgs-to-download.txt && -s pkgs-to-download.txt ]]
					then
						# almacena el contenido del fichero to-download.txt en
						# una variable
						pkgs_to_download=$(< pkgs-to-download.txt)
						# determina la cantidad de paquetes repetidos
						number=$(wc -l < pkgs-to-download.txt)
						# elimina el fichero to-download.txt
						rm pkgs-to-download.txt
						# download the packages
						f_download_list_of_pkgs "$working_dir" "$pkgs_to_download" \
							"$number"
					fi
				fi
			fi
		else
			zenity --error \
					--title "$title_msg_error" \
					--text "$msg_create_mini_repo_fail"
		fi
	fi
}

f_clean_working_dir_verbose()
{
	# Elimina los paquetes repetidos (con versiones diferentes) en el directorio
	# de trabajo (menu_option_clean_work_dir_verbose) (last review 21/08/14).
	
	# selecciona el directorio de trabajo
	if working_dir=$(zenity --title "$title_select_source_dir" \
							--file-selection \
							--directory \
							--filename="$working_dir"/)
	then
		# toma el nombre de los archvos .deb repetidos en el directorio
		# de trabajo y los almacena en repeated-pkgs.txt
		[ -w "$working_dir" ] \
			&& cd "$working_dir" \
			&& ls -1 *.deb \
			| sed -e "s/_.*/_/g" \
			| sort \
			| uniq -d 1>repeated-pkgs.txt 2> /dev/null
		# comprueba la existencia del fichero repeated-pkgs.txt
		# y su contenido, si está vacío no hay paquetes repetidos
		if [[ -e repeated-pkgs.txt && -s repeated-pkgs.txt ]]
		then
			# almacena los nombres de los paquetes repetidos en una variable
			repeated_pkgs=$(< repeated-pkgs.txt)
			# determina la cantidad de paquetes repetidos
			number=$( wc -l < repeated-pkgs.txt )
			rm repeated-pkgs.txt # borra el fichero temporal tmp.txt
			i=0
			# compara los ficheros repetidos y borra las versiones antiguas
			for repeated in $repeated_pkgs
			do
				# almacena los ficheros repetidos en la variable reps
				reps=$( find "$repeated"* | sort -V )
				j=0
				# elimina los paquetes repetidos del directorio de trabajo,
				# dejando solamente las versiones mas recientes
				for rep in $reps
				do
					pkg_whole_name[$j]="$rep"
					# la variable j debe ser mayor que cero para que no tome
					# el primer valor del array y se vaya de rango al comparar
					if [ "$j" -gt 0 ]
					then
						# obtiene la versión del paquete j en el directorio
						dir_version_j=$(dpkg-deb --show ${pkg_whole_name[$j]} \
							| cut -f 2)
						# obtiene la versión del paquete j-1 en el directorio
						dir_version_j_1=$(dpkg-deb --show ${pkg_whole_name[$j-1]} \
							| cut -f 2)
						# compara las versiones y elimina uno u otro
						if dpkg --compare-versions "$dir_version_j" \
												gt "$dir_version_j_1"
						then
							# borra el paquete j-1 del directorio de trabajo
							rm -f --interactive=never ${pkg_whole_name[$j-1]}
						else
							# borra el paquete j del directorio de trabajo
							rm -f --interactive=never ${pkg_whole_name[$j]}
						fi
					fi
					let j="$j"+1
				done
				let i="$i"+1
				# Calcula el porciento de avance de la operación
				progress_percent=$(echo "scale=2; ($i/($number)*100)" | bc)
				echo "$progress_percent"
			done | zenity --progress \
							--title="$title_msg_progress" \
							--text="$msg_progress_cleaning_work_dir" \
							--auto-close \
							--no-cancel \
							--width=350 \
							--height=60 &>>"$script_dir"/error.log # progreso de la operación
			zenity --info \
					--title "$title_msg_info" \
					--text "$msg_clean_work_dir_verbose_success"
		else
			zenity --error \
					--title "$title_msg_error" \
					--text "$msg_error_no_repeated_pkgs_in_this_directory"
			# si existe el archivo lo elimina
			[ -e repeated-pkgs.txt ] && rm repeated-pkgs.txt
		fi
	fi
}

f_update_mini_repo()
{
	# funcion que descargar las ultimas versiones de los paquetes desactualizados
	# (menu_option_update_mini_repo) (last review 29/05/14)
	
	# get the path where actual mini-repo is located
	if working_dir=$(zenity --title "$title_select_source_dir" \
							--file-selection \
							--directory \
							--filename="$working_dir"/)
	then
		cd "$working_dir" # cd al directorio de trabajo
		if ls *.deb &>/dev/null # look for packages
		then
			# delete the repeated packages and keep the last version
			f_clean_working_dir_silent "$working_dir"
			# get the list of pkgs' names in the working directory
			pkgs_list=$(f_get_dir_pkgs_list "$working_dir" false)
			# obtien la cantidad de paquetes en el directorio
			number=$(ls | grep -c .deb)
			f_download_list_of_pkgs "$working_dir" "$pkgs_list" "$number"
		else
			zenity --error \
					--title "$title_msg_error" \
					--text "$msg_error_no_pkgs_in_this_directory"
		fi
	fi
}

f_create_repo_iso_aptoncd()
{
	# Generate a mini-repo iso file using aptoncd
	# (menu_option_create_repo_iso_aptoncd) (last review 16/05/14).
	
	pkg="aptoncd" # aptoncd is required
	if f_install_required_pkg "$pkg" # test if aptoncd is installed...
	then
		# define the working directory
		if working_dir=$(zenity --title "$title_select_source_dir" \
								--file-selection \
								--directory \
								--filename="$working_dir"/)
		then
			# delete the repeated packages and keep the last version
			f_clean_working_dir_silent "$working_dir"
			# run aptoncd using the working directory as cache
			if aptoncd --cache-dir "$working_dir" \
						--temp-dir "$working_dir" \
						1>/dev/null \
						2>>"$script_dir"/error.log
			then
				# success...
				zenity --info \
						--title "$title_msg_info" \
						--text "$msg_create_repo_iso_aptoncd_success"
			else
				# fail...
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_creating_repo_iso_aptoncd"
			fi
		fi
	fi
}

f_create_repo_scanpackages()
{
	# Creates a mini-repon packages.gz file using scanpackages
	# (menu_option_create_repo_scanpkgs) (last review 16/05/14).

	pkg="dpkg-dev" # paquete requerido
	if f_install_required_pkg "$pkg" # si la aplicación está instalada...
	then
		# selecciona el dirctorio de trabajo
		if working_dir=$(zenity --title "$title_select_source_dir" \
								--file-selection \
								--directory \
								--filename="$working_dir"/)
		then
			# delete the repeated packages and keep the last version
			f_clean_working_dir_silent "$working_dir"
			# cd al directorio de trabajo
			cd "$working_dir"
			# get the name of the working directory
			working_dir_name=${working_dir##*/}
			# comprueba si hay paquetes en el directorio de trabajo
			if ls *.deb &> /dev/null
			then
				zenity --warning \
						--title "$title_msg_warning" \
						--text "$msg_warning_dpkg_scanpkgs"
				cd .. # get up to parent directory
				# escanea el directorio de trabajo y genera el Packages.gz
				if dpkg-scanpackages "$working_dir_name" \
					2>>"$script_dir"/error.log \
					| gzip > Packages.gz
				then
					zenity --info \
							--title "$title_msg_info" \
							--text "$msg_create_repo_scanpkgs_success \"$PWD\""
				fi
				cd "$working_dir" # cd al directorio de trabajo
			else
				# no hay paquetes en el directorio
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_no_pkgs_in_this_directory"
			fi
		fi
	fi
}

f_replicate_dir_pkgs_list()
{
	# Funcion que extrae los nombres de los paquetes presentes en el directorio
	# del mini-repo, los almacena en el fichero repodir-pkgs-list.txt y luego los
	# descarga del repo on-line (menu_option_replicate_mini_repo)
	# (last review 15/05/14).

	# directorio donde se encuentran los paquetes del mini-repo
	f_configure_apt_sourses_list
	f_update_apt_database
	if source_dir=$(zenity --title "$title_select_source_dir" \
							--file-selection \
							--directory \
							--filename="$working_dir"/)
	then
		working_dir="$source_dir" # actualiza el directorio de trabajo
		cd "$working_dir" # cd al directorio de trabajo
		# comprueba si hay paquetes en el directorio de trabajo
		if ls *.deb &> /dev/null
		then
			f_clean_working_dir_silent "$working_dir"
			# almacena los nombre de los paquetes en una variable
			pkgs_list=$(f_get_dir_pkgs_list "$working_dir" false)
			# determina la cantidad de paquetes a descargar
			number=$(ls | grep -c .deb)
			# directorio donden almacenar los paquetes a descargar
			if destiny_dir=$(zenity --title "$title_select_destiny_dir" \
									--file-selection \
									--directory \
									--filename="$working_dir"/)
			then
				working_dir="$destiny_dir" # actualiza el directorio de trabajo
				cd "$working_dir" #cambia al directorio de descarga
				f_download_list_of_pkgs "$working_dir" "$pkgs_list" "$number" 
				f_clean_working_dir_silent "$working_dir"
			fi
		else
			# no hay paquetes en el directorio
			zenity --info \
					--title "$title_msg_info" \
					--text "$msg_error_no_pkgs_in_this_directory"
		fi
	fi
}

f_mount_mini_repo_iso()
{
	# Mount a mini-repo iso file or any other iso file
	# (menu_option_mount_repo_iso) (last review 28/05/14).

	if source_iso_file=$(zenity --title "$title_select_iso_file" \
							--file-selection \
							--file-filter=*.iso \
							--filename="$HOME"/)
	then
		if destiny_dir=$(zenity --title "$title_select_mount_point" \
								--file-selection \
								--directory \
								--filename="/media/")
		then
			# mount a mini-repo iso file
			f_run_as_root "mount -o loop -t iso9660 $source_iso_file $destiny_dir" \
				1>/dev/null \
				2>>$script_dir/error.log
			if [ "$?" -eq 0 ]
			then
				zenity --info \
						--title "$title_msg_info" \
						--text "$msg_mount_repo_iso_success" # success...
			else
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_mounting_repo_iso" # fail...
			fi
		fi
	fi
}

f_install_single_pkg()
{
	# Install a package difened by the user (menu_option_install_pkg)
	# (last review 28/05/14).

	if f_install_aptitude # test if aptitude is installed...
	then
		# ask for package name
		if pkg=$(zenity --entry \
						--title "$title_entry_install_pkg" \
						--text "$msg_entry_install_pkg")
		then
			# test if package is available on-line
			if apt-cache --no-all-versions show "$pkg" &> /dev/null
			then
				# test if package is already installed on the system
				if dpkg --get-selections | grep "$pkg" &> /dev/null
				then
					zenity --info \
							--title "$title_msg_info" \
							--text "$msg_pkg_already_installed ($pkg)"
				else
					{
						# begin the installation process
						printf "$msg_progress_installing_pkg ($pkg)\n\n"
						# install the package
						f_run_as_root "aptitude install --assume-yes --allow-untrusted $pkg"
						if [ "$?" -eq 0 ] # if installation is successful
						then
							printf "\n($pkg): $msg_install_pkg_success" # success
						else
							printf "\n($pkg): $msg_error_installing_pkg" # fail
						fi
					} | f_operation_progress_info
				fi
			else
				# fail: package is available on-line
				zenity --error \
						--title "$title_msg_error" \
						--text "$msg_error_pkg_not_found ($pkg)"
			fi
		fi
	fi
}

f_add_mini_repo_to_sources_list()
{
	# Add the mini-repo to sources_list. It gets the mini-repo directory as uniq
	# parameter (last review 13/09/14).

	if working_dir=$(zenity --title "$title_select_source_dir" \
							--file-selection \
							--directory \
							--filename="$working_dir"/)
	then
		cat $sources_list_file > "$HOME"/tmp
		if ! grep "$working_dir" "$HOME"/tmp &>/dev/null
		then
			printf "deb file:$working_dir /" >> "$HOME"/tmp
			f_run_as_root "cp "$HOME"/tmp $sources_list_file"
			rm "$HOME"/tmp
		fi
	fi
}

f_generate_mini_repo_pkgs_list()
{
	# Generate a mini-repo packages list
	# (menu_option_generate_mini_repo_pkgs_list) (last review 12/05/14).

	# selecciona el directorio de trabajo
	if working_dir=$(zenity --title "$title_select_source_dir" \
							--file-selection \
							--directory \
							--filename=$working_dir/)
	then
		cd "$working_dir"
		if ls *.deb &> /dev/null # Comprueba si hay paquetes en el directorio
		then
			# si se puede escribir en el directorio de trabajo...
			if [ -w "$working_dir" ]
			then
				ls -1 *.deb | sort > mini-repo-pkgs-list.txt
				zenity --info \
						--title "$title_msg_info" \
						--text "$msg_generate_mini_repo_pkgs_list_success $working_dir"
			else
				ls -1 *.deb | sort > "$HOME"/mini-repo-pkgs-list.txt
				zenity --info \
						--title "$title_msg_info" \
						--text "$msg_generate_mini_repo_pkgs_list_success $HOME"
			fi
		else
			zenity --error \
					--title "$title_msg_error" \
					--text "$msg_error_no_pkgs_in_this_directory"
		fi
	fi
}

f_mini_repo_incremental_update()
{
	# Copy the packages updated to a selected directory (last review 03/10/14).
	
	# selecciona el directorio de trabajo o fuente
	if source_dir=$(zenity --title "$title_select_source_dir" \
							--file-selection \
							--directory \
							--filename="$working_dir"/)
	then
		cd "$source_dir"
		pkgs_list=$(f_get_dir_pkgs_list "$source_dir" true)
		# selecciona el fichero con la lista de paquetes
		if mini_repo_pkgs_list=$(zenity --title "$title_select_pkgs_list_file" \
										--file-selection \
										--file-filter=*.txt \
										--filename="/media/")
		then
			for pkg in $pkgs_list
			do
				if ! grep -x "$pkg" "$mini_repo_pkgs_list"
				then
					printf "$pkg\n" >>pkgs-to-copy.txt
				fi
			done
			if destiny_dir=$(zenity --title "$title_select_destiny_dir" \
										--file-selection \
										--directory \
										--filename="/media/")
			then
				if [[ -e pkgs-to-copy.txt && -s pkgs-to-copy.txt && -w $destiny_dir ]]
				then
					cp $(< pkgs-to-copy.txt) "$destiny_dir"
					rm pkgs-to-copy.txt
				fi
			fi
		fi
	fi
}

f_create_repo_pc_installed_pkg()
{
	# Create mini-repo with the packages installed on this PC
	# (menu_option_create_repo_pc_installed_pkg) (last review 15/05/14).

	# directorio donde almacenar los paquetes a descargar
	if destiny_dir=$(zenity --title "$title_select_destiny_dir" \
							--file-selection \
							--directory \
							--filename="/media/")
	then
		working_dir="$destiny_dir" # actualiza el directorio de trabajo
		cd "$working_dir" # cd al directorio donde se descargaran los paquetes
		number=$(dpkg --get-selections | wc -l) # obtien la cantidad de paquetes
		# store in a variable the list of installed packages
		pkgs_list=$(dpkg --get-selections | cut -f1)
		f_download_list_of_pkgs "$working_dir" "$pkgs_list" "$number" 
	fi
}

#===============================================================================
# SCRIPT MAIN BLOCK
#===============================================================================

# At the beginning, do...
echo "################## Running $name $version error.log - DATE: $(date +%F) \
	- TIME: $(date +%R) ##################" >"$script_dir"/error.log

f_set_working_dir

# Main Menu Loop
while true
do
	# Show aplication Main Menu
	main_menu=$( zenity --list \
						--radiolist \
						--title="$title_main_menu" \
						--text="$msg_main_menu" --column="" \
						--column="$menu_column_options" --width=750 \
						--height=510 \
						TRUE "$menu_option_configure_apt_sources_list" \
						FALSE "$menu_option_update_apt_database" \
						FALSE "$menu_option_update_system" \
						FALSE "$menu_option_copy_apt_cache" \
						FALSE "$menu_option_clean_apt_cache" \
						FALSE "$menu_option_create_mini_repo" \
						FALSE "$menu_option_update_mini_repo" \
						FALSE "$menu_option_clean_work_dir_verbose" \
						FALSE "$menu_option_generate_mini_repo_pkgs_list" \
						FALSE "$menu_option_mini_repo_incremental_update" \
						FALSE "$menu_option_create_repo_iso_aptoncd" \
						FALSE "$menu_option_create_repo_scanpkgs" \
						FALSE "$menu_option_create_repo_pc_installed_pkg" \
						FALSE "$menu_option_replicate_mini_repo" \
						FALSE "$menu_option_mount_repo_iso" \
						FALSE "$menu_option_install_pkg" \
						FALSE "$menu_option_quit" )

	case "$main_menu" in # run user selected action
		"$menu_option_configure_apt_sources_list" )
			f_configure_apt_sourses_list
		;;
		"$menu_option_update_apt_database" )
			f_update_apt_database
		;;
		"$menu_option_update_system" )
			f_update_system
		;;
		"$menu_option_copy_apt_cache" )
			f_copy_apt_cache
		;;
		"$menu_option_clean_apt_cache" )
			f_clean_apt_cache
		;;
		"$menu_option_clean_work_dir_verbose" )
			f_clean_working_dir_verbose
		;;
		"$menu_option_generate_mini_repo_pkgs_list" )
			f_generate_mini_repo_pkgs_list
		;;
		"$menu_option_mini_repo_incremental_update" )
			f_mini_repo_incremental_update
		;;
		"$menu_option_update_mini_repo" )
			f_update_mini_repo
		;;
		"$menu_option_create_repo_iso_aptoncd" )
			f_create_repo_iso_aptoncd
		;;
		"$menu_option_create_repo_scanpkgs" )
			f_create_repo_scanpackages
		;;
		"$menu_option_create_repo_pc_installed_pkg" )
			f_create_repo_pc_installed_pkg
		;;
		"$menu_option_replicate_mini_repo" )
			f_replicate_dir_pkgs_list
		;;
		"$menu_option_mount_repo_iso" )
			f_mount_mini_repo_iso
		;;
		"$menu_option_create_mini_repo" )
			f_create_mini_repo
		;;
		"$menu_option_install_pkg" )
			f_install_single_pkg
		;;
		"$menu_option_quit" )
			break # finish the loop
		;;
		* )
			break # finish the loop
		;;
	esac
done

# At the end, do...
echo "################## Exit $name $version error.log - DATE: $(date +%F) \
	- TIME: $(date +%R) ##################" >>$script_dir/error.log

# Update configuration file
printf "$working_dir" > "$config_dir"/working-dir.conf

# DEBUGGING TOOLS
# uncomment these lines to debug the script
#export PS4='+ $LINENO: ' ## single quotes prevent $LINENO being expanded immediately
#set -x # prints each command with its expanded arguments as it is executed

# run the script with: bash -n scriptname to look for syntax errors

#===============================================================================
#===============================================================================
# Script finished OK
exit 0
