local lang = {}
local L = lang

L.COMMON = {}
L.COMMON.CONFIRM 							 = "确定"
L.COMMON.CANCEL 							 = "取消"
L.COMMON.LOGOUT 							 = "登出"
L.COMMON.FACEBOOK 							 = "FACEBOOK"
L.COMMON.GAME_START 						 = "开始游戏"
L.COMMON.NO_NETWORK 						 = "当前没有网络"
L.COMMON.SEND 								 = "发送"
L.COMMON.UPDATE_FAIL 						 = "同步/更新失败"
L.COMMON.COPY                             	 = "复制"
L.COMMON.COPY_SUCC                           = "复制成功"
L.COMMON.NICKNAME                            = "昵称"
L.COMMON.NOT_HAVE                            = "无"

L.TEST = {}
L.TEST.HELLO_WORLD 							 = "你好, 世界"

L.LOGIN = {}
L.LOGIN.LOGIN 								 = "登录"
L.LOGIN.LOGIN_TIPS 							 = "现在是登录界面, 有本事进游戏来找我啊"
L.LOGIN.SIGNUP_TIPS 						 = "注册界面, 兄嘚"
L.LOGIN.NAME_TIPS 							 = "用户名"
L.LOGIN.PWD_TIPS 							 = "密码"
L.LOGIN.EMAIL_TIPS 							 = "邮箱"
L.LOGIN.SIGNUP 							 	 = "注册"
L.LOGIN.GO_SIGNUP 							 = "去注册"
L.LOGIN.SIGNUP_SUCC 						 = "注册成功, 2秒后自动跳入登录界面"
L.LOGIN.GO_LOGIN 							 = "去登录"

L.HALL = {}
L.HALL.HALL_TIPS 							 = "你果然来了, 这是大厅, 我告诉你下一步怎么走"

L.HTTP = {}
L.HTTP.TIMEOUT 								 = "连接超时"
L.HTTP.TOKEN_EXPIRED_TIPS 					 = "长时间未操作, 请重新登录"

L.USER = {}
L.USER.IDENTIFY_NAME 						 = "青果名"

L.FRIEND = {}
L.FRIEND.SEARCH_FRIEND 						 = "搜索好友"
L.FRIEND.NAME_TIPS 							 = "输入用户名"
L.FRIEND.SEARCH 							 = "搜索"
L.FRIEND.USER_NOT_FOUND						 = "未找到用户~"
L.FRIEND.ADD						 		 = "添加"
L.FRIEND.USER_NAME_EMPTY					 = "用户名为空"
L.FRIEND.REQ_SEND_SUCC					 	 = "好友请求已发送"
L.FRIEND.REQ_SEND_FAIL					 	 = "未知错误, 请稍后再添加"
L.FRIEND.NO_FRIEND_TIPS					 	 = "暂无好友, 快去添加吧"
L.FRIEND.NO_CHAT_FRIEND_TIPS = "快找好友聊天吧"
L.FRIEND.NO_REQ_ADD_TIPS					 = "没有好友请求信息"
L.FRIEND.ADD_SUCC					 		 = "添加好友成功"
L.FRIEND.ADD_FAIL					 		 = "添加好友失败"
L.FRIEND.CAN_NOT_ADD_SELF					 = "不能添加自己为好友"
L.FRIEND.GET_FRIEND_LIST_FAIL				 = "拉取好友失败"
L.FRIEND.ACCEPT						 		 = "接受"
L.FRIEND.GO_CHAT						 	 = "去聊天"
L.FRIEND.REMARK						 	 	 = "备注"

L.MONEYTREE = {}
L.MONEYTREE.MONEYTREE                        = "摇钱树"
L.MONEYTREE.ALREADY_GET                      = "(已领:{num})"
L.MONEYTREE.MY_CODE                          = "我的邀请码"
L.MONEYTREE.BIND                             = "绑定"
L.MONEYTREE.BIND_SIMPLE                      = "绑定简版"
L.MONEYTREE.BINDED                           = "已绑定"
L.MONEYTREE.INPUT_CODE                       = "输入朋友邀请码"
L.MONEYTREE.CONFIRM                          = "确定"
L.MONEYTREE.GOLD_GET_LIMIT                   = "总金币上限"
L.MONEYTREE.CHIP_GET_LIMIT                   = "总筹码上限"
L.MONEYTREE.X_GOLD                           = "{num}金币"
L.MONEYTREE.X_GOLD_CAPACITY                  = "{num}金币容量"
L.MONEYTREE.VALID_TIME                       = "有效期"
L.MONEYTREE.DAY                              = "天"
L.MONEYTREE.GOLD_FROM_FRIEND                 = "好友产出金币"
L.MONEYTREE.CHIP_FROM_FRIEND                 = "好友产出筹码"
L.MONEYTREE.INVITE                           = "邀请"
L.MONEYTREE.RANK                             = "排名"
L.MONEYTREE.RULE1                            = "1.邀请好友越多，产生金币越多"
L.MONEYTREE.RULE1_CHIP                       = "1.邀请好友越多，产生筹码越多"
L.MONEYTREE.RULE2                            = "2.自己在金币场玩牌越多，产生金币越多"
L.MONEYTREE.RULE2_CHIP                       = "2.自己在金币场玩牌越多，产生筹码越多"
L.MONEYTREE.RULE3                            = "3.好友在金币场玩牌越多，产生金币越多"
L.MONEYTREE.RULE3_CHIP                       = "3.好友在金币场玩牌越多，产生筹码越多"
L.MONEYTREE.RULE4                            = "4.在发财树领取的金币达到一定数量后，发财树可升级"
L.MONEYTREE.RULE4_CHIP                       = "4.在发财树领取的筹码达到一定数量后，发财树可升级"
L.MONEYTREE.COPY_DESC                        = "朋友输入你的邀请码，你就可以获得金币/筹码。邀请朋友越多，获得金币/筹码越多，朋友玩牌越多，获得金币/筹码越多。"
L.MONEYTREE.CODE_NOT_EXIST                   = "邀请码不存在"
L.MONEYTREE.BIND_ERROR                       = "绑定错误"
L.MONEYTREE.INVITE_DESC                      = "通过Line FB，向你的朋友发送邀请链接"
L.MONEYTREE.INVITE_GET                       = "邀请获得"
L.MONEYTREE.CREDIT_GET                       = "充值获得"
L.MONEYTREE.WATER_GET                        = "浇水获得"
L.MONEYTREE.CAN_STEAL                        = "可偷取"
L.MONEYTREE.YOU_GET_HIM                      = "你拿他游戏币"
L.MONEYTREE.YOU_WATER_HIM                    = "你帮忙浇水"
L.MONEYTREE.HE_GET_YOU                       = "他拿你游戏币"
L.MONEYTREE.HE_WATER_YOU                     = "他帮你浇水"
L.MONEYTREE.NO_DYNAMICS                      = "暂无动态"
L.MONEYTREE.INVITE_DESC2                     = "邀请朋友得游戏币"
L.MONEYTREE.PRODUCE                          = "产生"
L.MONEYTREE.COME_TOMORROW                    = "明天再来"
L.MONEYTREE.NEED_UPDATE                      = "好友未升级到新版本"

L.TIME = {}
L.TIME.TODAY 								 = "今天"
L.TIME.YESTERDAY 							 = "昨天"

L.CHAT = {}
L.CHAT.INPUT_TIPS 							 = "请输入聊天内容"
L.CHAT.SEND 							 	 = "发送"
L.CHAT.INPUT_EMPTY_TIPS 					 = "输入内容为空"

return lang
