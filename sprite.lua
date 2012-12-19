SPRITES_TO_DELETE = {}

function makeSpriteMap()
    for i=1,#mapProp.map do
        spriteMap[i] = 0
    end
    for i=1,#SPRITES do
        local sprite = SPRITES[i] 
        spriteMap[(indexFromCoordinates(sprite.x,sprite.y))] = 1
    end
end

function renderSprites()
    local floor = math.floor

    for i=1,#SPRITES do
        local isHit = false
        local sprite = SPRITES[i]
        sprite.wallPositionX = floor(sprite.x)
        sprite.wallPositionY = floor(sprite.y)
        if (sprite.visible) then 
            if (sprite.hit) then
                isHit = true
            end

            local dy = sprite.y - player.y -- These two had + 0.5 to fix upside down sprites..
            local dx = sprite.x - player.x
            
            local dist = math.sqrt(dx*dx + dy*dy)
            local spriteAngle = math.atan2(dy, dx) - player.rot

            local spriteSize = viewDist / (math.cos(spriteAngle) * dist)
            
            local spriteX = math.tan(spriteAngle) * viewDist
            local top = (screenHeight - spriteSize)/2
            local left = (screenWidth/2 + spriteX - spriteSize/2)
            local dbx = sprite.x - player.x
            local dby = sprite.y - player.y
            local blockDist = dbx*dbx + dby*dby
            local z = -floor(dist*10000)
            --love.graphics.drawq(harrisImg,SPRITEQUAD[0],left,top,0,spriteSize/mapProp.tileSize,spriteSize/mapProp.tileSize)
            drawCalls[#drawCalls+1] = 
            { 
                z = z,
                x = left,
                y = top,
                dist = dist,
                sx = spriteSize / mapProp.tileSize,
                sy = spriteSize / 64,
                quad = SPRITEQUAD[sprite.img][sprite.state],
                hit = isHit
            }
            sprite.visible = false 
       end
    end
end

function handleSpriteHit(sprite)
    if (sprite.img == 1 and sprite.state == 0) then
        return
    end
    sprite.hit = true
    sprite.health = sprite.health - 1
end

function addSpriteToMap(index)
    local posX = positionXFromArrayIndex(index) 
    local posY = positionYFromArrayIndex(index) 
    
    local rand = math.random(1,3)
    rand = 4

    local action = {
        [1] = function (x) addSnowman(posX,posY) end,
        [2] = function (x) addElf(posX,posY) end,
        [3] = function (x) addNutCracker(posX,posY) end,
        [4] = function (x) addFrosty(posX,posY) end
    }

    action[rand]()
end

function areEnemiesDead()
    return (#SPRITES == 0) 
end

function deleteDeadSprites()
    if (#SPRITES_TO_DELETE > 0) then
        for i,v in ipairs(SPRITES_TO_DELETE) do
            table.remove(SPRITES,SPRITES_TO_DELETE[i])
        end
        SPRITES_TO_DELETE = {}
    end
    if (#SPRITES == 0) then
        unlockAllDoors()
    end
end

function addSnowman(x,y)
    local spriteIndex = #SPRITES + 1 
    SPRITES[spriteIndex] = {
            id = spriteIndex,
            x = x,
            y = y,
            img = 5,
            visible = false,
            block = true,
            speed = 0,
            dir = 0,
            rot = 0,

            bulletSpeed = 4.5,
            playerVisible = false,
            visiblityRange = 5,

            rotate = true,
            rotationDirection = 0,
            rotationAngle = 20,
            rotateDelay = 3,
            rotateDelayMax = 3,

            maxFireRate = 3,
            fireRate = math.random(2.9,7),

            health = 4,
            hit = false,
            hitPause = 0.1,

            moveSpeed = 0.05,
            rotSpeed = 3,
            totalStates = 12,
            state = 0,
            wallPositionX = 0,
            wallPositionY = 0,
            objType = "sprite",
            frameTimer = 0,
            walkAnimationSpeed = 5
        }
end

function addFrosty(x,y)
    local spriteIndex = #SPRITES + 1 
    SPRITES[spriteIndex] = {
            id = spriteIndex,
            x = x,
            y = y,
            img = 3,
            visible = false,
            block = true,
            speed = 0,
            dir = 0,
            rot = 0,

            bulletSpeed = 6.5,
            bulletImg = 1,
            bulletSplash = 2,
            playerVisible = false,
            visiblityRange = 5,

            rotate = false,
            rotationDirection = 0,
            rotationAngle = 20,
            rotateDelay = 3,
            rotateDelayMax = 3,

            maxFireRate = 0.5,
            fireRate = math.random(2.9,7),

            health = 4,
            hit = false,
            hitPause = 0.1,

            moveSpeed = 0.09,
            rotSpeed = 3,
            totalStates = 12,
            state = 0,
            wallPositionX = 0,
            wallPositionY = 0,
            objType = "sprite",
            frameTimer = 0,
            walkAnimationSpeed = 5
        }
end

function addElf(x,y)
    local spriteIndex = #SPRITES + 1 
    SPRITES[spriteIndex] = {
            id = spriteIndex,
            x = x,
            y = y,
            img = 0,
            visible = false,
            block = true,
            speed = 0,
            dir = 0,
            rot = 0,


            bulletImg = 3,
            bulletSpeed = 4.5,
            playerVisible = false,
            visiblityRange = 5,


            maxFireRate = 1.5,
            fireRate = math.random(7),

            health = 3,
            hit = false,
            hitPause = 0.1,

            moveSpeed = 0.05,
            rotSpeed = 3,
            totalStates = 12,
            state = 0,
            wallPositionX = 0,
            wallPositionY = 0,
            objType = "sprite",
            frameTimer = 0,
            walkAnimationSpeed = 5
        }
end

function addNutCracker(x,y)
    local spriteIndex = #SPRITES + 1 
    SPRITES[spriteIndex] = {
            id = spriteIndex,
            x = x,
            y = y,
            img = 1,
            visible = false,
            block = true,
            speed = 0,
            dir = 0,
            rot = 0,


            bulletSpeed = 4.5,
            playerVisible = false,
            visiblityRange = 15,


            maxFireRate = 1.5,
            fireRate = math.random(7),

            health = 3,
            hit = false,
            hitPause = 0.1,

            moveSpeed = 0.05,
            rotSpeed = 3,
            totalStates = 12,
            state = 0,
            wallPositionX = 0,
            wallPositionY = 0,
            objType = "sprite",
            frameTimer = 0,
            walkAnimationSpeed = 5
        }
end
