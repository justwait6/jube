local RummyCmdConfig = {}

local C = import(".CommandDef")
local T = require("app.core.socket.PacketDataType")

RummyCmdConfig = {
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
    [C.CLI_EXIT_ROOM] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "tid", type = T.INT},
        }
    },
    [C.CLI_RUMMY_DRAW_CARD] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "region", type = T.BYTE},
        }
    },
    [C.CLI_RUMMY_DISCARD_CARD] = {
        ver = 1,
        fmt = {
            {name="uid", type=T.INT},
            {name="card", type=T.BYTE},
            {name="index", type=T.INT},
        }
    },
    [C.CLI_RUMMY_UPLOAD_GROUPS] = {
        ver = 1,
        fmt = {
            {name="uid", type=T.INT},
            {name="groups", type=T.ARRAY, lengthType=T.BYTE,
                fmt = {
                    {name="cards", type=T.ARRAY, lengthType=T.BYTE,
                        fmt = {
                            {name="card", type=T.BYTE},
                        }
                    }
                }
            },
            {name="drawCardPos", type=T.INT},
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
            {name="groups", type=T.ARRAY, lengthType=T.BYTE,depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end,
                fmt = {
                    {name="cards", type=T.ARRAY, lengthType=T.BYTE,
                        fmt = {
                            {name="card", type=T.BYTE},
                        }
                    }
                }
            },
            {name="drawCardPos", type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="dropCard", type=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="magicCard", type=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="heapCardNum", type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="operUid", type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="leftOperSec", type=T.INT, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
            {name="users", type=T.ARRAY, lengthType=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end,
                fmt = {
                    {name="uid", type=T.INT},
                    {name="operStatus", type=T.BYTE},
                    {name="isDrop", type=T.BYTE},
                    {name="isNeedDeclare", type=T.BYTE},
                    {name="isFinishDeclare", type=T.BYTE},
                    {name="groups", type=T.ARRAY, lengthType=T.BYTE,depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end,
                        fmt = {
                            {name="cards", type=T.ARRAY, lengthType=T.BYTE,
                                fmt = {
                                    {name="card", type=T.BYTE},
                                }
                            }
                        }
                    }
                }
            },
            {name="finishCard", type=T.BYTE, depends = function(ctx) return ctx.ret == 0 and (ctx.state == 1) end},
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
    [C.SVR_RUMMY_COUNTDOWN] = {
        ver = 1,
        fmt = {
            {name="leftSec", type=T.BYTE},
        }
    },
    [C.SVR_RUMMY_GAME_START] = {
        ver = 1,
        fmt = {
            {name="state", type=T.INT},
            {name="dUid", type=T.INT},
            {name="smallbet", type=T.INT},
            {name="players", type=T.ARRAY, lengthType=T.BYTE,
                fmt = {
                    {name="uid", type=T.INT},
                    {name="money", type=T.LONG},
                    {name="card", type=T.BYTE},
                    {name="minusPoint", type=T.INT},
                    {name="minusMoney", type=T.LONG},
                }
            },
        }
    },
    [C.SVR_RUMMY_USER_TURN] = {
        ver = 1,
        fmt = {
            {name="uid", type=T.INT},
            {name="time", type=T.INT},
        }
    },    
    [C.SVR_RUMMY_DEAL_CARDS] = {
        ver = 1,
        fmt = {
            {name="magicCard", type=T.BYTE},
            {name="dropCard", type=T.BYTE},
            {name="heapCardNum", type=T.INT},
            {name="cards",type=T.ARRAY,lengthType=T.BYTE,
                    fmt = {
                            {name="card",type=T.BYTE},
                    },
            },
        }
    },
    [C.SVR_RUMMY_DRAW_CARD] = {
        ver = 1,
        fmt = {
            {name="ret", type=T.BYTE},
            {name="region", type=T.BYTE,depends = function(ctx) return ctx.ret == 0 end},
            {name="dropCard", type=T.BYTE,depends = function(ctx) return ctx.ret == 0 end},
            {name="card", type=T.BYTE,depends = function(ctx) return ctx.ret == 0 end},
            {name="heapCardNum", type=T.INT,depends = function(ctx) return ctx.ret == 0 end}
        }
    },
    [C.SVR_CAST_RUMMY_DRAW_CARD] = {
        ver = 1,
        fmt = {
            {name="uid", type=T.INT},
            {name="region", type=T.BYTE},
            {name="dropCard", type=T.BYTE},
            {name="heapCardNum", type=T.INT}
        }
    },
    [C.SVR_RUMMY_DISCARD_CARD] = {
        ver = 1,
        fmt = {
            {name="ret", type=T.BYTE},
            {name="dropCard", type=T.BYTE, depends = function(ctx) return ctx.ret == 0 end},
            {name="index", type=T.INT, depends = function(ctx) return ctx.ret == 0 end},
        }
    },
    [C.SVR_CAST_RUMMY_DISCARD] = {
        ver = 1,
        fmt = {
            {name="uid", type=T.INT},
            {name="dropCard", type=T.BYTE},
        }
    },
    [C.SVR_RUMMY_UPLOAD_GROUPS] = {
        ver = 1,
        fmt = {
            {name="ret", type=T.BYTE},
        }
    },
}

return RummyCmdConfig
