local RunService = game:GetService("RunService")

local Directory = {}

if RunService:IsServer() then
    Directory.ServerScriptService = game:GetService("ServerScriptService")
    Directory.ServerPackages = Directory.ServerScriptService:WaitForChild("ServerPackages")
    Directory.HttpService = game:GetService("HttpService")
    -- Server-only stash (not replicated) for unloaded map zombies, etc.
    Directory.ServerStorage = game:GetService("ServerStorage")
end

-- Services
Directory.ReplicatedStorage = game:GetService("ReplicatedStorage")
Directory.TweenService = game:GetService("TweenService")
Directory.PathfindingService = game:GetService("PathfindingService")
Directory.PhysicsService = game:GetService("PhysicsService")
Directory.RunService = RunService
Directory.Players = game:GetService("Players")
Directory.Lighting = game:GetService("Lighting")
Directory.CollectionService = game:GetService("CollectionService")

Directory.Packages = Directory.ReplicatedStorage:WaitForChild("Packages")

return Directory