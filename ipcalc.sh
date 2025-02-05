#!/bin/bash

# Colores

blackcolour="\e[30m"
redcolour="\e[31m"
greencolour="\e[32m"
endcolour="\e[0m"
yellowcolour="\e[33m"
bluecolour="\e[34m"
pinkcolour="\e[35m"
ciancolour="\e[36m"
whitecolour="\033[1;37m"
graycolour="\e[90m"
purplecolour="\e[1;35m"

# ctrl+c

function ctrl_c(){
echo -e "\n\n${redcolour}[!]${endcolour} ${yellowcolour}Saliendo...${endcolour}\n\n"
tput cnorm && exit 1
}
trap ctrl_c INT

# Variables globales 

declare -a ip_bin
declare -a ip_bin2
declare -i bucle=0
ip_bin_com=0
mask_bin_comp=0
network_mask=0
declare -a mask_bin
declare -i count2=0
declare -i count32=0
declare -i count=0
declare -a network_id_bin
declare -i difference
declare -a broadcast_bin

# help menu

if [ "$1" == -h ] || [ "$1" == --help ]; then 
    echo -e "\n\t${redcolour}[+]${endcolour}${greencolour} Este script te proporciona la máscara, networkID, broadcast address en decimal y binario tras proporcionarle una IP con su CIDR${endcolour}"
    echo -e "\t${redcolour}[+]${endcolour}${greencolour} Para usarlo, ejecuta el script sin ningún parámetro. Tras eso, escribe la IP junto a su CIDR de la siguiente manera: \"x.x.x.x/x\" ${endcolour}"
    echo -e "\t${redcolour}[+]${endcolour}${greencolour} Script desarrollado por${endcolour}${redcolour} Jofunpe.${endcolour}${greencolour} más info en ${endcolour}${redcolour}https://jofunpe.com${endcolour}\n"
    exit 0
else
    :
fi

# Script 

echo -en "\n${redcolour}[+] ${endcolour}${greencolour}IP -> ${endcolour}${bluecolour}" && read -a ip_bruta
echo -en "${endcolour}"
while [ "$bucle" -eq 0 ]; do
    if [[ "$ip_bruta" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then

        cidr=$(echo "$ip_bruta" | cut -d '/' -f2)
        ip_bin[0]="$(echo "$ip_bruta" | cut -d '.' -f1)" 2>/dev/null
        ip_bin[1]="$(echo "$ip_bruta" | cut -d '.' -f2)" 2>/dev/null
        ip_bin[2]="$(echo "$ip_bruta" | cut -d '.' -f3)" 2>/dev/null
        ip_bin[3]="$(echo "$ip_bruta" | cut -d '.' -f4 | cut -d '/' -f1)" 2>/dev/null
        if [ "${ip_bin[0]}" -ge 0 ] && [ "${ip_bin[0]}" -le 255 ] &&
           [ "${ip_bin[1]}" -ge 0 ] && [ "${ip_bin[1]}" -le 255 ] &&
           [ "${ip_bin[2]}" -ge 0 ] && [ "${ip_bin[2]}" -le 255 ] &&
           [ "${ip_bin[3]}" -ge 0 ] && [ "${ip_bin[3]}" -le 255 ] &&
           [ "$cidr" -ge 1 ] && [ "$cidr" -le 32 ]; then
#              echo "ewwefwef"
              let bucle+=1
        else 
            echo -en "\n${redcolour}[!]${endcolour} ${greencolour}La IP no es válida. Inténtelo de nuevo -> ${endcolour}${bluecolour}" && read ip_bruta
            echo -en "${endcolour}"
        fi 
    else 
        echo -en "\n${redcolour}[!]${endcolour} ${greencolour}La IP no es válida. Inténtelo de nuevo -> ${endcolour}${bluecolour}" && read ip_bruta
        echo -en "${endcolour}"
    fi
done 

ip_bin2[0]=$(printf "%08d" "$(echo "obase=2; ${ip_bin[0]}" | bc)")
ip_bin2[1]=$(printf "%08d" "$(echo "obase=2; ${ip_bin[1]}" | bc)")
ip_bin2[2]=$(printf "%08d" "$(echo "obase=2; ${ip_bin[2]}" | bc)")
ip_bin2[3]=$(printf "%08d" "$(echo "obase=2; ${ip_bin[3]}" | bc)")

ip_bin_com=$(echo "${ip_bin2[0]}.${ip_bin2[1]}.${ip_bin2[2]}.${ip_bin2[3]}")

# Mascara de red

cidr_temp=$cidr
until [ "$count32" -eq 32 ]; do
    if [ "$count" -eq 8 ]; then 
        count=0
        let count2+=1
#        sleep 7
    fi
    if [ "$count2" -eq 0 ]; then 
        if [ "$cidr_temp" -gt 0 ]; then 
            mask_bin[0]=$(echo "${mask_bin[0]}1")
            let cidr_temp-=1
        elif [ "$cidr_temp" -eq 0 ]; then 
            mask_bin[0]=$(echo "${mask_bin[0]}0")
        fi
    elif [ "$count2" -eq 1 ]; then
        if [ "$cidr_temp" -gt 0 ]; then 
            mask_bin[1]=$(echo "${mask_bin[1]}1")
            let cidr_temp-=1
        elif [ "$cidr_temp" -eq 0 ]; then  
            mask_bin[1]=$(echo "${mask_bin[1]}0")
        fi
    elif [ "$count2" -eq 2 ]; then
        if [ "$cidr_temp" -gt 0 ]; then 
            mask_bin[2]=$(echo "${mask_bin[2]}1")
            let cidr_temp-=1
        elif [ "$cidr_temp" -eq 0 ]; then  
            mask_bin[2]=$(echo "${mask_bin[2]}0")
        fi
    else 
        if [ "$cidr_temp" -gt 0 ]; then 
            mask_bin[3]=$(echo "${mask_bin[3]}1")
            let cidr_temp-=1
        elif [ "$cidr_temp" -eq 0 ]; then  
            mask_bin[3]=$(echo "${mask_bin[3]}0")
        fi
    fi
    let count32+=1
    let count+=1 
#    sleep 2 
#    echo "$count"
done

mask_bin_com=$(echo "${mask_bin[0]}.${mask_bin[1]}.${mask_bin[2]}.${mask_bin[3]}")

network_mask="$((2#${mask_bin[0]})).$((2#${mask_bin[1]})).$((2#${mask_bin[2]})).$((2#${mask_bin[3]}))"

# echo "$network_mask"
# echo "${mask_bin_com}"
# echo "elementos array mascara ${#mask_bin[@]}"
# echo "La mascara de la red en binario es ${mask_bin[@]}"
# echo "$ip_bin_com"
# echo "${ip_bin2[@]}"
# echo "$ip_bruta"
# echo "$cidr"
# echo "$ip_bin"

# NetworkID 

for i in {0..3}; do
    for i2 in {0..7}; do
        bit_ip=${ip_bin2[$i]:$i2:1}
        bit_mask=${mask_bin[$i]:$i2:1}

        if [ "$bit_ip" -eq 1 ] && [ "$bit_mask" -eq 1 ]; then
            network_id_bin[$i]+="1"
        else 
            network_id_bin[$i]+="0"
        fi
    done 
done 

network_id_bin_com=${network_id_bin[0]}.${network_id_bin[1]}.${network_id_bin[2]}.${network_id_bin[3]}
network_id_com="$((2#${network_id_bin[0]})).$((2#${network_id_bin[1]})).$((2#${network_id_bin[2]})).$((2#${network_id_bin[3]}))"

# Broascast address 

difference=$((32 - cidr))
difference2=$((32 - difference))

for i in {0..3}; do
    for i2 in {0..7}; do
        bit_network_id=${network_id_bin[$i]:$i2:1}
        if [ "$difference2" -ne 0 ]; then 
            let difference2-=1
            broadcast_bin[$i]="${broadcast_bin[$i]}$bit_network_id"
        else
            broadcast_bin[$i]="${broadcast_bin[$i]}1"
        fi
    done
done

broadcast_bin_com=${broadcast_bin[0]}.${broadcast_bin[1]}.${broadcast_bin[2]}.${broadcast_bin[3]}
broadcast_com=$((2#${broadcast_bin[0]})).$((2#${broadcast_bin[1]})).$((2#${broadcast_bin[2]})).$((2#${broadcast_bin[3]}))

# Host totales 
if [ "$cidr" -eq 32 ]; then 
    total_host=0
else 
    total_host=$(( (2 ** (32 - cidr)) - 2 ))
fi

# Prints finales 

echo -e "\n${redcolour}[+] ${endcolour}${greencolour}IP proporcionada: ${endcolour}${bluecolour}$(echo "$ip_bruta" | cut -d '/' -f1)${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}CIDR proporcionado: ${endcolour}${bluecolour}${cidr}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}Máscara de red: ${endcolour}${bluecolour}${network_mask}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}Host totales: ${endcolour}${bluecolour}${total_host}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}networkID (primera IP): ${endcolour}${bluecolour}${network_id_com}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}broadcast address (ultima IP): ${endcolour}${bluecolour}${broadcast_com}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}IP en binario: ${endcolour}${bluecolour}${ip_bin_com}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}Máscara en binario: ${endcolour}${bluecolour}${mask_bin_com}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}NetworkID en binario: ${endcolour}${bluecolour}${network_id_bin_com}${endcolour}"
echo -e "${redcolour}[+] ${endcolour}${greencolour}Broadcast address en binario: ${endcolour}${bluecolour}${broadcast_bin_com}${endcolour}\n"