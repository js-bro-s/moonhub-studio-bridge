local Theme = {
    ACCENT = Color3.fromRGB(230, 105, 52),
    ACCENT_TEXT = Color3.fromRGB(255, 255, 249),
    OK = Color3.fromRGB(110, 190, 120),
    ERR = Color3.fromRGB(240, 110, 90),
}

local themed = {}

function Theme.color(guide, modifier)
    return settings().Studio.Theme:GetColor(guide, modifier or Enum.StudioStyleGuideModifier.Default)
end

-- Binds a property to a Studio style guide color and re-applies it on theme change.
function Theme.bind(instance, property, guide, modifier)
    table.insert(themed, {instance, property, guide, modifier})
    instance[property] = Theme.color(guide, modifier)
    return instance
end

settings().Studio.ThemeChanged:Connect(function()
    for _, entry in ipairs(themed) do
        entry[1][entry[2]] = Theme.color(entry[3], entry[4])
    end
end)

return Theme
