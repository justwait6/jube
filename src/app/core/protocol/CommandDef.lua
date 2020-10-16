local CommandDef = {}
local C = CommandDef

--[[
RULE:
Client始终发[偶数协议号], Server单播返回发[Client协议号 + 1]
单播协议[0x0XXX]格式, 广播协议[0x1XXX]格式
0x02XX, 单播, 大厅(房间外逻辑)
0x03XX, 单播, 房间, 功能逻辑(聊天, 表情, 打赏)
0x04XX, 单播, 房间, 玩法逻辑

0x04XX, 广播, 房间, 玩法逻辑
--]]

-- CLIENT
C.CLI_HEART_BEAT                        = 0x0200 -- Common心跳
C.CLI_HALL_LOGIN                        = 0x0202 -- Common登录大厅
C.CLI_SEND_CHAT                         = 0x0300 -- Common发送聊天
C.CLI_FORWARD_CHAT                      = 0x0302 -- Common转发聊天(占位, 未使用)
C.CLI_GET_TABLE                         = 0x0400 -- Common获取桌子信息
C.CLI_ENTER_ROOM                        = 0x0402 -- Common登录房间
C.CLI_EXIT_ROOM                         = 0x0404 -- Common主动请求退出房间
C.CLI_REQ_SIT                           = 0x0406 -- Common主动请求坐下
C.CLI_REQ_SWITCH_TABLE                  = 0x0408 -- Common主动请求换桌
C.CLI_REQ_STAND                         = 0x040A -- Common主动请求站起

-- SERVER
C.SVR_HEART_BEAT                        = 0x0201 -- Common心跳返回
C.SVR_HALL_LOGIN                        = 0x0203 -- Common登录大厅
C.SVR_PUSH                              = 0x0205 -- Common服务器自定义推送
C.SVR_SEND_CHAT_RESP                    = 0x0301 -- Common聊天返回
C.SVR_FORWARD_CHAT                      = 0x0303 -- Common转发聊天
C.SVR_GET_TABLE                         = 0x0401 -- Common返回桌子信息
C.SVR_ENTER_ROOM                        = 0x0403 -- Common返回登录房间信息
C.SVR_EXIT_ROOM                         = 0x0405 -- Common返回退出房间信息
C.SVR_CAST_EXIT_ROOM                    = 0x1405 -- Common广播玩家退出
C.SVR_REQ_SIT                           = 0x0407 -- Common返回请求坐下信息
C.SVR_CAST_USER_SIT                     = 0x1407 -- Common广播玩家坐下
C.SVR_REQ_SWITCH_TABLE                  = 0x0409 -- Common请求换桌返回
C.SVR_REQ_STAND                         = 0x040B -- Common请求站起返回

--[[ Rummy Client Protocol Begin --]]
C.CLI_RUMMY_DRAW_CARD                   = 0x040C -- Rummy请求摸牌
C.CLI_RUMMY_DISCARD_CARD                = 0x040E -- Rummy请求出牌
C.CLI_RUMMY_FINISH                      = 0x0410 -- Rummy请求Finish
C.CLI_RUMMY_DECLARE                     = 0x0412 -- Rummy请求Declare
C.CLI_RUMMY_DROP                        = 0x0414 -- Rummy请求弃整副牌
C.CLI_RUMMY_UPLOAD_GROUPS               = 0x0416 -- Rummy请求上报牌
C.CLI_RUMMY_GET_DROP_CARDS              = 0x0418 -- Rummy获取drop牌列表
C.CLI_RUMMY_USER_BACK                   = 0x041A -- Rummy玩家通报"I am back"                      
--[[ Rummy Client Protocol End --]]


--[[ Rummy Server Protocol Begin --]]
C.SVR_RUMMY_COUNTDOWN                   = 0x14A1 -- Rummy广播游戏开始倒计时
C.SVR_RUMMY_GAME_START                  = 0x14A2 -- Rummy广播游戏开始
C.SVR_RUMMY_USER_TURN                   = 0x14A3 -- Rummy广播轮到玩家
C.SVR_CAST_RUMMY_RESUFFLE               = 0x14A4 -- Rummy广播重新洗牌
C.SVR_RUMMY_BONUS_TIME                  = 0x14A5 -- Rummy广播玩家bonus time
C.SVR_RUMMY_USER_MISS_TURNS             = 0x14A6 -- Rummy广播玩家超时次数
C.SVR_RUMMY_GAME_END_SCORE              = 0x14A7 -- Rummy广播游戏结算(会多次广播)
C.SVR_RUMMY_DEAL_CARDS                  = 0x0434 -- Rummy游戏发牌
C.SVR_RUMMY_DRAW_CARD                   = 0x040D -- Rummy请求摸牌返回
C.SVR_CAST_RUMMY_DRAW_CARD              = 0x140D -- Rummy广播玩家摸牌
C.SVR_RUMMY_DISCARD_CARD                = 0x040F -- Rummy请求出牌返回
C.SVR_CAST_RUMMY_DISCARD                = 0x140F -- Rummy广播玩家出牌
C.SVR_RUMMY_FINISH                      = 0x0411 -- Rummy请求Finish返回
C.SVR_CAST_RUMMY_FINISH                 = 0x1411 -- Rummy广播玩家Finish
C.SVR_RUMMY_DECLARE                     = 0x0413 -- Rummy请求Declare返回
C.SVR_CAST_RUMMY_DECLARE                = 0x1413 -- Rummy广播玩家Declare结果(成功后, 有其他玩家declare组牌时间信息)
C.SVR_RUMMY_DROP                        = 0x0415 -- Rummy请求弃整副牌返回
C.SVR_CAST_RUMMY_DROP                   = 0x1415 -- Rummy广播玩家弃整副牌
C.SVR_RUMMY_UPLOAD_GROUPS               = 0x0417 -- Rummy请求上报牌返回
C.SVR_RUMMY_GET_DROP_CARDS              = 0x0419 -- Rummy获取drop牌列表返回
C.SVR_RUMMY_USER_BACK                   = 0x041B -- Rummy通报"I am back"返回
--[[ Rummy Server Protocol End --]]

--[[ Dizhu Client Protocol Begin --]]
C.CLI_DIZHU_READY                      = 0x040C -- Dizhu请求准备
C.CLI_DIZHU_GRAB                       = 0x040E -- Dizhu请求Grab
C.CLI_DIZHU_OUT_CARD                   = 0x0410 -- Dizhu请求出牌
--[[ Dizhu Client Protocol End --]]

--[[ Dizhu Server Protocol Begin --]]
C.SVR_DIZHU_GAME_START                 = 0x14A1 -- Dizhu广播游戏开始
C.SVR_DIZHU_GRAB_TURN                  = 0x14A2 -- Dizhu广播轮到抢庄
C.SVR_DIZHU_GRAB_RESULT                = 0x14A3 -- Dizhu广播抢庄结果
C.SVR_DIZHU_TURN                       = 0x14A4 -- Dizhu广播轮到玩家
C.SVR_DIZHU_READY                      = 0x040D -- Dizhu返回用户准备
C.SVR_CAST_DIZHU_READY                 = 0x140D -- Dizhu广播用户准备
C.SVR_DIZHU_GRAB                       = 0x040F -- Dizhu返回请求Grab
C.SVR_CAST_DIZHU_GRAB                  = 0x140F -- Dizhu广播Grab
C.SVR_DIZHU_OUT_CARD                   = 0x0411 -- Dizhu返回用户出牌
C.SVR_CAST_DIZHU_OUT_CARD              = 0x1411 -- Dizhu广播用户出牌
--[[ Dizhu Server Protocol End --]]

return CommandDef
