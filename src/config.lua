
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

ENABLE_HEART_BEATS_LOG = false

-- Language Options: CH, EN,
LANG = require("app.language.LangDef").EN

LOAD_DEPRECATED_API = false

LOAD_SHORTCODES_API = true

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- design resolution
CONFIG_SCREEN_WIDTH  = 1280
CONFIG_SCREEN_HEIGHT = 720

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
--是否为长屏手机 中文注释写在上一行 只针对这个文件
CONFIG_ISLARGE_WIDTH = false 
local glView = cc.Director:getInstance():getOpenGLView()
local size = glView:getFrameSize()
local w = size.width
local h = size.height
if w/h > CONFIG_SCREEN_WIDTH/CONFIG_SCREEN_HEIGHT then
	CONFIG_ISLARGE_WIDTH = true
end