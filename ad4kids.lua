--==========================================================--
-- Ad4Kids module for Corona SDK
-- Developed by © Braulio Martínez Rosillo / Toca Toca G&A 2013.
-- Granada, Spain.
-- 
-- USAGE INSTRUCTIONS:
--
--      1 - Require the module using:
--                  ad4kids = require( "ad4kids" )
--
--      2 - Initialize the module using: 
--                  ad4kids.init( "YOUR_APP_ID_HERE" )
--
--      3 - Show ads using: 
--                  ad4kids.showAd()
--==========================================================--

-- ==================================== --
--         MODULE'S DECLARATION
-- ==================================== --
local ad4kids = {}

-- ==================================== --
--           REQUIRED MODULES
-- ==================================== --
local crypto = require( "crypto" )

-- ==================================== --
--              LOCAL VARS
-- ==================================== --
local adInitialized = false
local showingAd     = false
local kidsSafeLocal = false
local appID         = 0
local clickURL      = ""
local impressURL    = ""

-- ==================================== --
--           DISPLAY OBJECTS
-- ==================================== --

local adGroup = display.newGroup() -- This group will be allways on top

local blackBackground = display.newRect( adGroup, display.screenOriginX, display.screenOriginY, display.pixelWidth, display.pixelHeight )
      blackBackground.alpha = 0
      blackBackground:setFillColor( 0, 0, 0 )

local closeGroup = display.newGroup()
      adGroup:insert( closeGroup )
      closeGroup.close = true
      closeGroup.alpha = 0

local blackBackground2 = display.newRect( closeGroup, 35, 35, 250, 410 )
      blackBackground2.alpha = 1
      blackBackground2:setFillColor( 255, 255, 255 )

local close = display.newCircle( closeGroup, display.contentWidth - 30, 30, 16 )
      close.strokeWidth = 5
      close:setFillColor( 200, 0, 0 )
      close:setStrokeColor( 0, 0, 0 )

local close2 = display.newCircle( closeGroup, display.contentWidth - 30, 30, 16 )
      close2.strokeWidth = 3 
      close2:setFillColor( 200, 0, 0 )
      close2:setStrokeColor( 255, 255, 255 )

local linea1 = display.newLine( closeGroup, display.contentWidth - 35, 35, display.contentWidth - 25 , 25 )
      linea1:setColor( 255, 255, 255 )

local linea2 = display.newLine( closeGroup, display.contentWidth - 25, 35, display.contentWidth - 35 , 25 )
      linea2:setColor( 255, 255, 255 )



-- ==================================== --
--               FUNCTIONS
-- ==================================== --

-- ------------------------------------
local function collectData() -- Fills the "paramsData" var with propper values 
-- ------------------------------------
    
    -- Retrieve all the data -- 
    -- ------------------------------------
    local function getManufacturer()
    -- ------------------------------------
        local deviceManufacturer = "Apple"
        if system.getInfo( "platformName" ) == "Android" then deviceManufacturer = "Android" end
        
        return deviceManufacturer
    -- ------------------------------------
    end
    -- ------------------------------------

    -- ------------------------------------
    local function getUniqueID()
    -- ------------------------------------
        local uniqueID = "dummy"
        -- If we're on the real device
        if system.getInfo( "environment" ) == "device" then
            -- Get the Android ID
            if system.getInfo( "platformName" ) == "Android" then 
                uniqueID = system.getInfo( "deviceID" )
            -- Get the iOS ID
            elseif system.getInfo( "platformName" ) == "iPhone OS" then
                local iosVer = tonumber( system.getInfo( "platformVersion" ) )
                if iosVer >= 6 then  -- If we're on iOS 6, use the new Apple's adversiting identifier
                    uniqueID = system.getInfo( "iosAdvertisingIdentifier" )
                else
                    uniqueID = system.getInfo( "deviceID" )
                end
            end
        end

        return uniqueID
    -- ------------------------------------
    end
    -- ------------------------------------

    -- Fill vars --
    local language   = string.sub( system.getPreference( "ui", "language" ), 1, 2 )
    local country_id = system.getPreference( "locale", "country" )
    local deviceModel = system.getInfo( "model" )
    local deviceManufacturer = getManufacturer()
    local nv = "dummy"
    local udid = getUniqueID()
          -- If we're on Android, encrypt the udid with sha1
          if system.getInfo( "platformName" ) == "Android" then udid = "sha:" .. crypto.digest( crypto.sha1, getUniqueID() ) end
    local idMD5 = crypto.digest( crypto.md5, getUniqueID() )
    local conex_speed = "dummy"
    local ua = "Corona"
    local av = "Corona" .. system.getInfo( "build" )
    local sc_a = "dummy"
    local nv = "dummy"
    local o = string.sub( system.orientation, 1, 1 )
    local v = "6"

    -- Construct the string --
    local paramsData = "&language="..language.."&country_id="..country_id.."&deviceModel="..deviceModel.."&deviceManufacturer="..deviceManufacturer.."&nv="..nv.."&udid="..udid.."&idMD5="..idMD5.."&conex_speed="..conex_speed.."&ua="..ua.."&av="..av.."&sc_a="..sc_a.."&nv="..nv.."&o="..o.."&v="..v
    
    return paramsData
-- ------------------------------------
end
-- ------------------------------------

-- ------------------------------------
local function newSession()
-- ------------------------------------
    local paramsData = collectData()
    local body = "app_api_id="..appID.."&action=new_session"..paramsData
    print("El cuerpo de la llamada es " .. body )
    local params = {}
          params.body = body
    local URL = "http://api.ad4kids.com"
          network.request( URL, "POST", function() print( "New session" ) end, params )
-- ------------------------------------
end
-- ------------------------------------

-- ------------------------------------
local function impression()
-- ------------------------------------
    local paramsData = collectData()
    local body = paramsData
    local params = {}
          params.body = impressURL .. body
          print( "El cuerpo de la llamada es " .. params.body )
    local URL = "http://api.ad4kids.com"
          network.request( URL, "POST", function() print( "New Impression" ) end, params )
-- ------------------------------------
end
-- ------------------------------------

-- ------------------------------------
local function clickAd()
-- ------------------------------------
    local paramsData = collectData()
    local body = paramsData
    local params = {}
          params.body = clickURL .. body
          print( "El cuerpo de la llamada es " .. params.body )
    local URL = "http://api.ad4kids.com"
          network.request( URL, "POST", function( event ) print( "New CLICK" ) end, params )
-- ------------------------------------
end
-- ------------------------------------


-- ------------------------------------
local function doNothing( event )
-- ------------------------------------
    print("Doing nothing")
    return true
-- ------------------------------------
end
-- ------------------------------------

-- ------------------------------------
local function downloadSealSafe( event )
-- ------------------------------------
    local function imageListener( event )
        if event.response then
            if event.response.filename == "kidsSafe.png" then
                kidsSafeLocal = true
            end
        end
    end

    network.download( "http://api.ad4kids.com/resources/Seal_sharp_150wide_tm.png", "GET", imageListener, "kidsSafe.png", system.TemporaryDirectory )
-- ------------------------------------
end
-- ------------------------------------


-- ------------------------------------
local function displayAd( adUrl, adImgUrl, imgName, certified ) -- Show the ads
-- ------------------------------------
    print( adUrl )
    print( adImgUrl )
    print( imgName )
    print( certified )

    local function imageListener( event )

        if event.isError then
            print("No hay internet")
        else
            showingAd = true
            local safeSeal

            if certified then
                if kidsSafeLocal then
                      safeSeal = display.newImageRect( adGroup, "kidsSafe.png", system.TemporaryDirectory, 75, 31.5 )
                else
                    downloadSealSafe()
                end
            end

            local adImg = display.newImageRect( adGroup, imgName, system.TemporaryDirectory, 480, 800 )

            local function remove( event )
                display.remove( event )
                event = nil
            end

            local function closeAd()
                showingAd = false
                transition.to( blackBackground, { alpha = 0, time = 350 } )
                transition.to( closeGroup, { x = -1 * display.pixelWidth, alpha = 0, time = 400, transition = easing.inExpo } )
                return true
            end

            local function adReaction( event )
                clickAd( adUrl )
                system.openURL( adUrl ) 
                print( adUrl )
                closeAd()
                return true
            end

            impression( )
            transition.to( blackBackground, { alpha = 0.5, time = 150 } )
            adGroup:insert( adImg )
            adImg.alpha = 1
            adImg.xScale = 0.5
            adImg.yScale = 0.5
            adImg.x = display.contentWidth * 0.5
            adImg.y = display.contentHeight * 0.5
            if safeSeal then
                safeSeal.x = display.contentWidth * 0.5 + 90
                safeSeal.y = display.contentHeight * 0.5 + 190
            end
            closeGroup.x = -5
            closeGroup.y = 5
            closeGroup.alpha = 1
            adGroup:insert( closeGroup )
            closeGroup:insert( adImg )
            if safeSeal then
                closeGroup:insert( safeSeal )
            end
            closeGroup:insert( close )
            closeGroup:insert( close2 )
            closeGroup:insert( linea1 )
            closeGroup:insert( linea2 )
            transition.from( closeGroup,   { x = display.pixelWidth, alpha = 0, time = 600, transition = easing.outExpo } )
            adImg:addEventListener( "tap", adReaction )            
            close:addEventListener( "tap", closeAd )
        end
    end

    -- 
    local pathImg = system.pathForFile( imgName, system.TemporaryDirectory )
    local imgFile = io.open( pathImg, "r" )
    if not imgFile then
        network.download( adImgUrl, "GET", imageListener, imgName, system.TemporaryDirectory )
    else
        local event = {}
        imageListener( event )
    end
-- ------------------------------------
end
-- ------------------------------------


-- ------------------------------------
local function networkListener( event ) -- Manage the network request and interpret the HTML response
-- ------------------------------------
	if event.isError then
		print( "Server error or no Internet connection. Mensaje: " .. event.errorMessage )
        print( "La respuesta del servidor es...")
        print( event.response )
	elseif event.response then

        -- What is the ad URL?
        local anuncio = tostring( event.response )
        local start, ending = string.find( anuncio, "<a id='ad' " )
        local adUrlStart, adUrlEnding = string.find( anuncio, '"', ending + 7 )
        local adUrl = string.sub( anuncio, ending + 7, adUrlEnding - 1 )--, adUrlEnding )

        -- What is the ad image URL?
        local startImg, endImg = string.find( anuncio, "<img src=" )
        local discard, endUrlImg = string.find( anuncio, '"', endImg + 2 )
        local imgUrl = string.sub( anuncio, endImg + 2, endUrlImg - 1 )

        local imgName
        local isTest = string.find( imgUrl, "test" )
        
        if isTest == nil then
            print( "RESPUESTA HTML ES " .. event.response )
            clickURL   = string.sub( event.responseHeaders["X-Clickthrough"], 32 )
            impressURL = string.sub( event.responseHeaders["X-Imptracker"], 32 )
            print( "LLAMAMOS A ".. clickURL )
            print( "IMPRIMIMOS EN ".. impressURL )
        end
        

        -- Is the ad certified with the kids-safe seal?
        local certified = false
        local kidsSafe = string.find( anuncio, 'seal' )
        if kidsSafe then certified = true end

        -- Once we have the ad image & url, show the ad
        if isTest then imgUrl = "http://api.ad4kids.com/resources/test-ad.png" imgName = "test-ad.png" 
        else imgName = string.sub( imgUrl, 64 )
        end
        
        print("La imagen es " .. imgName )
        displayAd( adUrl, imgUrl, imgName, certified )

	end
-- ------------------------------------
end
-- ------------------------------------


-- ------------------------------------
ad4kids.init = function( id )
-- ------------------------------------
    appID = tostring( id )

    if appID == 0 then
        print( "Please call 'init()' function introducing an appID" )
    else
        -- If is the first installation, we need to initialize the system
        local path = system.pathForFile( "a4k.txt", system.DocumentsDirectory )
        local file = io.open( path, "r" )
        if not file then
            -- If the first installation is succesful, create the file
            local function networkListenerInit( event )
                if event.response then
                    print( "First installation of ad4kids succesfully done" )
                    file = io.open( path, "w" )
                    file:write( "1" )
                    io.close( file )
                    newSession()
                    adInitialized = true
                end
            end
            -- Create the network call
            local paramData = collectData()
            local body = "v=6&cnv=1&app_api_id="..appID.."&action=new_session"..paramData
            local params = {}
                  params.body = body
            local URL = "http://api.ad4kids.com"
            -- Perform the call
            network.request( URL, "POST", networkListenerInit, params)
        else
            newSession()
            adInitialized = true
        end
    end
-- ------------------------------------
end
-- ------------------------------------


-- ------------------------------------
ad4kids.showAd = function()
-- ------------------------------------
    if not showingAd then
        local paramsData = collectData()
        local body = "app_api_id="..appID.."&action=request_an_ad"..paramsData
        print("El cuerpo de la llamada es " .. body )
        local params = {}
              params.body = body
        local URL = "http://api.ad4kids.com"
              network.request( URL, "POST", networkListener, params )
    else
        print( "Already showing an ad" )
    end
-- ------------------------------------
end
-- ------------------------------------


-- This function allows the ads to stay always on top of the screen (except for native UI elements)
-- ------------------------------------
local function alwaysUp()
-- ------------------------------------
    parent = adGroup.parent
    parent:insert( adGroup )
-- ------------------------------------
end
-- ------------------------------------


-- ------------------------------------
local function checkSealSafeLocal()
-- ------------------------------------
    local pathImg = system.pathForFile( "kidsSafe.png", system.TemporaryDirectory )
    local imgFile = io.open( pathImg, "r" )
    if not imgFile then
        downloadSealSafe()
    else
        kidsSafeLocal = true
    end
-- ------------------------------------
end
-- ------------------------------------
checkSealSafeLocal()

-- ==================================== --
--           EVENT LISTENERS
-- ==================================== --
Runtime:addEventListener( "enterFrame", alwaysUp )
blackBackground:addEventListener( "tap",   doNothing )
blackBackground:addEventListener( "touch", doNothing )


return ad4kids