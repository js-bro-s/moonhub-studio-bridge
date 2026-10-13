# MoonHub Studio Bridge

Move Roblox `KeyframeSequence` saves between Roblox Studio and MoonHub. Publish selected animation poses to get a shareable `MH-####` code. Import public codes back into Studio as editable keyframes.

## Install

1. [Download the plugin script](https://github.com/js-bro-s/moonhub-studio-bridge/raw/refs/heads/main/MoonHubBridge.plugin.lua).
2. Follow the [Studio installation guide](https://js-bro-s.github.io/moonhub-studio-bridge/installation/).

## Developer docs

Read the [MoonHub Studio Bridge docs](https://js-bro-s.github.io/moonhub-studio-bridge/) for installation, usage, supported data, and troubleshooting.

## Requirements

- Roblox Studio desktop app.
- A MoonHub account and creator API key for publishing.
- HTTP requests enabled in place settings.

Imports of public animation codes do not require an API key. The plugin saves your API key in local Roblox Studio plugin settings and sends it only as a bearer token to `https://moonhub.dev/api/upload`.

## Source

Review [`MoonHubBridge.plugin.lua`](MoonHubBridge.plugin.lua) before installing. The plugin transfers keyframe pose data; it does not recreate private Moon Animator editor metadata or asset-specific rig setup.
