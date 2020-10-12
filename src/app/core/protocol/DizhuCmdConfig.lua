local DizhuCmdConfig = {}

local C = import(".CommandDef")
local T = require("app.core.socket.PacketDataType")

DizhuCmdConfig = {
    --[[
        客户端包，对于空包体，可以永许不定义协议内容，将默认版本号为1， 包体长度为0
    --]]
    [C.CLI_ENTER_ROOM] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "gameId", type = T.INT},
            {name = "tid", type = T.INT},
            {name = "userinfo", type = T.STRING},
        }
    },
    [C.CLI_EXIT_ROOM] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "tid", type = T.INT},
        }
    },
    [C.CLI_PLAYER_READY] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
        }
    },


    --[[
        服务器包
    --]]
    [C.SVR_ENTER_ROOM] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.BYTE},
            {name="tid",type=T.INT,depends = function(ctx) return ctx.ret == 0 end},
            {name="level",type=T.INT, depends = function(ctx) return ctx.ret == 0 end},
            {name="state",type=T.INT, depends = function(ctx) return ctx.ret == 0 end},
            {name="smallbet",type=T.INT, depends = function(ctx) return ctx.ret == 0 end},
            {name="dUid",type=T.INT, depends = function(ctx) return ctx.ret == 0 end},
            {name="players", type=T.ARRAY, lengthType=T.BYTE, depends = function(ctx) return ctx.ret == 0 end,
                fmt = {
                    {name="uid", type=T.INT},
                    {name="seatId", type=T.INT},
                    {name="money", type=T.LONG},
                    {name="gold", type=T.LONG},
                    {name="userinfo", type=T.STRING},
                    {name="state",type=T.INT}
                }
            },
        }
    },
    [C.SVR_EXIT_ROOM] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.BYTE},
            {name="money", type=T.LONG, depends = function(ctx) return ctx.ret == 0 end},
            {name="gold", type=T.LONG, depends = function(ctx) return ctx.ret == 0 end},
        }
    },
    [C.SVR_CAST_EXIT_ROOM] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
        }
    },
    [C.SVR_CAST_USER_SIT] = {
        ver = 1,
        fmt = {
            {name="uid", type=T.INT},
            {name="seatId", type=T.INT},
            {name="money", type=T.LONG},
            {name="gold", type=T.LONG},
            {name="userinfo", type=T.STRING},
            {name="state",type=T.INT},
        }
    },
    [C.SVR_PLAYER_READY] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.BYTE},
        }
    },
    [C.SVR_CAST_PLAYER_READY] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
        }
    },
}

return DizhuCmdConfig
