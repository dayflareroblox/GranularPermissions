local GranularPermissions = {}
GranularPermissions.__index = GranularPermissions

-- // PACKAGES
local TableUtil = require(script.Parent:WaitForChild("TableUtil"))
local stringUtility = require(script:WaitForChild("stringUtility"))

--[=[
	@class MyFirstClass

	This is my first class.
]=]
function GranularPermissions.new()
    local self = setmetatable({}, GranularPermissions)
    self.Replacements = {}
    self.Callbacks = {}

    self.Configuration = {
        SplittingSyntax = ":"
    }
    
    return self
end

function GranularPermissions:IsAuthorised(Player: Player, Permissions: {any}): boolean
    local AllRequired = TableUtil.Find(Permissions, function(Item: string)
        return Item == "[RequireAll]"
    end) and true or false

    for _, PermissionProperty: any in pairs(Permissions) do
        if PermissionProperty == "[RequireAll]" then
            continue
        end

        local Reverse = false
        local AuthorisedBoolean = false

        if typeof(PermissionProperty) == "string" then
            if stringUtility:IsReversed(PermissionProperty) then
                Reverse = true
                PermissionProperty = PermissionProperty:sub(2)
            end

            local Arguments = stringUtility:SplitArguments(PermissionProperty, self.Configuration.SplittingSyntax)

            for Index: number, SingleArgument: string in pairs(Arguments) do
                if #stringUtility:SplitArguments(SingleArgument, "-") >= 2 then
                    Arguments[Index] = stringUtility:SplitArguments(SingleArgument, "-")
                end

                if self.Replacements[SingleArgument] then
                    Arguments[Index] = self.Replacements[SingleArgument]
                end
            end

            local CallbackRequest = self:GetCallback(Arguments[1], Player, Arguments) :: boolean

            if Reverse then
                CallbackRequest = not CallbackRequest
            end

            AuthorisedBoolean = CallbackRequest
        elseif typeof(PermissionProperty) == "table" then
            AuthorisedBoolean = self:IsAuthorised(Player, PermissionProperty)
        end

        if AllRequired and not AuthorisedBoolean then
            return false
        elseif not AllRequired and AuthorisedBoolean then
            return true
        end
    end

    return AllRequired
end

function GranularPermissions:GetCallback(Callback: string, ...)
    if self.Callbacks[Callback] then
        return self.Callbacks[Callback](self, ...)
    end
end

function GranularPermissions:RegisterReplacement(ReplacementName: string, ReplaceWith: string | number)
	self.Replacements[ReplacementName] = ReplaceWith
end

function GranularPermissions:RegisterReplacementsBulk(Replacements: {{ReplacementName: string, ReplaceWith: string | number}}): boolean
	for _, Replacement in pairs(Replacements) do
		self:RegisterReplacement(Replacement.ReplacementName, Replacement.ReplaceWith)
	end

	return true
end

function GranularPermissions:RegisterCallback(CallbackName: string, Callback): boolean
	if self.Callbacks[CallbackName] then
		return false
	else
		self.Callbacks[CallbackName] = Callback
		return true
	end
end


function GranularPermissions:Destroy()
    
end


return GranularPermissions
