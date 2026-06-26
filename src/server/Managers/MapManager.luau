local Directory = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Directory)

-- Packages
local Trove = require(Directory.Packages.trove)
local BridgeNet2 = require(Directory.Packages.BridgeNet2)
local Signal = require(Directory.Packages.Signal)


local MapManager = {
    MapCleaner = Trove.new(),
}

local function GetMap() -- Get map from the randomzied stuff we have.
    
end

function MapManager:GenerateMap()
    
end

function MapManager:UnloadMap()
    
end

function MapManager:LoadMap()
    
end

function MapManager:Start()
    
end

return MapManager