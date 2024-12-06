local TableUtil = require(script.Parent:WaitForChild("TableUtil"))
local stringUtility = require(script:WaitForChild("stringUtility"))

--[=[
	@class GranularPermissions

	The `GranularPermissions` class is designed to manage and evaluate complex permission sets for players. 
	It supports customizable permission checks, dynamic replacements, and flexible splitting syntax.
]=]
local GranularPermissions = {}
GranularPermissions.__index = GranularPermissions

--[=[
    @prop Configuration {SplittingSyntax: string}

    @within GranularPermissions
]=]

--[=[
    Creates a new GranularPermissions instance.
    @return GranularPermissions -- Returns the GranularPermissions instance.
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

--[=[
	This function checks if a player is authorized based on a given set of permissions.

	@param Player Player -- The player whose permissions are being checked
	@param Permissions {any} -- A list of permissions to evaluate
	@return boolean -- Returns `true` if the player is authorized, otherwise `false`
]=]
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

--[=[
	This function retrieves and executes a registered callback for the provided arguments.

	@param Callback string -- The name of the callback to execute
	@param ... any -- Additional arguments to pass to the callback
	@return boolean? -- Returns the result of the callback, or `nil` if the callback is not found
]=]
function GranularPermissions:GetCallback(Callback: string, ...)
    if self.Callbacks[Callback] then
        return self.Callbacks[Callback](self, ...)
    end
end

--[=[
	This function registers a single replacement for use in permission strings.

	@param ReplacementName string -- The name of the replacement
	@param ReplaceWith string | number -- The value to replace with
]=]
function GranularPermissions:RegisterReplacement(ReplacementName: string, ReplaceWith: string | number)
	self.Replacements[ReplacementName] = ReplaceWith
end

--[=[
	This function registers multiple replacements in bulk.

	@param Replacements {{ReplacementName: string, ReplaceWith: string | number}} -- A list of replacements to register
	@return boolean -- Returns `true` after successfully registering all replacements
]=]
function GranularPermissions:RegisterReplacementsBulk(Replacements: {{ReplacementName: string, ReplaceWith: string | number}}): boolean
	for _, Replacement in pairs(Replacements) do
		self:RegisterReplacement(Replacement.ReplacementName, Replacement.ReplaceWith)
	end

	return true
end 

--[=[
	This function registers a callback function to evaluate permissions dynamically.

	@param CallbackName string -- The name of the callback
	@param Callback (self: GranularPermissions, ...any) -> boolean -- The function to execute for the callback
	@return boolean -- Returns `true` if the callback was registered, or `false` if it already exists
]=]
function GranularPermissions:RegisterCallback(CallbackName: string, Callback): boolean
	if self.Callbacks[CallbackName] then
		return false
	else
		self.Callbacks[CallbackName] = Callback
		return true
	end
end

--[=[
	This function cleans up and destroys the `GranularPermissions` instance.
]=]
function GranularPermissions:Destroy()
    
end


return GranularPermissions
