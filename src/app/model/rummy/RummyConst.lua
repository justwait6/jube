local RummyConst = {}

RummyConst.UserNum = 5
RummyConst.MSeatId = 2
RummyConst.NoPlayerSeatId = -10
RummyConst.GirlSeatId = 5
RummyConst.MAX_GROUP_NUM = 6
RummyConst.DRAW_CARD_ID = 14
RummyConst.MAX_SCORE = 80

RummyConst.toSFactor = 0.8

RummyConst.USER_STAND = -1 --玩家站起
RummyConst.USER_SEAT = 0 --玩家坐下
RummyConst.USER_PLAY = 1 -- 正在玩牌
RummyConst.USER_FOLD = 2 --玩家弃牌

RummyConst.isFinalGame = true -- 是否处于游戏结束到下局开始之间
RummyConst.isMeInGames = false

RummyConst.chipNumberPath1 = {}
RummyConst.chipNumberPath1["0"] = "#c_addnum_0.png"
RummyConst.chipNumberPath1["1"] = "#c_addnum_1.png"
RummyConst.chipNumberPath1["2"] = "#c_addnum_2.png"
RummyConst.chipNumberPath1["3"] = "#c_addnum_3.png"
RummyConst.chipNumberPath1["4"] = "#c_addnum_4.png"
RummyConst.chipNumberPath1["5"] = "#c_addnum_5.png"
RummyConst.chipNumberPath1["6"] = "#c_addnum_6.png"
RummyConst.chipNumberPath1["7"] = "#c_addnum_7.png"
RummyConst.chipNumberPath1["8"] = "#c_addnum_8.png"
RummyConst.chipNumberPath1["9"] = "#c_addnum_9.png"
RummyConst.chipNumberPath1["k"] = "#c_addnum_k.png"
RummyConst.chipNumberPath1["."] = "#c_addnum_p.png"
RummyConst.chipNumberPath1["+"] = "#c_addnum_a.png"
RummyConst.chipNumberPath1["m"] = "#c_addnum_m.png"

RummyConst.chipNumberPath2 = {}
RummyConst.chipNumberPath2["0"] = "#c_minusnum_0.png"
RummyConst.chipNumberPath2["1"] = "#c_minusnum_1.png"
RummyConst.chipNumberPath2["2"] = "#c_minusnum_2.png"
RummyConst.chipNumberPath2["3"] = "#c_minusnum_3.png"
RummyConst.chipNumberPath2["4"] = "#c_minusnum_4.png"
RummyConst.chipNumberPath2["5"] = "#c_minusnum_5.png"
RummyConst.chipNumberPath2["6"] = "#c_minusnum_6.png"
RummyConst.chipNumberPath2["7"] = "#c_minusnum_7.png"
RummyConst.chipNumberPath2["8"] = "#c_minusnum_8.png"
RummyConst.chipNumberPath2["9"] = "#c_minusnum_9.png"
RummyConst.chipNumberPath2["k"] = "#c_minusnum_k.png"
RummyConst.chipNumberPath2["."] = "#c_minusnum_p.png"
RummyConst.chipNumberPath2["-"] = "#c_minusnum_i.png"
RummyConst.chipNumberPath2["m"] = "#c_minusnum_m.png"

--三公牌型
RummyConst.OTHERS               = 0 --其他牌
RummyConst.STRAIGHT             = 1 --顺子
RummyConst.STRAIGHT_FLUSH       = 2 --纯顺子
RummyConst.SANGONG              = 3 --条

RummyConst.JOKER              = 0x4f --条

return RummyConst
