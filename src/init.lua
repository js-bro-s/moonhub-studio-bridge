-- MoonHub Studio bridge. Allow HTTP requests in Studio settings before use.
local Shell = import("Shell")
local Store = import("Store")

import("tabs/Browse")()
import("tabs/Export")()
import("tabs/Settings")()

Shell.selectTab(Store.state.apiKey == "" and "Settings" or "Browse")
