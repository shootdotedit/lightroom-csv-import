--[[----------------------------------------------------------------------------

License Info:
ShootDotEdit LLC Copyright 2020

--------------------------------------------------------------------------------

Info.lua
Summary information for ShootDotEdit Keyword Importer plug-in

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 5.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.adobe.lightroom.sdk.keywordimporter',

	LrPluginName = LOC "$$$/ShootDotEdit/PluginName=SDE Keyword Importer",
	LrPluginInfoUrl = 'https://shootdotedit.com/',
	LrPluginInfoProvider = 'PluginInfoProvider.lua',

	-- Add the menu item to the Library menu.
	
	LrLibraryMenuItems = {
		{
		    title = LOC "$$$/KeywordImporter/DialogObserver=Import CSV",
		    file = "CsvImporter.lua",
		},
	},
	VERSION = { major=0, minor=1, revision=0, build=1, },

}


	
