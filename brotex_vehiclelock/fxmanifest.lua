fx_version 'adamant'
game 'gta5'

description 'Vehicle Lock'

shared_script '@es_extended/imports.lua'

server_script {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended'
}
