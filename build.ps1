# The following assumes your source code is in C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrdevplugin
# for some reason you have to compile files one by one, also non lua files need to be copied manually to the destination folder 
# Do NOT use most recent Luac version, this seems to cause some issues with LR compatibility. I have included Luac 5.1.5 which is recommended by Adobe
# format is kind of backwards it is luac_binary -o output_location source_file 

C:\xampp\htdocs\lightroom-csv-import\luac.exe -o C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrplugin\CsvImporter.lua C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrdevplugin\CsvImporter.lua

C:\xampp\htdocs\lightroom-csv-import\luac.exe -o C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrplugin\Info.lua C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrdevplugin\Info.lua

C:\xampp\htdocs\lightroom-csv-import\luac.exe -o C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrplugin\PluginInfoProvider.lua C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrdevplugin\PluginInfoProvider.lua

C:\xampp\htdocs\lightroom-csv-import\luac.exe -o C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrplugin\PluginManager.lua C:\xampp\htdocs\lightroom-csv-import\LRKeywordImporter.lrdevplugin\PluginManager.lua