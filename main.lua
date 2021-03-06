require "globals"
require "player"
require "raycast"
require "controls"
require "util"
require "map"
require "sprite"
require "ai"
require "bullets"
require "decals"
require "mapgenerator"
require "roomgenerator"
require "hud"
require "menu"
require "items"
require "intro"


function love.draw()
    if (mainMenuDisplaying) then
        drawMenu()
    elseif (gamePaused) then
        drawPauseMenu()
    elseif (sceneChange and fadeAmount > 255) then
        drawSceneChange()
    elseif (gameRunning) then
        drawGame()
    end
    
    if (introDisplaying) then
        drawIntro()
    end

    if (fading) then
        fadeToBlack()
    end
end

function love.update(dt)
    if (gameRunning and not (gamePaused)) then
        if (player.health >= -0.5) then
            move(player, dt)
            firePlayerWeapon(dt)
        elseif (player.dead == nil or player.dead == false) then
            player.dead = true 
            fadeToBlackSetup()
        end 

        ai(dt)
        manageBullets(dt)
        manageDecals(dt)

        deleteDeadSprites()
    end
    if (mainMenuDisplaying) then
        menuButtonHover()
        p:update(dt)
        q:update(dt)
--        particleTimer(dt) 
    end
    if (gamePaused) then
        menuButtonHover()
    end

    if (introDisplaying) then
        introManagement(dt)
    end

    if (sceneChange) then
        
    end
end

function love.load()

    mainMenuDisplaying = true 
    introDisplaying = true
    gameRunning = false 
    sceneChange = false
    
    loadMainMenu()
    mainMenuMusic = love.audio.newSource("jinglemusic.ogg")
    
    love.graphics.setColorMode("modulate")
    love.graphics.setMode(640,480, true, false)

    love.mouse.setVisible(true)
--    love.mouse.setPosition(screenWidth/2,screenHeight/2)
--    love.mouse.setGrab(true)

    snowImg = love.graphics.newImage("snow.png")
    cashImg = love.graphics.newImage("cash.png")
    setupParticles()
end

function setupParticles(image, life)
  p = love.graphics.newParticleSystem(snowImg, 10000)
  p:setEmissionRate          (50)
  p:setLifetime              (-1) 
  p:setParticleLife          (30) 
  p:setPosition              (50, 50) 
  p:setDirection             (0) 
  p:setSpread                (0) 
  p:setSpeed                 (-60, 60) 
  p:setSpin                  (2) 
  p:setGravity               (10)
  p:setRadialAcceleration    (1)
  p:setTangentialAcceleration(2)
  p:setSizes                 (1,2,0.5,0.2,0.05,0.01)
  p:setSizeVariation         (1,130)
  p:setRotation              (0) 
  p:setSpinVariation(1) 
  p:stop()
  p:start()
  q = love.graphics.newParticleSystem(cashImg, 10000)
  q:setEmissionRate          (50)
  q:setLifetime              (-1) 
  q:setParticleLife          (60) 
  q:setPosition              (50, 50) 
  q:setDirection             (0) 
  q:setSpread                (0) 
  q:setSpeed                 (-60, 60) 
  q:setSpin                  (2) 
  q:setGravity               (10)
  q:setRadialAcceleration    (1)
  q:setTangentialAcceleration(2)
  q:setSizes                 (1,2,0.5,0.2,0.05,0.01)
  q:setSizeVariation         (1,130)
  q:setRotation              (0) 
  q:setSpinVariation(1) 
  q:stop()
  q:start()
end

function drawGame()
    local level = LEVELS[player.level]
    level.floor()
    love.graphics.rectangle( "fill",
     0,screenHeight/2,screenWidth,screenHeight/2
    )
    level.ceiling()
    love.graphics.rectangle( "fill",
     0,0,screenWidth,screenHeight/2
    )

    spriteBatch:clear()
    drawCalls = {}
    castRays()
    renderSprites()
    renderDecals()
    renderBullets()
    renderItems()
    sort(drawCalls)    

 --   drawBackground()

    for i = 1, #drawCalls do
        local strip = drawCalls[i]
--        local light = 1 - (strip.dist/20) 
--        if (light < 0) then light = 0 end
--        spriteBatch:setColor(255,255,255,255*light) 
--        print ("Quad: " .. tostring(strip.quad) .. "StripX: " .. tostring(strip.x) .. "StripY: " .. tostring(strip.y) .. "StripSX: " .. tostring(strip.sx) .. "StripSY: " .. tostring(strip.sy))
        if (strip.isSpecial) then
            spriteBatch:setColor( 50, 50, 50, 255)
        end
        if (strip.hit) then
            spriteBatch:setColor( 255, 0, 0, 255)
        end
--        spriteBatch:setColor( 255/strip.dist, 255/strip.dist, 255/strip.dist, 255)
        if (strip.quad) then
        --        spriteBatch:addq(strip.quad,strip.x+10,strip.y+20,0,strip.sx,strip.sy)
                spriteBatch:addq(strip.quad,strip.x,strip.y,0,strip.sx,strip.sy)
        end
        spriteBatch:setColor()
--        love.graphics.setColor(255,255,255,255*light)
--        love.graphics.drawq(wallsImgs,strip.quad,strip.x,strip.y,0,strip.sx,strip.sy)
    end

    spriteBatch:setColor( 255, 255, 255, 255)
    love.graphics.draw(spriteBatch)

    if (player.hit) then
        player.hitDecay = player.hitDecay - 1
        love.graphics.setColor(255,255,255,55)
        love.graphics.draw(hitImg,0,0,0,15,12)
        if (player.hitDecay < 0) then
            player.hitDecay = 10
            player.hit = false
        end
    end

--    if (mapProp.displayMap) then drawMiniMap() end
--    if (displayDebug) then drawDebug() end
    drawHud()
--    drawDebug()
end

function startGame()
    SPRITES = {}
 --   gamePaused = false
    loadPauseMenu()
    --loadMapFromDisk("map01.lua")
    --setPlayerSpawnPoint()
   
    wallsImgs = love.graphics.newImage("images.png")
    miniMapImgs = love.graphics.newImage("minimap.png")
    itemsImgs = love.graphics.newImage("items.png")
--    bgImg = love.graphics.newImage("bg.png")
    hitImg = love.graphics.newImage("hit.png")
    local imagesPerHeight = (wallsImgs:getHeight()/mapProp.tileSize)
    local imagesPerWidth = (wallsImgs:getWidth()/mapProp.tileSize)
    local itemsPerHeight = (itemsImgs:getHeight()/mapProp.tileSize)
    local itemsPerWidth = (itemsImgs:getWidth()/mapProp.tileSize)
    spriteBatch = love.graphics.newSpriteBatch( wallsImgs, 9000)
    mapSpriteBatch = love.graphics.newSpriteBatch(miniMapImgs, 100)
    setQuads(imagesPerHeight,imagesPerWidth,itemsPerHeight,itemsPerWidth)

    makeSpriteMap()
    loadHud()
    loadAudio() 



    fadeToBlackSetup()
--    changeLevel()
    
    mainMenuDisplaying = false
--    gameRunning = true

    love.mouse.setVisible(false)
    love.mouse.setPosition(screenWidth/2,screenHeight/2)
    love.mouse.setGrab(true)
end


function loadAudio()
    soundShoot = love.audio.newSource("shoot.ogg", "static")
    soundHit1 = love.audio.newSource("hit1.ogg", "static")
    ncAttack = love.audio.newSource("bite.ogg", "static")
    ncWalk = love.audio.newSource("ncwalk.ogg", "static")
    eAttack = love.audio.newSource("etoss.ogg", "static")
    jackHit = love.audio.newSource("jackhit.ogg", "static")
    jackLand = love.audio.newSource("jackland.ogg", "static")
    pickup = love.audio.newSource("pickup.ogg", "static")
    doorOpen = love.audio.newSource("dooropen.ogg", "static")
    doorClose = love.audio.newSource("doorclose.ogg", "static")

    jackIntro = love.audio.newSource("jackintro.ogg", "static")

    bossMusic = love.audio.newSource("bossmusic.ogg", "static")
    level1Music = love.audio.newSource("level1music.ogg", "static")
    level2Music = love.audio.newSource("level2music.ogg", "static")
    level3Music = love.audio.newSource("level3music.ogg", "static")
end
