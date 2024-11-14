#!/bin/bash

rojo='\e[1;31m'
verde='\e[1;32m'
amarillo='\e[1;33m'
reset='\e[0m'

echo -e "${verde}Comenzando con las verificaciones básicas...${reset}"
sleep 2


check_eje(){
  if [ "$?" != '0' ]; then
    echo -e "${rojo}Hubo un error con el último comando${reset}"
    exit 1
  fi
}


check_bin(){
  if ! command -v $1 > /dev/null 2>&1; then
    echo -e "${amarillo}Instale ${rojo}'$1' ${amarillo}y vuelva a intentar${reset}"
    exit 1
  else
    echo -e "${verde}'$1' ${amarillo}se encuentra en el sistema${reset}"
  fi
}
check_bin adb
check_bin fastboot

echo -e "\n"
echo -e "${amarillo}Buscando dispositivos con depuracion USB${reset}"
sleep 2
echo -e "\n"

if [ -z "$(adb devices | grep -w 'device')" ]; then
  echo -e "${rojo}No se detecta ningún dispositivo con depuración USB activada o no está autorizado${reset}"
  exit 1
else
  echo -e "${verde}Dispositivo detectado y autorizado${reset}"
fi

if [ "$(ls . | grep 'rom.zip')" == "rom.zip" ]; then
  echo -e "\n"
  echo -e "${amarillo}La rom se encuentra en el directorio actual..."
  echo -e "${rojo}Descomprimiendo...${reset}"
  sleep 2
  mkdir -p stock
  unzip rom.zip -d stock > /dev/null 2>&1
elif [ "$(ls . | grep 'HAWAO')" == 'XT2233-1_HAWAO_OPENLA_13_T2SES33.73-23-2-11_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip' ]; then
  echo -e "\n"
  echo -e "${amarillo}La rom se encuentra en el directorio actual..."
  echo -e "${rojo}Descomprimiendo...${reset}"
  sleep 2
  mv $(ls | grep "HAWAO") rom.zip
  mkdir -p stock
  unzip rom.zip -d stock > /dev/null 2>&1
else
  echo -e "\n"
  echo -e "${amarillo}Descargando la ROM de stock para Argentina${reset}"
  check_bin wget
  check_bin unzip
  echo -e "\n"
  sleep 2
  wget "https://mirrors.lolinet.com/firmware/lenomola/2022/hawao/official/RETAR/XT2233-1_HAWAO_OPENLA_13_T2SES33.73-23-2-11_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip"
  echo -e "${rojo}Descomprimiendo...${reset}"
  sleep 2
  mv $(ls | grep "HAWAO") rom.zip
  mkdir -p stock
  unzip rom.zip -d stock > /dev/null 2>&1
fi

echo -e "\n\n"
echo -e "${amarillo}Reiniciando el celular en modo bootloader...${reset}"
adb reboot bootloader

sleep 10


echo -ne "${rojo}Escriba una 'y' cuando el celular ya se encuentre en el bootloader, si no lo está espere: ${reset}"
read status

if [ "$status" == 'y' ]; then
  fastboot getvar max-sparse-size
  fastboot oem fb_mode_set
  fastboot flash partition stock/gpt.bin
  fastboot flash bootloader stock/bootloader.img
  fastboot flash vbmeta stock/vbmeta.img
  fastboot flash vbmeta_system stock/vbmeta_system.img
  fastboot reboot bootloader
  sleep 30
  fastboot flash radio stock/radio.img
  fastboot flash bluetooth stock/BTFM.bin
  fastboot flash dsp stock/dspso.bin
  fastboot flash spunvm stock/spunvm.bin
  fastboot flash logo stock/logo.bin
  fastboot flash boot stock/boot.img
  fastboot flash vendor_boot stock/vendor_boot.img
  fastboot flash dtbo stock/dtbo.img
  fastboot flash super stock/super.img_sparsechunk.0
  fastboot flash super stock/super.img_sparsechunk.1
  fastboot flash super stock/super.img_sparsechunk.2
  fastboot flash super stock/super.img_sparsechunk.3
  fastboot flash super stock/super.img_sparsechunk.4
  fastboot flash super stock/super.img_sparsechunk.5
  fastboot flash super stock/super.img_sparsechunk.6
  fastboot flash super stock/super.img_sparsechunk.7
  fastboot flash super stock/super.img_sparsechunk.8
  fastboot flash super stock/super.img_sparsechunk.9
  fastboot flash super stock/super.img_sparsechunk.10
  fastboot flash super stock/super.img_sparsechunk.11
  fastboot flash super stock/super.img_sparsechunk.12
  fastboot flash super stock/super.img_sparsechunk.13
  fastboot reboot bootloader
  sleep 30
  fastboot erase carrier
  fastboot erase userdata
  fastboot erase metadata
  fastboot erase ddr
  fastboot oem fb_mode_clear
  fastboot reboot
else
  echo -e "${rojo}Saliendo...${reset}"
  exit 1
fi


echo -e "${verde}Sistema listo${reset}"
exit 0
