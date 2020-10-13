local CardDef = {}

CardDef.VARIETY_DIAMOND = 0 -- 方块
CardDef.VARIETY_CLUB    = 1 -- 梅花
CardDef.VARIETY_HEART   = 2 -- 红桃
CardDef.VARIETY_SPADE   = 3 -- 黑桃
CardDef.VARIETY_JOKER   = 4 -- Joker牌(0x4e小王; 0x4f大王)
CardDef.SMALL_JOKER     = 0x4e -- 小Joker牌
CardDef.BIG_JOKER       = 0x4f -- 大Joker牌

return CardDef
