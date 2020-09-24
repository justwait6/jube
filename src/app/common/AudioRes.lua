local AudioRes = {}

AudioRes.Music = {}


AudioRes.Effects = {}
AudioRes.Effects.CLICK_BUTTON = "sounds/effects/clickButton.ogg"
AudioRes.Effects.GEAR_TICK = "sounds/effects/gearTick.ogg"
AudioRes.Effects.CHIP_ON_TABLE = "sounds/effects/chipontable.ogg"

-- if device.platform == "ios" then
-- else
	-- 互动表情音效
	AudioRes.hddjSounds = {
		[1] = "sounds/hddj/Kiss.ogg",
		[2] = "sounds/hddj/rose.ogg",
		[3] = "sounds/hddj/eggs.ogg",
		[4] = "sounds/hddj/eggs.ogg",
		[5] = "sounds/hddj/chess.ogg",
		[6] = "sounds/hddj/Bomb.ogg"
	}
	-- common
	AudioRes.CHECK = "sounds/common/check.ogg"
	AudioRes.SOUND_CHIPS = "sounds/common/sound_chips.ogg"
	AudioRes.CALL = "sounds/common/call.ogg"
	AudioRes.ALL_IN = "sounds/common/allin.ogg"
	AudioRes.DICE_TIMEWARNING = "sounds/common/audio_timewarning.ogg"
	AudioRes.BOX_SHAKE = "sounds/common/boxshake.ogg"
	AudioRes.DELIVER_CARD = "sounds/common/dealCard.ogg"
	AudioRes.FLIP_CARD = "sounds/common/flipCard.ogg"
	AudioRes.LOBBY_MUSIC = "sounds/common/lobby.ogg"
	AudioRes.LOSE = "sounds/common/lose.ogg"
	AudioRes.MOVE_CHIPS = "sounds/common/moveChip.ogg"
	AudioRes.OPEN_BOX = "sounds/common/openbox.ogg"
	AudioRes.RAISE = "sounds/common/raise.ogg"
	AudioRes.REWARD = "sounds/common/reward.ogg"
	AudioRes.DICE_MUSIC = "sounds/common/roombackground.ogg"
	AudioRes.SHOW_CARD = "sounds/common/showcard.ogg"
	AudioRes.SHOW_HAND_CARD = "sounds/common/ShowHandCard.ogg"
	AudioRes.SLIDE_RAISE = "sounds/common/slide_raise.ogg"
	AudioRes.TAP_TABLE = "sounds/common/tapTable.ogg"
	AudioRes.VICTORY = "sounds/common/victory.ogg"
	AudioRes.WIN = "sounds/common/win.ogg"
	AudioRes.YOUR_TURN = "sounds/common/yourturn.ogg"
	-- hilo
	AudioRes.HILO_DING = "sounds/hilo/dingding.ogg"
	-- yxx
	AudioRes.YXX_MUSIC = "sounds/yxx/yxxbg.ogg"
	-- dummy 
	AudioRes.DUMMY_DEAL = "sounds/dummy/dummy_dealCard.ogg"
	AudioRes.DUMMY_FOLD = "sounds/dummy/dummy_foldCard.ogg"
	AudioRes.DUMMY_GET = "sounds/dummy/dummy_getCard.ogg"
	AudioRes.DUMMY_KNOCK = "sounds/dummy/dummy_knock.ogg"
	AudioRes.DUMMY_MAKEUP = "sounds/dummy/dummy_makeup.ogg"
	AudioRes.DUMMY_MINUS  = "sounds/dummy/dummy_minus.ogg"
	AudioRes.DUMMY_MYTURN = "sounds/dummy/dummy_myturn.ogg"
	AudioRes.DUMMY_PLUS = "sounds/dummy/dummy_plus.ogg"
	AudioRes.DUMMY_MUSIC = "sounds/dummy/dummy_music.ogg"
	--qiuqiu
	AudioRes.QIUQIU_ALLIN       = "sounds/qiuqiu/allin.ogg"
	AudioRes.QIUQIU_ALLINSLIDER = "sounds/qiuqiu/allin_slider.ogg"
	AudioRes.QIUQIU_FOLD        = "sounds/qiuqiu/fold.ogg"
	AudioRes.QIUQIU_SLIDER      = "sounds/qiuqiu/huakuai.ogg"
	AudioRes.QIUQIU_MOVECHIPS   = "sounds/qiuqiu/movingChips.ogg"
	AudioRes.QIUQIU_RAISE       = "sounds/qiuqiu/raise.ogg"
	AudioRes.QIUQIU_SWITCH      = "sounds/qiuqiu/switchPage.ogg"
	AudioRes.QIUQIU_TURN        = "sounds/qiuqiu/youturn.ogg"
	-- Gaple
	AudioRes.GAPLE_NOTICE = "sounds/gaple/gaple_notice.ogg"
	AudioRes.GAPLE_GAME_OVER = "sounds/gaple/gaple_GameOver.ogg"
	AudioRes.GAPLE_DEALCARD = "sounds/gaple/gaple_dealCard.ogg"
	AudioRes.GAPLE_COUNTDOWN = "sounds/gaple/gaple_CountDown.ogg"
	AudioRes.GAPLE_CHIPSFLY = "sounds/gaple/gaple_chipsFly.ogg"
	-- king
	AudioRes.KING_CALL       	 = "sounds/king/king_call.ogg"
	AudioRes.KING_COLLECTPOKER  = "sounds/king/king_collectpoker.ogg"
	AudioRes.KING_KAIPAI        = "sounds/king/king_kaipai.ogg"
	AudioRes.KING_LOSE          = "sounds/king/king_lose.ogg"
	AudioRes.KING_SHOWCARDS     = "sounds/king/king_showcards.ogg"
	AudioRes.KING_WIN       	 = "sounds/king/king_win.ogg"
	AudioRes.KING_WIN_SPECIAL   = "sounds/king/king_win_special.ogg"
	AudioRes.KING_CHANGE_CHIPS  = "sounds/king/king_changechips.ogg"
	-- sangong hundred
	AudioRes.HUNDRED_MOVE_CARD      = "sounds/hundred/hundred_move_card.ogg"
	AudioRes.HUNDRED_OPEN_CARD      = "sounds/hundred/hundred_open_card.ogg"
	AudioRes.HUNDRED_CROWD 	     = "sounds/hundred/hundred_crowd.ogg"
	AudioRes.HUNDRED_START_BET      = "sounds/hundred/hundred_start_bet.ogg"
	AudioRes.HUNDRED_END_BET        = "sounds/hundred/hundred_end_bet.ogg"
	AudioRes.HUNDRED_WIN            = "sounds/hundred/hundred_win.ogg"
	AudioRes.HUNDRED_LOSE           = "sounds/hundred/hundred_lose.ogg"
	AudioRes.HUNDRED_POT_PRIZE      = "sounds/hundred/hundred_pot_prize.ogg"
	AudioRes.HUNDRED_MUSIC 		 = "sounds/hundred/hundredRoomBgMusic.ogg"
	-- 老虎机
	AudioRes.SLOT_BIGWIN      = "sounds/slot/bigwin.ogg"
	AudioRes.SLOT_JACKPOT      = "sounds/slot/jackpotpopup.ogg"
	AudioRes.SLOT_FREESPINS 	= "sounds/slot/freespins_popup.ogg"
	AudioRes.SLOT_START	= "sounds/slot/stot_start.ogg"
	AudioRes.SLOT_FREE        = "sounds/slot/freespins.ogg"
	AudioRes.SLOT_PICKME            = "sounds/slot/pickme.ogg"
	AudioRes.SLOT_LINE           = "sounds/slot/slot_line.ogg"
	AudioRes.SLOT_STOP      = "sounds/slot/slot_stop.ogg"
	AudioRes.SLOT_RUNNING 		 = "sounds/slot/slot_running.ogg"
-- end
 
AudioRes.preload = {
	AudioRes.Effects.CLICK_BUTTON,
	AudioRes.Effects.CHIP_ON_TABLE,
	AudioRes.DELIVER_CARD,
	AudioRes.SLIDE_RAISE,
	AudioRes.REWARD
}

return AudioRes
