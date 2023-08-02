fx_version 'cerulean'

game 'gta5'

author 'Linden - KASH - REWORK(Javi)'

lua54 'yes'

dependencies {
    'es_extended',
    'esx_identity',
    'esx_skin'
}

shared_scripts {'@es_extended/imports.lua', '@es_extended/locale.lua', 'locales/*.lua', 'config.lua'}

server_scripts {'@oxmysql/lib/MySQL.lua', 'server/*.lua'}

client_scripts {'client/*.lua'}

ui_page {'html/ui.html'}

files {
    'html/**/**/*.*'
}
