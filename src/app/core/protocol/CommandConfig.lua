local CommandConfig = {}

local C = import(".CommandDef")
local T = require("app.core.socket.PacketDataType")

CommandConfig = {
    --[[
        客户端包，对于空包体，可以永许不定义协议内容，将默认版本号为1， 包体长度为0
    --]]
    [C.CLI_HEART_BEAT] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "random", type = T.ARRAY, lengthType = T.BYTE,
               fmt = {
                   {name = "value", type = T.INT},
               },
            }
        }
    },
    -- 大厅登录协议
    [C.CLI_HALL_LOGIN] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "token", type = T.STRING},
            {name = "version", type = T.STRING},
            {name = "channel", type = T.STRING},
            {name = "deviceId", type = T.SHORT}
        }
    },
    [C.CLI_SEND_CHAT] = {
        ver = 1,
        fmt = {
            {name = "keyId", type = T.INT},
            {name = "type", type = T.BYTE},
            {name = "srcUid", type = T.INT},
            {name = "destUid", type = T.INT},
            {name = "sentTime", type = T.INT},
            {name = "msg", type = T.STRING},
        }
    },
    [C.CLI_GET_TABLE] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "gameId", type = T.INT},
            {name = "level", type = T.INT},
        }
    },
    [C.CLI_ENTER_ROOM] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "gameId", type = T.INT},
            {name = "tid", type = T.INT},
            {name = "userinfo", type = T.STRING},
        }
    },

    --[[
        服务器包
    --]]
    [C.SVR_HEART_BEAT] = {
        ver = 1,
        fmt = {
            {name = "random", type = T.ARRAY, lengthType = T.BYTE,
               fmt = {
                   {name = "value", type = T.INT},
               },
            }
        }
    },
    [C.SVR_HALL_LOGIN] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.BYTE},
        }
    },
    [C.SVR_PUSH] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "pushType", type = T.INT},
        }
    },
    [C.SVR_SEND_CHAT_RESP] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.BYTE},
            {name = "keyId", type = T.INT, depends = function(ctx) return ctx.ret == 0 end},
            {name = "msgId", type = T.INT, depends = function(ctx) return ctx.ret == 0 end},
            {name = "uid", type = T.INT},
        }
    },
    [C.SVR_FORWARD_CHAT] = {
        ver = 1,
        fmt = {
            {name = "srcUid", type = T.INT},
            {name = "destUid", type = T.INT},
            {name = "time", type = T.INT},
            {name = "msg", type = T.STRING},
        }
    },
    [C.SVR_GET_TABLE] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.INT},
            {name = "tid", type = T.INT},
            {name = "gameId", type = T.INT},
            {name = "level", type = T.INT},
        }
    },
}

return CommandConfig
