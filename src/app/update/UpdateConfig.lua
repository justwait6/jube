-- Author: Jam
-- Date: 2016.08.20
local UpdateConfig = {}
UpdateConfig.UpdateBasePath = device.writablePath .. "upd" .. device.directorySeparator
-- 保存在本地的版本文件名称
UpdateConfig.UPDATE_LIST_FILE_NAME = "ResList"
UpdateConfig.UPDATE_LIST_FILE_NAME_TEMP = "ResListTemp"

-- 大厅更新
UpdateConfig.UpdatePath = UpdateConfig.UpdateBasePath .. "hall" .. device.directorySeparator
UpdateConfig.Lobby_List_file = UpdateConfig.UpdatePath .. UpdateConfig.UPDATE_LIST_FILE_NAME
UpdateConfig.UpdatePath_RES = UpdateConfig.UpdatePath .. "res" .. device.directorySeparator
UpdateConfig.UpdatePath_RES_TMP = UpdateConfig.UpdatePath .. "restmp" .. device.directorySeparator

-- 游戏更新
UpdateConfig.GamePath = UpdateConfig.UpdateBasePath .. "%s" .. device.directorySeparator
UpdateConfig.GamePath_RES = UpdateConfig.UpdateBasePath .. "%s" .. device.directorySeparator .. "res" .. device.directorySeparator
UpdateConfig.GamePath_RES_TMP = UpdateConfig.UpdateBasePath .. "%s" .. device.directorySeparator .. "restmp" .. device.directorySeparator

UpdateConfig.Game_List_File = UpdateConfig.UpdateBasePath .. "%s" .. device.directorySeparator .. UpdateConfig.UPDATE_LIST_FILE_NAME

UpdateConfig.GAME_SERVER = "http://www.nfanr.com/update/%s/"

if LANG == LANG_TH then
    UpdateConfig.m_configs = {
        [600] = {gameId = 600, needDownload = false, game = device.writablePath .. "src/app/module/diceroom", version = "app.module.diceroom.version", name="ไฮโล"},
        [200] = {gameId = 200, needDownload = false, game = device.writablePath .. "src/app/module/yxxroom", version = "app.module.yxxroom.version", name="น้ำเต้า ปู ปลา"},    
        [300] = {gameId = 300, needDownload = false, game = device.writablePath .. "src/app/module/pokdengroom", version = "app.module.pokdengroom.version", name="ป๊อกเด้ง"},
    	[400] = {gameId = 400, needDownload = false, game = device.writablePath .. "src/app/module/texasroom", version = "app.module.texasroom.version", name="ไพ่เท็กซัส"},
    	[500] = {gameId = 500, needDownload = false, game = device.writablePath .. "src/app/module/dummyroom", version = "app.module.dummyroom.version", name="ดัมมี่"},
    	[700] = {gameId = 700, needDownload = false, game = device.writablePath .. "src/app/module/gaple", version = "app.module.gaple.version", name="domino"},
    	[800] = {gameId = 800, needDownload = false, game = device.writablePath .. "src/app/module/qiuqiuroom", version = "app.module.qiuqiuroom.version", name="qiuqiu"},
        [1000] = {gameId = 1000, needDownload = false, game = device.writablePath .. "src/app/module/sangongroom", version = "app.module.sangongroom.version", name="sangong"},
        [10000] = {gameId = 10000, needDownload = false, game = device.writablePath .. "", version = 1, name="gold"},
        [900] = {gameId = 900, needDownload = false, game = device.writablePath .. "src/app/module/king", version = "app.module.king.version", name="king"},
    }
    UpdateConfig.gold_lobby_configs = {
        {gameId = 10300,name="ป๊อกเด้ง",open = true},
        {gameId = 10500,name="ดัมมี่",open = true},
        {gameId = 11000,name="เก้าเก",open = true},
    }
elseif LANG == LANG_ID then
    UpdateConfig.m_configs = {
        [600] = {gameId = 600, needDownload = false, game = device.writablePath .. "src/app/module/diceroom", version = "app.module.diceroom.version", name="ไฮโล"},
        [200] = {gameId = 200, needDownload = false, game = device.writablePath .. "src/app/module/yxxroom", version = "app.module.yxxroom.version", name="น้ำเต้า ปู ปลา"},    
    	[300] = {gameId = 300, needDownload = false, game = device.writablePath .. "src/app/module/pokdengroom", version = "app.module.pokdengroom.version", name="ป๊อกเด้ง"},
        [400] = {gameId = 400, needDownload = false, game = device.writablePath .. "src/app/module/texasroom", version = "app.module.texasroom.version", name="ไพ่เท็กซัส"},
    	[700] = {gameId = 700, needDownload = false, game = device.writablePath .. "src/app/module/gaple", version = "app.module.gaple.version", name="domino"},
    	[800] = {gameId = 800, needDownload = false, game = device.writablePath .. "src/app/module/qiuqiuroom", version = "app.module.qiuqiuroom.version", name="qiuqiu"},
        [10000] = {gameId = 10000, needDownload = false, game = device.writablePath .. "", version = 1, name="gold"},
    }
    UpdateConfig.gold_lobby_configs = {
        {gameId = 10800,name="QiuQiu",open=true},
        {gameId = 10400,name="Texas Poker",open=true},
        {gameId = 10600,name="Sic Bo",open=false},
    }
elseif LANG == LANG_EN then
	UpdateConfig.m_configs = {
        [600] = {gameId = 600, needDownload = false, game = device.writablePath .. "src/app/module/diceroom", version = "app.module.diceroom.version", name="ไฮโล"},
        [200] = {gameId = 200, needDownload = false, game = device.writablePath .. "src/app/module/yxxroom", version = "app.module.yxxroom.version", name="น้ำเต้า ปู ปลา"},    
    	[400] = {gameId = 400, needDownload = false, game = device.writablePath .. "src/app/module/texasroom", version = "app.module.texasroom.version", name="ไพ่เท็กซัส"},
    	[700] = {gameId = 700, needDownload = false, game = device.writablePath .. "src/app/module/gaple", version = "app.module.gaple.version", name="domino"},
    	[800] = {gameId = 800, needDownload = false, game = device.writablePath .. "src/app/module/qiuqiuroom", version = "app.module.qiuqiuroom.version", name="qiuqiu"},
    }
else
     UpdateConfig.m_configs = {
        [600] = {gameId = 600, needDownload = false, game = device.writablePath .. "src/app/module/diceroom", version = "app.module.diceroom.version", name="ไฮโล"},
        [200] = {gameId = 200, needDownload = false, game = device.writablePath .. "src/app/module/yxxroom", version = "app.module.yxxroom.version", name="น้ำเต้า ปู ปลา"},    
        [300] = {gameId = 300, needDownload = false, game = device.writablePath .. "src/app/module/pokdengroom", version = "app.module.pokdengroom.version", name="ป๊อกเด้ง"},
    	[400] = {gameId = 400, needDownload = false, game = device.writablePath .. "src/app/module/texasroom", version = "app.module.texasroom.version", name="ไพ่เท็กซัส"},
    	[500] = {gameId = 500, needDownload = false, game = device.writablePath .. "src/app/module/dummyroom", version = "app.module.dummyroom.version", name="ดัมมี่"},
    	[700] = {gameId = 700, needDownload = false, game = device.writablePath .. "src/app/module/gaple", version = "app.module.gaple.version", name="domino"},
    	[800] = {gameId = 800, needDownload = false, game = device.writablePath .. "src/app/module/qiuqiuroom", version = "app.module.qiuqiuroom.version", name="qiuqiu"},
        [10000] = {gameId = 10000, needDownload = false, game = device.writablePath .. "", version = 1, name="gold"},
    }
end


return UpdateConfig