# LRKeywordImporter
Lightroom plugin to allow importing of keywords from a CSV.


## Details

This is a simple plugin for Lightroom that will read in a CSV file containing a list of SmartPreviewFileNames ("key" in CSV) and keywords ("tags" in CSV) and attach the keywords to the images. 

The expected CSV format is: 

`index, key, file_name, file_path, jpg_path, convert_jpg_path, scaled_jpg_path, cluster_index, keep_image, tags
`

The plugin works with the sequential column numbers ("key"=2 (Lua start indexing from 1), tags=10). 
Please avoid of mixing columns amount and ordering.

## Instructions

1. Add the plugin as usual
1. Select Library mode
1. Select 'Library' from the top menu and open Keyword Importer from the Plug-in Extras item at the bottom. 
1. Click 'Select file' to open the file selection dialog and find your .csv file. 
1. Hit OK and the keywords will start importing. 

### Notes/warnings

- Only tested on Windows. 
- Has not been tested on CSVs above a few hundred lines.
- When you click OK to start the import, the dialog will close and the import will start running in the background. If you view the Keyword List you should see the new keywords be added. 
