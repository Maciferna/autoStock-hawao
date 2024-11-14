$rojo = "`e[1;31m"
$verde = "`e[1;32m"
$amarillo = "`e[1;33m"
$reset = "`e[0m"

Write-Host "${verde}Comenzando con las verificaciones básicas...${reset}"
Start-Sleep -Seconds 2

function Check-Eje {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${rojo}Hubo un error con el último comando${reset}"
        exit 1
    }
}

function Check-Bin {
    param ($bin)
    if (-not (Get-Command $bin -ErrorAction SilentlyContinue)) {
        Write-Host "${amarillo}Instale ${rojo}'$bin' ${amarillo}y vuelva a intentar${reset}"
        exit 1
    } else {
        Write-Host "${verde}'$bin' ${amarillo}se encuentra en el sistema${reset}"
    }
}

Check-Bin "adb"
Check-Bin "fastboot"

Write-Host "`n"
Write-Host "${amarillo}Buscando dispositivos con depuracion USB${reset}"
Start-Sleep -Seconds 2
Write-Host "`n"

if (-not (adb devices | Select-String -Pattern 'device')) {
    Write-Host "${rojo}No se detecta ningún dispositivo con depuración USB activada o no está autorizado${reset}"
    exit 1
} else {
    Write-Host "${verde}Dispositivo detectado y autorizado${reset}"
}

Write-Host "`n"
Write-Host "${amarillo}Descargando la ROM de stock para Argentina${reset}"

Check-Bin "wget"
Check-Bin "Expand-Archive"

Write-Host "`n"
Start-Sleep -Seconds 2

Invoke-WebRequest -Uri "https://mirrors.lolinet.com/firmware/lenomola/2022/hawao/official/RETAR/XT2233-1_HAWAO_OPENLA_13_T2SES33.73-23-2-11_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip" -OutFile "rom.zip"

Write-Host "${rojo}Descomprimiendo...${reset}"
Start-Sleep -Seconds 2

$stockPath = Join-Path -Path (Get-Location) -ChildPath "stock"
New-Item -ItemType Directory -Path $stockPath | Out-Null
Expand-Archive -Path "rom.zip" -DestinationPath $stockPath -Force

Write-Host "`n`n"
Write-Host "${amarillo}Reiniciando el celular en modo bootloader...${reset}"
adb reboot bootloader

Start-Sleep -Seconds 10

$status = Read-Host -Prompt "${rojo}Escriba una 'y' cuando el celular ya se encuentre en el bootloader, si no lo está espere: ${reset}"

if ($status -eq 'y') {
    fastboot getvar max-sparse-size
    fastboot oem fb_mode_set
    fastboot flash partition "$stockPath\gpt.bin"
    fastboot flash bootloader "$stockPath\bootloader.img"
    fastboot flash vbmeta "$stockPath\vbmeta.img"
    fastboot flash vbmeta_system "$stockPath\vbmeta_system.img"
    fastboot reboot bootloader
    fastboot flash radio "$stockPath\radio.img"
    fastboot flash bluetooth "$stockPath\BTFM.bin"
    fastboot flash dsp "$stockPath\dspso.bin"
    fastboot flash spunvm "$stockPath\spunvm.bin"
    fastboot flash logo "$stockPath\logo.bin"
    fastboot flash boot "$stockPath\boot.img"
    fastboot flash vendor_boot "$stockPath\vendor_boot.img"
    fastboot flash dtbo "$stockPath\dtbo.img"
    
    for ($i = 0; $i -le 13; $i++) {
        fastboot flash super "$stockPath\super.img_sparsechunk.$i"
    }

    fastboot reboot bootloader
    fastboot erase carrier
    fastboot erase userdata
    fastboot erase metadata
    fastboot erase ddr
    fastboot oem fb_mode_clear
    fastboot reboot
} else {
    Write-Host "${rojo}Saliendo...${reset}"
    exit 1
}

Write-Host "${verde}Sistema listo${reset}"
exit 0
