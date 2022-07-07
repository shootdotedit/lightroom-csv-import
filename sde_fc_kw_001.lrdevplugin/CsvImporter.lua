--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

ShowCustomDialog.lua
From the Hello World sample plug-in. Displays a custom dialog and writes debug info.

------------------------------------------------------------------------------]]

-- Access the Lightroom SDK namespaces.
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'
local LrErrors = import 'LrErrors'


-- Create the logger and enable the print function.

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- Pass either a string or a table of actions.

-- Write trace information to the logger.

local function outputToLog( message )
	myLogger:trace( message )
end

-- Parse a CSV line, taking into consideration quoted items that include the separator.
-- http://lua-users.org/wiki/LuaCsv
function parseCSVLine (line,sep)
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startPosition,endPosition = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startPosition+1,endPosition-1)
				pos = endPosition + 1
				c = string.sub(line,pos,pos)
				if (c == '"') then txt = txt..'"' end
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else
			-- no quotes used, just look for the first separator
			local startPosition,endPosition = string.find(line,sep,pos)
			if (startPosition) then
				table.insert(res,string.sub(line,pos,startPosition-1))
				pos = endPosition + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end
		end
	end
	return res
end

function convertCSVIntoTagsBySmartPreviewName(CSCFileName)
	local tagsBySmartPreviewName = {}
	for line in io.lines(CSCFileName) do
		local parsed_line = parseCSVLine(line, ",")
		tagsBySmartPreviewName[parsed_line[2]] = parsed_line[11]
		-- Note that columns are indexed from 1 not 0 here, so column 2 is Key and 10 is Tags
	end
	tagsBySmartPreviewName["key"] = nil
	return tagsBySmartPreviewName
end

function setKeywordTagsToPhoto(catalog, photo, KeywordTags)
	for keywordTag in KeywordTags:gmatch('[^,%s]+') do
		catalog:withWriteAccessDo('setKeywordTagsToPhoto', function()
			local newKeyword = catalog:createKeyword(keywordTag, {}, true, nil, true)
			photo:addKeyword(newKeyword)
			-- addKeyword prevents keyword duplication and is non case sensitive 
		end)
	end
end

--[[
	Demonstrates a custom dialog with a simple binding. The dialog displays a
	checkbox and a text field.  When the check box is selected the text field becomes
	enabled, if the checkbox is unchecked then the text field is disabled.
	
	The check_box.value and the edit_field.enabled are bound to the same value in an
	observable table.  When the check_box is checked/unchecked the changes are reflected
	in the bound property 'isChecked'.  Because the edit_field.enabled value is also bound then
	it reflects whatever value 'isChecked' has.
]]
local function showCustomDialog()
	LrFunctionContext.callWithContext( "showCustomDialog", function( context )
	    local f = LrView.osFactory()
	    -- Create a bindable table.  Whenever a field in this table changes
	    -- then notifications will be sent.
	    local props = LrBinding.makePropertyTable( context )
	    props.isChecked = false

		local staticTextValue = f:static_text {
			title = "Please select file \"Job_Number.csv\"",
			width = 300,
			alignment = left
		}
	    -- Create the contents for the dialog.
	    local c = f:row {
		    -- Bind the table to the view.  This enables controls to be bound
		    -- to the named field of the 'props' table.

		    bind_to_object = props,

			f:static_text {
				--alignment = "right",
				-- width = LrView.share "label_width",
				alignment = "left",
				width = 100,
				title = "Import .csv file: "
			},
			staticTextValue,
		    f:push_button {
					title = "Select File",
					action = function()
						staticTextValue.title = LrDialogs.runOpenPanel({
							title = "Import this file: Job_Number.csv",
							canChooseDirectories = false,
							allowsMultipleSelection = false,
						})[1]
						outputToLog( "File find button clicked." )
					end
				}
	    }


	    local retVal = LrDialogs.presentModalDialog {
			    title = "SDE Keyword Importer",
				resizable = false,
				actionVerb = "Start Import",
				cancelVerb = "Cancel",
			    contents = c
		}

		outputToLog(retVal)

		if retVal == "ok" then
			outputToLog("Got file & OK so calling the actual keyword import")
			LrTasks.startAsyncTask(function()
				local tagsCSVFileName = staticTextValue.title
				-- test for CSV currently using string match to the dialog title should use file selector call back
				if tagsCSVFileName == "Please select file \"Job_Number.csv\"" then
					LrErrors.throwUserError( "Please select the \"Job_Number.csv\" and then click \"Start Import\"" )
				end  

				if tagsCSVFileName == "cancel" then
					LrErrors.throwUserError( "Please select the \"Job_Number.csv\" and then click \"Start Import\"" )
				end  

				local CSVTagsBySmartPreviewName = convertCSVIntoTagsBySmartPreviewName(tagsCSVFileName)
				local catalog = LrApplication.activeCatalog()
				local allPhotos = catalog:getAllPhotos()
				local progressScope = LrProgressScope {
						title = LOC( "$$$/KeywordImporter/ProgressScopeTitle=Applying Keywords")
					}
				for index, photo in ipairs(allPhotos) do
					local raw_metadata = photo:getRawMetadata("smartPreviewInfo")
					if raw_metadata["smartPreviewPath"] ~= nil then
						local smartPreviewPath = photo:getRawMetadata("smartPreviewInfo").smartPreviewPath
						outputToLog(smartPreviewPath)
						--get index of smartPreviewFileName extension, requires v5 of API
						local indexOfFileExtension = smartPreviewPath:find(".dng")
						--remove anything from smartPreviewPath except smartPreviewFileName
						local smartPreviewFileName = smartPreviewPath:sub(indexOfFileExtension - 36, indexOfFileExtension - 1)
						--check if have data for smartPreview in CSV table
						if CSVTagsBySmartPreviewName[smartPreviewFileName] ~= nil then
							do
								local keywordTagsFromCSV = CSVTagsBySmartPreviewName[smartPreviewFileName]
								setKeywordTagsToPhoto(catalog, photo, keywordTagsFromCSV)
							end
						else
							do
								outputToLog("There is no data in CSV file for SmartPreview file: " .. smartPreviewFileName .. "")
							end
						end
					end
					progressScope:setPortionComplete( index, #allPhotos )
					progressScope:setCaption(smartPreviewFileName)
				end
				progressScope:done()
			end)
		else
			outputToLog("RetVal not OK: " .. retVal)
			LrErrors.throwUserError( retVal )
		end


	end) -- end main function

end


-- Now display the dialogs.
showCustomDialog()
