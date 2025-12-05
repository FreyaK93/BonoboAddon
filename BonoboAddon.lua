-- BonoboAddon.lua

local f = CreateFrame("Frame")

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_RAID_WARNING")
f:RegisterEvent("CHAT_MSG_SAY")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("CHAT_MSG_SYSTEM")

-- rembember to check your gear and talents

------------------------------------------------------------
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
    end
end)
