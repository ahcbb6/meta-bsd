local menu = require("menu")
local entry = menu.welcome.all_entries.kernel_options
local original_name = entry.name

entry.name = function(index, choice, choices)
    local label = choice
    if choice == "kernel" then
        label = "kernel-OpenEmbedded"
    end
    return original_name(index, label, choices)
end
