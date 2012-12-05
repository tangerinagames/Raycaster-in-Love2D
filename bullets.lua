function manageBullets(dt)                                                         
    for i,v in ipairs(bullets) do                                                  
        v["x"] = v["x"] + (v["dx"] * dt)                                           
        v["y"] = v["y"] + (v["dy"] * dt)                                           
        if (isBlocking(v, v["x"], v["y"])) then
            table.remove(bullets,i)
        end
    end                                                                            
end  

function renderBullets()
    local sqrt = math.sqrt
    local atan2 = math.atan2
    local cos = math.cos
    local tan = math.tan
    local floor = math.floor
    local plyr = player
    local vDist = viewDist
    local scrHeight = screenHeight
    local scrWidth = screenWidth 
    local mTileSize = mapProp.tileSize
    
    for i,v in ipairs(bullets) do
        v["bulletWallPositionX"] = floor(v["x"])
        v["bulletWallPositionY"] = floor(v["y"])

        if (v["visible"] == true) then
            local dx = v["x"] - plyr.x
            local dy = v["y"] - plyr.y

            local dist = sqrt(dx*dx + dy*dy)
            local spriteAngle = atan2(dy, dx) - plyr.rot
            local spriteSize = vDist / (cos(spriteAngle) * dist)

            local spriteX = tan(spriteAngle) * vDist                           
            local top = (scrHeight - spriteSize)/2                                  
            local left = (scrWidth/2 + spriteX - spriteSize/2)                      
            local z = -floor(dist*10000)  
        
            drawCalls[#drawCalls+1] =                                              
            {                                                                      
                z = z,                                                             
                x = left,
                y = top,                                                           
                dist = dist,                                                       
                sx = spriteSize / mTileSize,                                
                sy = spriteSize / 64,                                              
                quad = SPRITEQUAD[1][1]                        
            }

            v["visible"] = false
        end
    end
end