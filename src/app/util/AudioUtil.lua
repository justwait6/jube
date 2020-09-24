-- Author: Jam
-- Date: 2015.05.01

local AudioUtil = class("AudioUtil")
local AudioRes = import("app.common.AudioRes")

function AudioUtil:ctor()
    self:updateVolume()
end

function AudioUtil.getInstance()
    if not AudioUtil.singleInstance then
        AudioUtil.singleInstance = AudioUtil.new()
    end
    return AudioUtil.singleInstance
end

function AudioUtil:preload(soundsType)
    if soundsType and type(soundsType) == "table" then
        for _,soundName in pairs(soundsType) do
            if audio.preloadSound then 
                audio.preloadSound(soundName)
            elseif audio.loadFile then
                audio.loadFile(soundName, function(fn, success)
                    if DEBUG > 0 then
                        if success then
                            print(fn)
                            print("load success")
                        else
                            print("load error")
                        end
                    end
                end)
            end
        end
    end
end

function AudioUtil:unload(soundsType)
    if soundsType and type(soundsType) == "table" then
        for _, soundName in pairs(soundsType) do
            if audio.unloadSound then
                audio.unloadSound(soundName)
            else
                audio.unloadFile(soundName)
            end
        end
    end
end

function AudioUtil:playSound(soundName, loop, callback)
    if self:getSoundVolume() > 0 then
        if audio.playSound then
            return audio.playSound(soundName, loop or false)
        else
            audio.loadFile(soundName, function(soundName, success)
                    if success then
                        if callback then
                            callback(audio.playEffect(soundName, loop or false))
                        else
                            audio.playEffect(soundName, loop or false)
                        end
                    end
                end)
        end
    end
    return nil
end

function AudioUtil:stopAllSounds()
    if audio.stopAllSounds then
        audio.stopAllSounds()
    else
        audio.stopAll()
    end
end

function AudioUtil:stopSound(handle)
    if handle then
        if audio.stopSound then
            audio.stopSound(handle)
        else
            audio.stopEffect()
        end
    end
end

function AudioUtil:updateVolume()
    self.volume_ = g.userDefault:getIntegerForKey(g.cookieKey.VOLUME, 100)
    if audio.setSoundsVolume then
        audio.setSoundsVolume(self.volume_/100)
    elseif audio.setEffectVolume then
        audio.setEffectVolume(self.volume_/100)
    end
end

function AudioUtil:setMusicVolume(musicVolume)
    self.m_musicVolume = musicVolume
    if self.m_musicVolume <= 0 then 
        self.m_musicVolume = 0
    end
    if self.m_musicVolume >= 1 then 
        self.m_musicVolume = 1
    end
    if audio.setMusicVolume then
        audio.setMusicVolume(self.m_musicVolume)
    elseif audio.setBGMVolume then
        audio.setBGMVolume(self.m_musicVolume)
    end
end

function AudioUtil:getMusicVolume()
    if not self.m_musicVolume then 
        if audio.getMusicVolume then
            self.m_musicVolume = audio.getMusicVolume()
        else
            self.m_musicVolume = audio._BGMVolume
        end
    end
    return self.m_musicVolume*100
end

function AudioUtil:setSoundVolume(soundVolume)
    self.m_soundVolume = soundVolume
    if self.m_soundVolume <= 0 then 
        self.m_soundVolume = 0
    end
    if self.m_soundVolume >= 1 then 
        self.m_soundVolume = 1
    end
    if audio.setSoundsVolume then
        audio.setSoundsVolume(self.m_soundVolume)
    else
        audio.setEffectVolume(self.m_soundVolume)
    end
end

function AudioUtil:getSoundVolume()
    if not self.m_soundVolume then
        if audio.getSoundsVolume then
            self.m_soundVolume = audio.getSoundsVolume()
        else 
            self.m_soundVolume = audio._effectVolume
        end
    end

    return self.m_soundVolume*100
end

function AudioUtil:playHddjSound(id)
    if self.volume_ > 0 then
        self:playSound(AudioRes.hddjSounds[id], false)
    end
end

function AudioUtil:playMusic(filename)
    if self:getMusicVolume() > 0 then
        if audio.preloadMusic then
            audio.preloadMusic(filename)
            audio.playMusic(filename, true)
        else
            audio.loadFile(filename, function(fn, success)
                    if success then
                        audio.playBGM(fn, true)
                    end
                end
            )
        end
    else
        self:pauseMusic()
    end
end

function AudioUtil:stopMusic()
    if audio.stopMusic then
        audio.stopMusic(true)
    else
        audio.stopBGM()
    end
end

function AudioUtil:pauseMusic()
    if audio.pauseMusic then
        audio.pauseMusic()
    else
        audio.pauseAll()
    end
end

function AudioUtil:resumeMusic()
    if audio.resumeMusic then
        audio.resumeMusic()
    else
        audio.resumeAll()
    end
end

return AudioUtil
