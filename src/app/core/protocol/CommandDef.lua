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
C.CLI_HEART_BEAT                        = 0x0200 -- 心跳
C.CLI_HALL_LOGIN                        = 0x0202 -- 登录大厅
C.CLI_SEND_CHAT                         = 0x0300 -- 发送聊天
C.CLI_FORWARD_CHAT                      = 0x0302 -- 转发聊天(占位, 未使用)
C.CLI_GET_TABLE                         = 0x0400 -- 获取桌子信息
C.CLI_ENTER_ROOM                        = 0x0402 -- 登录房间
C.CLI_EXIT_ROOM                         = 0x0404 -- 主动请求退出房间
C.CLI_REQ_SIT                           = 0x0406 -- 主动请求坐下
C.CLI_REQ_SWITCH_TABLE                  = 0x0408 -- 主动请求换桌
C.CLI_REQ_STAND                         = 0x040A -- 主动请求站起
C.CLI_RUMMY_DRAW_CARD                   = 0x040C -- Rummy请求摸牌
C.CLI_RUMMY_DISCARD_CARD                = 0x040E -- Rummy请求出牌
C.CLI_RUMMY_FINISH                      = 0x0410 -- Rummy请求Finish
C.CLI_RUMMY_DECLARE                     = 0x0412 -- Rummy请求Declare
C.CLI_RUMMY_DROP                        = 0x0414 -- Rummy请求弃整副牌
C.CLI_RUMMY_UPLOAD_GROUPS               = 0x0416 -- Rummy请求上报牌
C.CLI_RUMMY_GET_DROP_CARDS              = 0x0418 -- Rummy获取drop牌列表
C.CLI_RUMMY_USER_BACK                   = 0x041A -- Rummy玩家通报"I am back"                      

-- SERVER
C.SVR_HEART_BEAT                        = 0x0201 -- 心跳返回
C.SVR_PUSH                              = 0x0205 -- 服务器自定义推送
C.SVR_SEND_CHAT_RESP                    = 0x0301 -- 聊天返回
C.SVR_FORWARD_CHAT                      = 0x0303 -- 转发聊天
C.SVR_GET_TABLE                         = 0x0401 -- 返回桌子信息
C.SVR_ENTER_ROOM                        = 0x0403 -- 返回登录房间信息
C.SVR_EXIT_ROOM                         = 0x0405 -- 返回退出房间信息
C.SVR_CAST_EXIT_ROOM                    = 0x1405 -- 广播玩家退出
C.SVR_REQ_SIT                           = 0x0407 -- 返回请求坐下信息
C.SVR_CAST_USER_SIT                     = 0x1407 -- 广播玩家坐下
C.SVR_REQ_SWITCH_TABLE                  = 0x0409 -- 请求换桌返回
C.SVR_REQ_STAND                         = 0x040B -- 请求站起返回
C.SVR_RUMMY_COUNTDOWN                   = 0x14A1 -- 广播游戏开始倒计时
C.SVR_RUMMY_GAME_START                  = 0x14A2 -- 广播游戏开始
C.SVR_RUMMY_USER_TURN                   = 0x14A3 -- 广播轮到玩家
C.SVR_CAST_RUMMY_RESUFFLE               = 0x14A4 -- 广播重新洗牌
C.SVR_RUMMY_BONUS_TIME                  = 0x14A5 -- 广播玩家bonus time
C.SVR_RUMMY_USER_MISS_TURNS             = 0x14A6 -- 广播玩家超时次数
C.SVR_RUMMY_DEAL_CARDS                  = 0x0434 -- 游戏发牌
C.SVR_RUMMY_DRAW_CARD                   = 0x040D -- 请求摸牌返回
C.SVR_CAST_RUMMY_DRAW_CARD              = 0x140D -- 广播玩家摸牌
C.SVR_RUMMY_DISCARD_CARD                = 0x040F -- 请求出牌返回
C.SVR_CAST_RUMMY_DISCARD                = 0x140F -- 广播玩家出牌
C.SVR_RUMMY_FINISH                      = 0x0411 -- 请求Finish返回
C.SVR_CAST_RUMMY_FINISH                 = 0x1411 -- 广播玩家Finish
C.SVR_RUMMY_DECLARE                     = 0x0413 -- 请求Declare返回
C.SVR_CAST_RUMMY_DECLARE                = 0x1413 -- Rummy广播玩家Declare结果(成功后, 有其他玩家declare组牌时间信息)
C.SVR_RUMMY_DROP                        = 0x0415 -- 请求弃整副牌返回
C.SVR_CAST_RUMMY_DROP                   = 0x1415 -- 广播玩家弃整副牌
C.SVR_RUMMY_UPLOAD_GROUPS               = 0x0417 -- 请求上报牌返回
C.SVR_RUMMY_GET_DROP_CARDS              = 0x0419 -- 获取drop牌列表返回
C.SVR_RUMMY_USER_BACK                   = 0x041B -- 通报"I am back"返回

return CommandDef
