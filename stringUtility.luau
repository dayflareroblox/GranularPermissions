local stringUtility = {}

function stringUtility:SplitArguments(String: string, Cursor: string)
	return string.split(String, Cursor)
end

function stringUtility:IsReversed(String: string)
	return string.sub(String, 1, 1) == "!" 
end

return stringUtility