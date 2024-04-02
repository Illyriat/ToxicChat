-- Messaging Alerts:
--                  Displays when the player enters and exits combat.
--                  Displays when the player enters and exits the water.
--                  Displays when the player mounts and dismounts.


ToxicChat = {}
ToxicChat.name = "ToxicChat"


function ToxicChat.RestorePosition()
    local left = ToxicChat.savedVariables.left
    local top = ToxicChat.savedVariables.top

    ToxicChatIndicator:ClearAnchors()
    ToxicChatIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- ##############################
-- Initializer
-- Registering Events for each function that needs to be
function ToxicChat.Initialize()
    ToxicChat.inCombat = IsUnitInCombat("player")
    ToxicChat.isSwimming = IsUnitSwimming("player")
    ToxicChat.isNotSwimming = not IsUnitSwimming("player")     -- Initialize not swimming state
    ToxicChat.IsMounted = IsMounted("player")
    ToxicChat.OnPlayerLocation = GetPlayerLocationName("player")

    EVENT_MANAGER:RegisterForEvent(ToxicChat.name, EVENT_PLAYER_COMBAT_STATE, ToxicChat.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ToxicChat.name, EVENT_PLAYER_SWIMMING, ToxicChat.OnPlayerEnteredSwimming)
    EVENT_MANAGER:RegisterForEvent(ToxicChat.name, EVENT_PLAYER_NOT_SWIMMING, ToxicChat.OnPlayerExitedSwimming)     -- Register for exiting swimming event
    EVENT_MANAGER:RegisterForEvent(ToxicChat.name, EVENT_MOUNTED_STATE_CHANGED, ToxicChat.OnPlayerMountState)
    EVENT_MANAGER:RegisterForEvent(ToxicChat.name, ToxicChat.OnPlayerLocation)


    ToxicChat.savedVariables = ZO_SavedVars:NewAccountWide("ToxicChatSavedVariables", 1, GetWorldName(), {})

    ToxicChat.RestorePosition()

    -- Periodically check the swimming state
    zo_callLater(function()
        local isSwimming = IsUnitSwimming("player")
        ToxicChat.OnPlayerSwimmingState(nil, isSwimming)     -- Call the function manually to handle initial state
        zo_callLater(ToxicChat.Initialize, 1000)             -- Repeat every 1 second
    end, 1000)
end

-- ##############################
function ToxicChat.OnIndicatorMoveStop()
    ToxicChat.savedVariables.left = ToxicChatIndicator:GetLeft()
    ToxicChat.savedVariables.top = ToxicChatIndicator:GetTop()
end

-- ##############################
-- ENTERING AND EXITING COMBAT HANDLERS
-- ##############################
-- Check to see if player is in combat
function ToxicChat.OnPlayerCombatState(event, inCombat)
    if inCombat ~= ToxicChat.inCombat then
        ToxicChat.inCombat = inCombat

        if inCombat then
            d("Entering Combat...")
        else
            d("Exiting Combat...")
        end
        ToxicChat.Indicator:SetHidden(not inCombat)
    end
end

-- ##############################
-- SWIMMING HANDLER
-- ##############################
-- Handler for entering swimming state
-- Display a random message based on a 1 in 5 chance. Added to reduce message spamming
function ToxicChat.OnPlayerEnteredSwimming(event, isSwimming)
    local enteringMessages = {
        "Taking a dip...?",
        "Splish Splash, I was taking a bath.",
        "Enjoying the water!",
        "Swimming time!",
        "You won't find Volendrung there...."
    }
    local maxIndex = math.floor(#enteringMessages * 0.2)
    local randomIndex = math.random(1, #enteringMessages)
    local message = enteringMessages[randomIndex]
    d(message)
    ToxicChat.isSwimming = true
end

-- Handler for exiting swimming state
function ToxicChat.OnPlayerExitedSwimming(event, isNotSwimming)
    local exitingMessages = {
        "Leaving the water...",
        "Back on dry land...",
        "That was refreshing!",
        "Time to dry off..."
    }
    local maxIndex = math.floor(#exitingMessages * 0.2)
    local randomIndex = math.random(1, #exitingMessages)
    local message = exitingMessages[randomIndex]
    d(message)
    ToxicChat.isSwimming = false
end

-- ##############################
-- ##############################


-- ##############################
-- MOUNTING AND DISMOUNTING HANDLERS
-- ##############################
-- Check the changed mount state of the player
-- Display a random message based on a 1 in 5 chance. Added to reduce message spamming
function ToxicChat.OnPlayerMountState(event, IsMounted)
    if IsMounted ~= ToxicChat.IsMounted then
        ToxicChat.IsMounted = IsMounted
        -- Mounted Random messages and execution
        local mountedMessages ={
            "Giddy Up Horsey!",
            "Ridin' Dead Horses!",
            "I've been through the desert on a horse with no name, it felt good to be out of the rain...",

        }
        local maxIndex = math.floor(#mountedMessages * 0.2)
        local randomIndex = math.random(1, #mountedMessages)
        local isMountedMessage = mountedMessages[randomIndex]

        -- Not Mounted Random messages and execution.
        local notMountedMessages = {
            "You`re not a rider unless you`ve fallen off seven times.",
            "Did you fall again?",
            "Need to get that saddle seen too."
        }
        local maxIndex = math.floor(#notMountedMessages * 0.2)
        local randomIndex = math.random(1, #notMountedMessages)
        local isNotMounted = notMountedMessages[randomIndex]

        if IsMounted then
            d(isMountedMessage)
        else
            d(isNotMounted)
        end
    end
end

-- ##############################
-- ##############################


-- ##############################
-- ##############################
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function ToxicChat.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == ToxicChat.name then
        ToxicChat.Initialize()
        --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
        EVENT_MANAGER:UnregisterForEvent(ToxicChat.name, EVENT_ADD_ON_LOADED)
    end
end

-- ##############################
-- ##############################
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name
-->within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(ToxicChat.name, EVENT_ADD_ON_LOADED, ToxicChat.OnAddOnLoaded)
