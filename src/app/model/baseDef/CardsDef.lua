local CardsDef = {}

CardsDef.VARIETY_DIAMOND = 0 -- 方块
CardsDef.VARIETY_CLUB    = 1 -- 梅花
CardsDef.VARIETY_HEART   = 2 -- 红桃
CardsDef.VARIETY_SPADE   = 3 -- 黑桃
CardsDef.VARIETY_JOKER   = 4 -- Joker牌(0x4e小王; 0x4f大王)
CardsDef.SMALL_JOKER     = 0x4e -- 小Joker牌
CardsDef.BIG_JOKER       = 0x4f -- 大Joker牌

return CardsDef
