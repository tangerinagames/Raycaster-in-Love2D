MAPGEN_MAP = {}
MAPGEN_ROOMS = {}
MAPGEN_MAPSIZE = 0 

function createEmptyMapWithSize(size)
    size = size * size
    MAPGEN_MAPSIZE = size
    for i=0,size do
        MAPGEN_MAP[i] = 0
    end
end 

function setSpawnRoom()
    mapSize = #MAPGEN_MAP-1
    sRoom = mapSize / 2
    MAPGEN_MAP[sRoom] = 1
    return sRoom
end

function printGeneratedMap()
    local mapstring = ""
    local current = getCurrentRoomCoordinates()
    for i=0,math.sqrt(MAPGEN_MAPSIZE)-1 do
        mapstring = ""
        for j=0,math.sqrt(MAPGEN_MAPSIZE)-1 do
            if (i == current.y and j == current.x) then
                mapstring = mapstring .. "X" 
            else
                local index = mapGenIndexFromCoordinates(j,i)
                mapstring = mapstring .. tostring(MAPGEN_MAP[index])
            end
        end
        print (mapstring)
    end
end


function generateMap()
    createEmptyMapWithSize(25)
    local spawn = setSpawnRoom()

--    local index = mapGenIndexFromCoordinates(5,5)
--    local x = mapGenPositionXFromArrayIndex(index)
--    local y = mapGenPositionYFromArrayIndex(index)
--
--    print (index .. "  " .. x .. "  " .. y)

    createRooms(55) 
    printGeneratedMap()

    local rm = createRoom(spawn)
    local doors = getDoorIndexes(rm)
    local spawnX = mapGenPositionXFromArrayIndex(spawn)
    local spawnY = mapGenPositionYFromArrayIndex(spawn)

    MAPGEN_ROOMS[spawn] = {
        room = rm,
        x = spawnX,
        y = spawnY,
        l = doors.l,
        r = doors.r,
        d = doors.d,
        u = doors.u
    }

    player.mapGenX = spawnX
    player.mapGenY = spawnY

    player.x = 5
    player.y = 5
    printGeneratedMap()
end

function mapGenManagement(dt)
    local currentRoomIndex = getCurrentRoomIndex()
    local currentRoomMapGenIndex = getMapGenRoomsArrayIndexFromIndex(currentRoomIndex)

    if (indexFromCoordinates(player.x,player.y) == MAPGEN_ROOMS[currentRoomIndex].u and
        doesRoomHaveTop(currentRoomIndex)) then

        local currentRoomX = mapGenPositionXFromArrayIndex(currentRoomIndex) 
        local currentRoomY = mapGenPositionYFromArrayIndex(currentRoomIndex) 
        local topRoomX = currentRoomX 
        local topRoomY = currentRoomY - 1 
        local topRoomIndex = mapGenIndexFromCoordinates(topRoomX,topRoomY)

        if (hasRoomIndexBeenMade(topRoomIndex)) then
            print ("Room has been made!")
            switchToRoom(topRoomIndex)
            currentRoomIndex = getCurrentRoomIndex()
            local newPlayerPositionIndex  = MAPGEN_ROOMS[currentRoomIndex].d
            player.x = positionXFromArrayIndex(newPlayerPositionIndex)+0.5 
            player.y = positionYFromArrayIndex(newPlayerPositionIndex)-1 
        else
            print ("Room has not been made!")
            makeRoomForMapGenRooms(topRoomIndex)
            currentRoomIndex = getCurrentRoomIndex()
            local newPlayerPositionIndex  = MAPGEN_ROOMS[currentRoomIndex].d
            player.x = positionXFromArrayIndex(newPlayerPositionIndex)+0.5 
            player.y = positionYFromArrayIndex(newPlayerPositionIndex)-1 
        end
        printGeneratedMap()
    end

    if (indexFromCoordinates(player.x,player.y) == MAPGEN_ROOMS[currentRoomIndex].d and
        doesRoomHaveBottom(currentRoomIndex)) then

        local currentRoomX = mapGenPositionXFromArrayIndex(currentRoomIndex) 
        local currentRoomY = mapGenPositionYFromArrayIndex(currentRoomIndex) 
        local bottomRoomX = currentRoomX 
        local bottomRoomY = currentRoomY + 1 
        local bottomRoomIndex = mapGenIndexFromCoordinates(bottomRoomX,bottomRoomY)

        if (hasRoomIndexBeenMade(bottomRoomIndex)) then
            switchToRoom(bottomRoomIndex)
            currentRoomIndex = getCurrentRoomIndex()
            local newPlayerPositionIndex  = MAPGEN_ROOMS[currentRoomIndex].u
            player.x = positionXFromArrayIndex(newPlayerPositionIndex)+0.5 
            player.y = positionYFromArrayIndex(newPlayerPositionIndex)+1 
        else
            makeRoomForMapGenRooms(bottomRoomIndex)
            currentRoomIndex = getCurrentRoomIndex()
            local newPlayerPositionIndex  = MAPGEN_ROOMS[bottomRoomIndex].u
            player.x = positionXFromArrayIndex(newPlayerPositionIndex)+0.5 
            player.y = positionYFromArrayIndex(newPlayerPositionIndex)+1 
        end
        printGeneratedMap()
    end
end

function switchToRoom(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)

    print ("THIS IS THE SWITCHED TO INDEX: " .. index)

    local room = MAPGEN_ROOMS[index].room
    loadMapFromRoom(room) 
    player.mapGenX = MAPGEN_ROOMS[index].x
    player.mapGenY = MAPGEN_ROOMS[index].y
end

function makeRoomForMapGenRooms(index)
        local rm = createRoom(index)
        local doors = getDoorIndexes(rm)

        MAPGEN_ROOMS[index]={
            room = rm,
            x = mapGenPositionXFromArrayIndex(index),
            y = mapGenPositionYFromArrayIndex(index),
            l = doors.l,
            r = doors.r,
            d = doors.d,
            u = doors.u
        }

        loadMapFromRoom(rm)
        player.mapGenX = MAPGEN_ROOMS[index].x
        player.mapGenY = MAPGEN_ROOMS[index].y
end

function getMapGenRoomsArrayIndexFromIndex(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)

    for i,v in ipairs(MAPGEN_ROOMS) do
        if (v["x"] == x and v["y"] == y) then
            return i
        end
    end
end


function hasRoomIndexBeenMade(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)

    if (MAPGEN_ROOMS[index] == nil) then
        return false
    end
    return true
end

function selectRandomRoom()
    local index = math.random(0, MAPGEN_MAPSIZE)
    return index 
end

function getCurrentRoomIndex()
    local pos = getCurrentRoomCoordinates()
    local index = mapGenIndexFromCoordinates(pos.x,pos.y)
    return index
end

function getCurrentRoomCoordinates()
   local pos = {
        x = player.mapGenX,
        y = player.mapGenY
    } 
    return pos
end

function numberOfRooms()
    local num = 0
    for i,v in ipairs(MAPGEN_MAP) do
        if (MAPGEN_MAP[i] > 0) then
            num = num + 1
        end
    end
    return num
end

function numberOfConnections(index)
    local roomX = mapGenPositionXFromArrayIndex(index)
    local roomY = mapGenPositionYFromArrayIndex(index)
    
    local numberOfConnections = 0

    local potentialRoomX = roomX
    local potentialRoomY = roomY - 1

    if (potentialRoomY > 0) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            numberOfConnections = numberOfConnections + 1
        end
    end

    potentialRoomY = roomY + 1
    
    if (potentialRoomY < math.sqrt(MAPGEN_MAPSIZE)) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            numberOfConnections = numberOfConnections + 1
        end
    end
    
    potentialRoomX = roomX+1
    potentialRoomY = roomY

    if (potentialRoomX < math.sqrt(MAPGEN_MAPSIZE)) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            numberOfConnections = numberOfConnections + 1
        end
    end
    
    potentialRoomX = roomX-1
    if (potentialRoomX > 0 and potentialRoomY > 0) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            numberOfConnections = numberOfConnections + 1
        end
    end

    return numberOfConnections 
end

function isNextToARoom(index)
    local roomX = mapGenPositionXFromArrayIndex(index)
    local roomY = mapGenPositionYFromArrayIndex(index)
    
    local potentialRoomX = roomX
    local potentialRoomY = roomY - 1

    if (potentialRoomY > 0) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            return true
        end
    end

    potentialRoomY = roomY + 1
    
    if (potentialRoomY < math.sqrt(MAPGEN_MAPSIZE)) then
        print (potentialRoomX .. "  " .. potentialRoomY)
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            return true
        end
    end
    
    potentialRoomX = roomX+1
    potentialRoomY = roomY

    if (potentialRoomX < math.sqrt(MAPGEN_MAPSIZE)) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            return true
        end
    end
    
    potentialRoomX = roomX-1
    if (potentialRoomX > 0 and potentialRoomY > 0) then
        if (MAPGEN_MAP[mapGenIndexFromCoordinates(potentialRoomX,potentialRoomY)] > 0) then
            return true
        end
    end

    return false
end

function createRooms(maxRooms)
    while (numberOfRooms() < maxRooms) do
        local index = selectRandomRoom()
        if (isNextToARoom(index) and MAPGEN_MAP[index] ~= 1) then
            if (numberOfConnections(index) < 2) then
                MAPGEN_MAP[index] = 2
            end
        end
    end
end

function mapGenIndexFromCoordinates(x,y) 
    index = 1 + (math.floor(y)*(math.sqrt(MAPGEN_MAPSIZE))) + (math.floor(x))
    return index
end

function mapGenPositionXFromArrayIndex(index)
    local x = (index % math.sqrt(MAPGEN_MAPSIZE))-1
    if (x==-1) then x = math.sqrt(MAPGEN_MAPSIZE)-1 end
    return x
end

function mapGenPositionYFromArrayIndex(index)
    local y = ((index-1) / math.sqrt(MAPGEN_MAPSIZE))
    y = math.floor(y)
    return y
end

function doesRoomHaveTop(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)
    local topRoomY = y - 1

    if (topRoomY < 0) then
        return false
    end

    local topRoom = mapGenIndexFromCoordinates(x,topRoomY)

    return (MAPGEN_MAP[topRoom] > 0)
end

function doesRoomHaveBottom(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)
    local bottomRoomY = y + 1

    if (bottomRoomY > math.sqrt(MAPGEN_MAPSIZE)) then
        return false
    end

    local bottomRoom = mapGenIndexFromCoordinates(x,bottomRoomY)

    return (MAPGEN_MAP[bottomRoom] > 0)
end

function doesRoomHaveLeft(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)
    local leftRoomX = x - 1

    if (leftRoomX < 0) then
        return false
    end

    local leftRoom = mapGenIndexFromCoordinates(leftRoomX,y)

    return (MAPGEN_MAP[leftRoom] > 0)
end


function doesRoomHaveRight(index)
    local x = mapGenPositionXFromArrayIndex(index)
    local y = mapGenPositionYFromArrayIndex(index)
    local rightRoomX = x + 1

    if (rightRoomX > math.sqrt(MAPGEN_MAPSIZE)) then
        return false
    end

    local rightRoom = mapGenIndexFromCoordinates(rightRoomX,y)

    return (MAPGEN_MAP[rightRoom] > 0)
end


