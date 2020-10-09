local RoomConst = {}

RoomConst.UserNum = 5
RoomConst.MSeatId = 2
RoomConst.NoPlayerSeatId = -10
RoomConst.GirlSeatId = 5
RoomConst.MAX_GROUP_NUM = 6
RoomConst.DRAW_CARD_ID = 14
RoomConst.MAX_SCORE = 80

RoomConst.toSFactor = 0.8

RoomConst.USER_STAND = -1 --玩家站起
RoomConst.USER_SEAT = 0 --玩家坐下
RoomConst.USER_PLAY = 1 -- 正在玩牌
RoomConst.USER_FOLD = 2 --玩家弃牌

RoomConst.isMeInGames = false

RoomConst.chipNumberPath1 = {}
RoomConst.chipNumberPath1["0"] = "#c_addnum_0.png"
RoomConst.chipNumberPath1["1"] = "#c_addnum_1.png"
RoomConst.chipNumberPath1["2"] = "#c_addnum_2.png"
RoomConst.chipNumberPath1["3"] = "#c_addnum_3.png"
RoomConst.chipNumberPath1["4"] = "#c_addnum_4.png"
RoomConst.chipNumberPath1["5"] = "#c_addnum_5.png"
RoomConst.chipNumberPath1["6"] = "#c_addnum_6.png"
RoomConst.chipNumberPath1["7"] = "#c_addnum_7.png"
RoomConst.chipNumberPath1["8"] = "#c_addnum_8.png"
RoomConst.chipNumberPath1["9"] = "#c_addnum_9.png"
RoomConst.chipNumberPath1["k"] = "#c_addnum_k.png"
RoomConst.chipNumberPath1["."] = "#c_addnum_p.png"
RoomConst.chipNumberPath1["+"] = "#c_addnum_a.png"
RoomConst.chipNumberPath1["m"] = "#c_addnum_m.png"

RoomConst.chipNumberPath2 = {}
RoomConst.chipNumberPath2["0"] = "#c_minusnum_0.png"
RoomConst.chipNumberPath2["1"] = "#c_minusnum_1.png"
RoomConst.chipNumberPath2["2"] = "#c_minusnum_2.png"
RoomConst.chipNumberPath2["3"] = "#c_minusnum_3.png"
RoomConst.chipNumberPath2["4"] = "#c_minusnum_4.png"
RoomConst.chipNumberPath2["5"] = "#c_minusnum_5.png"
RoomConst.chipNumberPath2["6"] = "#c_minusnum_6.png"
RoomConst.chipNumberPath2["7"] = "#c_minusnum_7.png"
RoomConst.chipNumberPath2["8"] = "#c_minusnum_8.png"
RoomConst.chipNumberPath2["9"] = "#c_minusnum_9.png"
RoomConst.chipNumberPath2["k"] = "#c_minusnum_k.png"
RoomConst.chipNumberPath2["."] = "#c_minusnum_p.png"
RoomConst.chipNumberPath2["-"] = "#c_minusnum_i.png"
RoomConst.chipNumberPath2["m"] = "#c_minusnum_m.png"

--三公牌型
RoomConst.OTHERS               = 0 --其他牌
RoomConst.STRAIGHT             = 1 --顺子
RoomConst.STRAIGHT_FLUSH       = 2 --纯顺子
RoomConst.SANGONG              = 3 --条

RoomConst.JOKER              = 0x4f --条

return RoomConst
