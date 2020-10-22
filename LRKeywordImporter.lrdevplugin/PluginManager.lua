local LrView = import "LrView"
local LrHttp = import "LrHttp"
local bind = import "LrBinding"
local app = import 'LrApplication'
PluginManager = {}
function PluginManager.sectionsForTopOfDialog( f, p )
    return {
        -- section for the top of the dialog
        {
            title = 'Plug-in',
            f:row {
                spacing = f:control_spacing(),
                f:picture {
                    value = _PLUGIN:resourceId('SDE_HeaderLogo.png'),
                    alignment = 'center',
                    fill_horizontal = 1,
                },
            },
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'SDE Keyword Importer',
                    alignment = 'center',
                    fill_horizontal = 1,
                },
            },
        },
    }
end