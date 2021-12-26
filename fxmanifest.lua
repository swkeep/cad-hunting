fx_version 'bodacious'
games { 'gta5' }

author "Cadburry#7547"

client_script 'client/cl_main.lua'
shared_script "@qb-core/shared.lua"
shared_script 'config.lua'
server_script 'server/sv_main.lua'

-- server_script 'server/md5.lua'

-- server_exports {
-- 	'md5new',
-- 	'md5tohex',
-- 	'md5sum',
-- 	'md5sumhexa'
-- }