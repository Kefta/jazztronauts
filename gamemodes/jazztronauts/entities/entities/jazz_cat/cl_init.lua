include("shared.lua")

-- How quickly the chat fades in and out
ENT.ChatFadeSpeed = 1.2

ENT.ChatFade = 0
function ENT:Initialize()

    -- Allow mouse clicks on the chat menu (and make it so clicking doesn't shoot their weapon)
    if self:GetNPCID() == missions.NPC_CAT_BAR then
        hook.Add("KeyPress", self, function(self, ply, key) return self:OnMouseClicked(ply, key) end )
        hook.Add("KeyRelease", self, function(self, ply, key) return self:OnMouseReleased(ply, key) end)
    end

end

function ENT:OnMouseClicked(ply, key)
    if not IsFirstTimePredicted() or key != IN_ATTACK then return end

    if self.IsLeftDown then return end
    self.IsLeftDown = true

    local opt = self:GetSelectedOption(LocalPlayer(), self.BarChoices)
    if opt then

        surface.PlaySound("buttons/button9.wav")
        self.BarChoices[opt].func(self, LocalPlayer())
    end
end

function ENT:OnMouseReleased(ply, key)
    if not IsFirstTimePredicted() then return end
    if key == IN_ATTACK or (key == IN_ZOOM and self.IsLeftDown) then
        self.IsLeftDown = false      
    end
end 

function ENT:ShouldDrawChat()
    local pos = self:GetMenuPosAng(LocalPlayer())
    return LocalPlayer():EyePos():Distance(pos) < self.ChatFadeDistance
end

function ENT:UpdateChatFade()
    local shouldDraw = self:ShouldDrawChat()
    local change = 0
    if shouldDraw && self.ChatFade < 1.0 then
        change = 1
    elseif not shouldDraw && self.ChatFade > 0.0 then
        change = -1
    end

    self.ChatFade = math.Clamp(self.ChatFade + FrameTime() * self.ChatFadeSpeed * change, 0, 1)
end

function ENT:Draw()
    if not self.GetNPCID then return end 
    self:DrawModel()

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    local offset = self:GetAngles():Up() * 70
    offset = offset + self:GetAngles():Forward() * -5
    local right = self:GetAngles():Right()

    -- Draw debug name above their head. TODO: This is lazy. Style cat models.
    cam.Start3D2D(self:GetPos() + offset, ang, 0.1)
        draw.DrawText(missions.GetNPCName(self:GetNPCID()), "SteamCommentFont", 0, 0, color_white, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    
    -- Only the bartender has multiple options, everyone else just chats
    if self:GetNPCID() == missions.NPC_CAT_BAR then
        self:UpdateChatFade()

        -- Don't draw if 100% hidden
        if self.ChatFade > 0 then
            self:DrawDialogEntry(self.BarChoices, self.ChatFade)
        end
    
        -- Play a small click sound when switching between options
        local opt = self:GetSelectedOption(LocalPlayer(), self.BarChoices)
        if self.LastOption != opt then
            self.LastOption = opt
        

            LocalPlayer():EmitSound("buttons/lightswitch2.wav", 0, 175)
        end
    end

end

dialog.RegisterFunc("setskin", function(d, skinid)
    local skinid = tonumber(skinid) or 0
    local cat = dialog.GetFocus()

    if IsValid(cat) then
	    cat:SetSkin(skinid)
    end
end )

local bitch = [[What the fuck did you just fucking say about me, you little bitch? I’ll have you know I graduated top of my class in the Navy Seals, and I’ve been involved in numerous secret raids on Al-Quaeda, and I have over 300 confirmed kills. I am trained in gorilla warfare and I’m the top sniper in the entire US armed forces. You are nothing to me but just another target. I will wipe you the fuck out with precision the likes of which has never been seen before on this Earth, mark my fucking words. You think you can get away with saying that shit to me over the Internet? Think again, fucker. As we speak I am contacting my secret network of spies across the USA and your IP is being traced right now so you better prepare for the storm, maggot. The storm that wipes out the pathetic little thing you call your life. You’re fucking dead, kid. I can be anywhere, anytime, and I can kill you in over seven hundred ways, and that’s just with my bare hands. Not only am I extensively trained in unarmed combat, but I have access to the entire arsenal of the United States Marine Corps and I will use it to its full extent to wipe your miserable ass off the face of the continent, you little shit. If only you could have known what unholy retribution your little “clever” comment was about to bring down upon you, maybe you would have held your fucking tongue. But you couldn’t, you didn’t, and now you’re paying the price, you goddamn idiot. I will shit fury all over you and you will drown in it. You’re fucking dead, kiddo.]]
local bitchArr = string.Split(bitch, " ")
dialog.RegisterFunc("bitch", function(d)
    for i=1, #bitchArr do
        d.rate = i
        surface.PlaySound("garrysmod/balloon_pop_cute.wav")
        coroutine.yield(bitchArr[i] .. (i % 17 == 0 and "\n" or " "))
    end
end )

dialog.RegisterFunc("punch", function(d)
    LocalPlayer():ViewPunch(Angle(45, 0, 0))
end )

dialog.RegisterFunc("emitsound", function(d, snd)
    surface.PlaySound(snd)
end )
dialog.RegisterFunc("slam", function(d, ...)
    return table.concat({...}, " ")
end )
dialog.RegisterFunc("shake", function(d, time)
    util.ScreenShake(LocalPlayer():GetPos(), 8, 8, time or 1, 256)
end )
dialog.RegisterFunc("fadeblind", function(d)
    LocalPlayer():ScreenFade(SCREENFADE.IN, color_white, 2, 2)
end )
dialog.RegisterFunc("dsp", function(d, dspid)
    local dspid = tonumber(dspid) or 0
    LocalPlayer():SetDSP(dspid, true)
end )