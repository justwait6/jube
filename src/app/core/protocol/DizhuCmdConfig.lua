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
    [C.CLI_DIZHU_READY] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
        }
    },
    [C.CLI_DIZHU_GRAB] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "isGrab", type = T.BYTE},
        }
    },
    [C.CLI_DIZHU_OUT_CARD] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "isOut", type = T.BYTE},
            {name = "cardType", type = T.BYTE, depends = function(ctx) return ctx.isOut == 1 end},
            {name="cards",type=T.ARRAY,lengthType=T.BYTE, depends = function(ctx) return ctx.isOut == 1 end,
                    fmt = {
                            {name="card",type=T.BYTE},
                    },
            },
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
            {name="dUid",type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="cards", type=T.ARRAY, lengthType=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end,
                    fmt = {
                            {name="card",type=T.BYTE},
                    },
            },
            {name="detailState",type=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end },
            {name="operUid", type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="leftOperSec", type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="odds",type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="isNewRound",type=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.detailState == 1) end },
            {name="bottomCards", type=T.ARRAY, lengthType=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.detailState == 1) end,
                fmt = {
                        {name="card",type=T.BYTE},
                },
            },
            {name="latestOutCards", type=T.ARRAY, lengthType=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.detailState == 1) and (ctx.isNewRound == 0) end,
                fmt = {
                        {name="card",type=T.BYTE},
                },
            },
            {name="users", type=T.ARRAY, lengthType=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end, 
                fmt = {
                    {name="uid", type=T.INT},
                    {name="grabState", type=T.BYTE},
                    {name="outCardState", type=T.BYTE},
                    {name="cardsNum", type=T.INT},
                    {name="outCards", type=T.ARRAY, lengthType=T.BYTE,
                        fmt = {
                                {name="card",type=T.BYTE},
                        },
                    },
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
    [C.SVR_DIZHU_READY] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.BYTE},
        }
    },
    [C.SVR_CAST_DIZHU_READY] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
        }
    },
    [C.SVR_DIZHU_GAME_START] = {
        ver = 1,
        fmt = {
            {name="cards",type=T.ARRAY,lengthType=T.BYTE,
                    fmt = {
                            {name="card",type=T.BYTE},
                    },
            },
        }
    },
    [C.SVR_DIZHU_GRAB_TURN] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
            {name="odds",type=T.INT},
            {name="time",type=T.INT},
        }
    },
    [C.SVR_DIZHU_TURN] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
            {name="isNewRound",type=T.BYTE},
            {name="time",type=T.INT},
        }
    },
    [C.SVR_DIZHU_GRAB_RESULT] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
            {name="odds",type=T.INT},
            {name="cards",type=T.ARRAY,lengthType=T.BYTE,
                    fmt = {
                            {name="card",type=T.BYTE},
                    },
            },
        }
    },
    [C.SVR_DIZHU_GRAB] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.BYTE},
            {name = "isGrab", type = T.BYTE, depends = function(ctx) return ctx.ret == 0 end},
            {name = "odds", type = T.INT, depends = function(ctx) return ctx.ret == 0 end},
        }
    },
    [C.SVR_CAST_DIZHU_GRAB] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "isGrab", type = T.BYTE},
            {name = "odds", type = T.INT},
        }
    },
    [C.SVR_DIZHU_OUT_CARD] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.BYTE},
            {name = "isOut", type = T.BYTE, depends = function(ctx) return ctx.ret == 0 end},
        }
    },
    [C.SVR_CAST_DIZHU_OUT_CARD] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "isOut", type = T.BYTE},
            {name = "cardType", type = T.BYTE, depends = function(ctx) return ctx.isOut == 1 end},
            {name="cards",type=T.ARRAY,lengthType=T.BYTE, depends = function(ctx) return ctx.isOut == 1 end,
                    fmt = {
                            {name="card",type=T.BYTE},
                    },
            },
        }
    },
}

return DizhuCmdConfig
