-- BonoboAddon.lua

local f = CreateFrame("Frame")

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_RAID_WARNING")
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_PARTY")
f:RegisterEvent("CHAT_MSG_GUILD")
f:RegisterEvent("CHAT_MSG_SAY")
f:RegisterEvent("CHAT_MSG_YELL")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")




local chatEvents = {
    ["CHAT_MSG_RAID"] = true,
    ["CHAT_MSG_PARTY"] = true,
    ["CHAT_MSG_GUILD"] = true,
    ["CHAT_MSG_SAY"] = true
}
local lastTriggerTime = 0
local cooldown = 5
local RandomSounds = { "rand1.mp3", "rand2.mp3", "rand3.mp3", "rand4.mp3" }
local wasAbove10 = true


-------------------------------------
-- 🔹 Ready Check visual alert
------------------------------------------------------------
local readyFrame = CreateFrame("Frame", nil, UIParent)
readyFrame:SetSize(600, 400)
readyFrame:SetPoint("CENTER")
readyFrame:Hide()

-- Skull background image
local readyTex = readyFrame:CreateTexture(nil, "OVERLAY")
readyTex:SetAllPoints()
readyTex:SetTexture("Interface\\AddOns\\BonoboAddon\\skull.png")
readyTex:SetAlpha(0.7)

-- Big red text
local readyText = readyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
readyText:SetPoint("CENTER")
readyText:SetText("|cffff0000 rembember to check your gear and talents |r")
readyText:SetFont("Fonts\\FRIZQT__.TTF", 48, "OUTLINE, THICKOUTLINE")
readyText:SetJustifyH("CENTER")
readyText:SetJustifyV("MIDDLE")
readyText:SetAlpha(0)


local function TriggerReadyAlert()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    -- Play sound
    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\rembemb.mp3", "Master")

    -- Show frame and fade in both text and skull
    readyFrame:SetAlpha(0)
    readyFrame:Show()
    UIFrameFadeIn(readyFrame, 0.3, 0, 1)

    -- Text pulsing effect
    local pulseCount = 0
    local function PulseText()
        if pulseCount >= 4 then return end
        pulseCount = pulseCount + 1
        UIFrameFadeIn(readyText, 0.25, 0, 1)
        C_Timer.After(0.25, function()
            UIFrameFadeOut(readyText, 0.25, readyText:GetAlpha(), 0)
        end)
        C_Timer.After(0.5, PulseText)
    end
    PulseText()

    -- Hide after 3 seconds total
    C_Timer.After(3, function()
        UIFrameFadeOut(readyFrame, 0.5, readyFrame:GetAlpha(), 0)
        C_Timer.After(0.5, function() readyFrame:Hide() end)
    end)

    print("|cff00ff00[BonoboAddon]|r Ready check initiated — REMBEMBER!")
end

------------------------------------------------------------
-- 🔹 Main Bonobo image + text
------------------------------------------------------------
local bonoboFrame = CreateFrame("Frame", nil, UIParent)
bonoboFrame:SetSize(512, 512)
bonoboFrame:SetPoint("CENTER")
bonoboFrame:Hide()

local bonoboTex = bonoboFrame:CreateTexture(nil, "OVERLAY")
bonoboTex:SetAllPoints()
bonoboTex:SetTexture("Interface\\AddOns\\BonoboAddon\\dab.png")

local bonoboText = bonoboFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
bonoboText:SetPoint("BOTTOM", bonoboFrame, "TOP", 0, 20)
bonoboText:SetText("|cffff0000BONOBO ALERT|r")
bonoboText:SetFont("Fonts\\FRIZQT__.TTF", 36, "OUTLINE")
bonoboText:SetAlpha(0)
bonoboText:Hide()

------------------------------------------------------------
-- 🔹 Red screen-edge flash
------------------------------------------------------------
local edgeFrame = CreateFrame("Frame", nil, UIParent)
edgeFrame:SetAllPoints(UIParent)
edgeFrame:Hide()

local edgeTex = edgeFrame:CreateTexture(nil, "BACKGROUND")
edgeTex:SetAllPoints()
edgeTex:SetColorTexture(1, 0, 0, 0.4)
edgeTex:SetBlendMode("ADD")

------------------------------------------------------------
-- 🔹 Extra random images
------------------------------------------------------------
local extraImages = { "bonobo1.png", "bonobo2.png" }
local numExtras = 6 -- total images to flash during alert

local extraFrames = {}
for i = 1, numExtras do
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(128, 128)
    frame:Hide()

    local tex = frame:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    frame.texture = tex

    extraFrames[i] = frame
end

local function ShowRandomExtras()
    for i = 1, numExtras do
        local frame = extraFrames[i]
        local img = extraImages[math.random(#extraImages)]
        frame.texture:SetTexture("Interface\\AddOns\\BonoboAddon\\" .. img)

        -- Random position
        local x = math.random(100, GetScreenWidth() - 100)
        local y = math.random(100, GetScreenHeight() - 100)
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

        -- Show briefly
        frame:SetAlpha(0)
        frame:Show()
        UIFrameFadeIn(frame, 0.2, 0, 1)
        C_Timer.After(0.5 + math.random() * 0.5, function()
            UIFrameFadeOut(frame, 0.3, frame:GetAlpha(), 0)
            C_Timer.After(0.3, function() frame:Hide() end)
        end)
    end
end

------------------------------------------------------------
-- 🔹 Main animation for image + text
------------------------------------------------------------
local flash = bonoboFrame:CreateAnimationGroup()
local fadeIn = flash:CreateAnimation("Alpha")
fadeIn:SetFromAlpha(0)
fadeIn:SetToAlpha(1)
fadeIn:SetDuration(0.3)
fadeIn:SetOrder(1)

local hold = flash:CreateAnimation("Alpha")
hold:SetFromAlpha(1)
hold:SetToAlpha(1)
hold:SetDuration(2.0)
hold:SetOrder(2)

local fadeOut = flash:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(1.0)
fadeOut:SetOrder(3)

-- Text blinking
local textFlash = bonoboText:CreateAnimationGroup()
textFlash:SetLooping("REPEAT")

local textFadeOut = textFlash:CreateAnimation("Alpha")
textFadeOut:SetFromAlpha(1)
textFadeOut:SetToAlpha(0.3)
textFadeOut:SetDuration(0.25)
textFadeOut:SetOrder(1)

local textFadeIn = textFlash:CreateAnimation("Alpha")
textFadeIn:SetFromAlpha(0.3)
textFadeIn:SetToAlpha(1)
textFadeIn:SetDuration(0.25)
textFadeIn:SetOrder(2)

-- Hooks
flash:SetScript("OnPlay", function()
    bonoboText:Show()
    bonoboText:SetAlpha(1)
    textFlash:Play()

    -- Quick red edge flash
    edgeFrame:Show()
    edgeFrame:SetAlpha(0)
    UIFrameFadeIn(edgeFrame, 0.2, 0, 0.6)
    C_Timer.After(0.5, function()
        UIFrameFadeOut(edgeFrame, 0.4, edgeFrame:GetAlpha(), 0)
    end)

    -- Spawn random extras multiple times
    for i = 0, 3 do
        C_Timer.After(i * 0.4, ShowRandomExtras)
    end
end)

flash:SetScript("OnFinished", function()
    bonoboText:Hide()
    bonoboFrame:Hide()
    edgeFrame:Hide()
    textFlash:Stop()
    for i = 1, numExtras do
        extraFrames[i]:Hide()
    end
end)

------------------------------------------------------------
-- 🔹 Trigger function
------------------------------------------------------------
local function TriggerBonobo()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    print("|cff00ff00[BonoboAddon]|r Trigger activated!")
    bonoboFrame:Show()
    flash:Play()
    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\buzzer.mp3", "Master")
end

------------------------------------------------------------
-- 🔹 Player Death: Sad Bonobo alert
------------------------------------------------------------
local deathFrame = CreateFrame("Frame", nil, UIParent)
deathFrame:SetSize(600, 400)
deathFrame:SetPoint("CENTER")
deathFrame:Hide()

-- Sad Bonobo Image
local deathTex = deathFrame:CreateTexture(nil, "OVERLAY")
deathTex:SetAllPoints()
deathTex:SetTexture("Interface\\AddOns\\BonoboAddon\\sadbonobo.png")
deathTex:SetAlpha(0.9)

-- Disappointment Text
local deathText = deathFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
deathText:SetPoint("BOTTOM", deathFrame, "TOP", 0, 20)
deathText:SetText("|cffff0000Bonobo is very disappointed|r")
deathText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE, THICKOUTLINE")
deathText:SetJustifyH("CENTER")
deathText:SetAlpha(0)

-- Trigger function
local function TriggerDeathAlert()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    -- Play sad sound
    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\sad.mp3", "Master")

    -- Show frame
    deathFrame:SetAlpha(0)
    deathFrame:Show()
    UIFrameFadeIn(deathFrame, 0.5, 0, 1)

    -- Text fade-in
    UIFrameFadeIn(deathText, 0.6, 0, 1)

    -- Fade everything out after 4 seconds
    C_Timer.After(4, function()
        UIFrameFadeOut(deathFrame, 1.0, deathFrame:GetAlpha(), 0)
        UIFrameFadeOut(deathText, 1.0, deathText:GetAlpha(), 0)
        C_Timer.After(1.0, function()
            deathFrame:Hide()
            deathText:SetAlpha(0)
        end)
    end)

    print("|cff00ff00[BonoboAddon]|r You have died. Bonobo is disappointed...")
end

-- 🔹 Golden Roll: Flash golden.png and play 100.mp3
------------------------------------------------------------
local goldenFrame = CreateFrame("Frame", nil, UIParent)
goldenFrame:SetSize(512, 512)
goldenFrame:SetPoint("CENTER")
goldenFrame:Hide()

local goldenTex = goldenFrame:CreateTexture(nil, "OVERLAY")
goldenTex:SetAllPoints()
goldenTex:SetTexture("Interface\\AddOns\\BonoboAddon\\golden.png")

local function TriggerGoldenRoll()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    print("|cff00ff00[BonoboAddon]|r Someone rolled a 100! Bonobo is PROUD!")
    goldenFrame:Show()
    UIFrameFadeIn(goldenFrame, 0.5, 0, 1)
    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\100.mp3", "Master")
    C_Timer.After(2, function()
        UIFrameFadeOut(goldenFrame, 1, goldenFrame:GetAlpha(), 0)
        C_Timer.After(1, function() goldenFrame:Hide() end)
    end)
end

------------------------------------------------------------
-- 🔹 So True
------------------------------------------------------------
local function SoTrue()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    print("|cff00ff00[BonoboAddon]|cffe580ff Vesu Mentioned")
    if IsInInstance() then
        SendChatMessage("So true", "SAY")
    end
end

------------------------------------------------------------
-- 🔹 Vulpmaxxing
------------------------------------------------------------
local vulpFrame = CreateFrame("Frame", nil, UIParent)
vulpFrame:SetSize(350, 350)
vulpFrame:SetPoint("TOP")
vulpFrame:Hide()

local vulpTex = vulpFrame:CreateTexture(nil, "OVERLAY")
vulpTex:SetAllPoints()
vulpTex:SetTexture("Interface\\AddOns\\BonoboAddon\\vulp.png")

local function Vulp()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    print("|cff00ff00[BonoboAddon]|cffe580ff Vulmekk Mentioned. Vulpmaxxing Engaged")
    vulpFrame:Show()
    UIFrameFadeIn(vulpFrame, 0.5, 0, 1)
    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\VineBoom.mp3", "Master")
    C_Timer.After(2, function()
        UIFrameFadeOut(vulpFrame, 1, vulpFrame:GetAlpha(), 0)
        C_Timer.After(1, function() vulpFrame:Hide() end)
    end)
end


------------------------------------------------------------
-- 🔹 Bonobo Mentioned
------------------------------------------------------------

local function BonoboMentioned()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\" .. RandomSounds[math.random(#RandomSounds)], "Master")
    do
        ShowRandomExtras()
    end
end


------------------------------------------------------------
-- 🔹 HELPO
------------------------------------------------------------

local function Helpo()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    print("|cff00ff00[BonoboAddon]|cFF000000 HEALTH LOW! HELPO!!")
    if IsInInstance() then
        SendChatMessage("helpo", "YELL")
    end
end

------------------------------------------------------------
-- 🔹 BLOODLUST GAMING
------------------------------------------------------------
local function Bloodlust()
    local currentTime = GetTime()
    if currentTime - lastTriggerTime < cooldown then
        return
    end
    lastTriggerTime = currentTime

    local bloodlustFrame = CreateFrame("Frame", nil, UIParent)
    bloodlustFrame:SetSize(256, 256)
    bloodlustFrame:SetPoint("CENTER")
    bloodlustFrame:Hide()

    local bloodlustTex = bloodlustFrame:CreateTexture(nil, "OVERLAY")
    bloodlustTex:SetAllPoints()
    bloodlustTex:SetTexture("Interface\\AddOns\\BonoboAddon\\bl.png")

    print("|cff00ff00[BonoboAddon]|cFF000000 BLOODLUST!? BONOBO ANGRY!!!")
    bloodlustFrame:Show()
    UIFrameFadeIn(bloodlustFrame, 0.5, 0, 1)
    PlaySoundFile("Interface\\AddOns\\BonoboAddon\\bl.mp3", "Master")
    C_Timer.After(2, function()
        UIFrameFadeOut(bloodlustFrame, 1, bloodlustFrame:GetAlpha(), 0)
        C_Timer.After(1, function() bloodlustFrame:Hide() end)
    end)
end

------------------------------------------------------------
-- 🔹 Monk randomizer
------------------------------------------------------------
local funcs = { SoTrue, Vulp }
local function MonkRandomizer()
    local f = funcs[math.random(1,#funcs)]
    f()
end

------------------------------------------------------------
-- 🔹 Event handler
------------------------------------------------------------
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "BonoboAddon" then
        print("|cff00ff00[BonoboAddon]|r Loaded successfully.")
    elseif event == "CHAT_MSG_RAID_WARNING" then
        TriggerBonobo()
        --    elseif event == "CHAT_MSG_SAY" and arg1 == "1234678901" then
        --        TriggerBonobo()
    elseif event == "READY_CHECK" then
        TriggerReadyAlert()
        --    elseif event == "CHAT_MSG_SAY" and arg1 == "1234578901" then
        --        TriggerReadyAlert()
    elseif event == "PLAYER_DEAD" then
        TriggerDeathAlert()
        --    elseif event == "CHAT_MSG_SAY" and arg1 == "1234568901" then
        --        TriggerDeathAlert()
    elseif event == "CHAT_MSG_SYSTEM" and arg1:find("rolls 100") then
        TriggerGoldenRoll()
        --    elseif event == "CHAT_MSG_SAY" and arg1 == "1234568901" then
        --        TriggerGoldenRoll()
    --elseif event == "CHAT_MSG_SAY" and (arg1:find("Vesu") or arg1:find("vesu") or arg1:find("VESU")) then
        SoTrue()
    --elseif event == "CHAT_MSG_SAY" and (arg1:find("Vulmekk") or arg1:find("vulmekk") or arg1:find("VULMEKK")) then
        Vulp()
    elseif event == "CHAT_MSG_SAY" and (arg1:find("Vesu") or arg1:find("vesu") or arg1:find("VESU")) then
        MonkRandomizer()
    elseif event == "CHAT_MSG_SAY" and (arg1:find("Vulmekk") or arg1:find("vulmekk") or arg1:find("VULMEKK")) then
        MonkRandomizer()
    elseif chatEvents[event] and (arg1:find("Bonobo") or arg1:find("bonobo") or arg1:find("BONOBO")) then
        BonoboMentioned()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, sourceGUID, sourceName, _, _, _, destName, _, _, spellID = CombatLogGetCurrentEventInfo()
        if subevent == "SPELL_AURA_APPLIED" and (spellID == 57723 or spellID == 57724 or spellID == 390435 or spellID == 264689) and destName == UnitName("player") then
            Bloodlust()
        end
    elseif event == "UNIT_HEALTH" and arg1 == "player" then
        local healthPercent = UnitHealth("player") / UnitHealthMax("player")
        if healthPercent <= 0.1 and wasAbove10 then
            wasAbove10 = false
            Helpo()
        elseif healthPercent > 0.1 then
            wasAbove10 = true
        end
    end
end)
----"CHAT_MSG_SAY" or "CHAT_MSG_PARTY" or "CHAT_MSG_RAID" or
