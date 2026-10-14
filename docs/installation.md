---
layout: page
title: Install
permalink: /installation/
---

## 1. Install the plugin

Fastest: run one command. It downloads the plugin and puts it straight into Studio's plugins folder.

**macOS** (Terminal):

```bash
mkdir -p ~/Documents/Roblox/Plugins && curl -fsSL https://moonhub.dev/MoonHubBridge.plugin.lua -o ~/Documents/Roblox/Plugins/MoonHubBridge.plugin.lua
```

**Windows** (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:LOCALAPPDATA\Roblox\Plugins" | Out-Null; Invoke-WebRequest https://moonhub.dev/MoonHubBridge.plugin.lua -OutFile "$env:LOCALAPPDATA\Roblox\Plugins\MoonHubBridge.plugin.lua"
```

Prefer a button? [Download MoonHubBridge.plugin.lua](https://moonhub.dev/MoonHubBridge.plugin.lua) and save it into the same folder (`~/Documents/Roblox/Plugins` on macOS, `%LOCALAPPDATA%\Roblox\Plugins` on Windows). The same buttons and commands are on [moonhub.dev/studio](https://moonhub.dev/studio).

## 2. Restart Studio

Close and reopen Roblox Studio. Find the **MoonHub** button on the **Plugins** tab. Studio loads every plugin file in that folder when it starts.

If you cannot write to the plugins folder, use **Save as Local Plugin** instead: put the source in a temporary `Script` under `ServerStorage`, select it, choose **Plugins → Save as Local Plugin**, then delete the temporary Script. Roblox Creator Hub has [official local plugin steps](https://create.roblox.com/docs/studio/plugins#save-plugin-script).

## 3. Optional: add an upload API key

Browsing and importing public animations need no API key. Follow these steps only when you want to upload saves.

1. Sign in at [moonhub.dev/dashboard](https://moonhub.dev/dashboard).
2. Create API key. Copy it while shown; MoonHub stores only its hash.
3. Open **Plugins → MoonHub** in Studio.
4. Paste key into **API KEY** field. Click elsewhere to save it in Studio plugin settings.

Key authorizes publishing. Do not share it or include it in a place file. Revoke it from dashboard if lost or exposed.

## 4. Allow HTTP requests

In Studio, open **File → Game Settings → Security**, enable **Allow HTTP Requests**, and save settings. This place setting allows plugin to reach MoonHub API.

On Studio versions with a different menu layout, open **Game Settings → Security** and find **Allow HTTP Requests**.

## Remove or update plugin

Open **Plugins → Manage Plugins** and disable or remove MoonHub bridge. To update, run the install command again and restart Studio; it replaces the old file. Remove any older MoonHub copy installed through **Save as Local Plugin** first if both toolbar buttons appear.
