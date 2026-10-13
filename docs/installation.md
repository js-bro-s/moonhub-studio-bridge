---
layout: page
title: Install
permalink: /installation/
---

## 1. Download plugin source

[Download MoonHubBridge.plugin.lua](https://github.com/js-bro-s/moonhub-studio-bridge/raw/refs/heads/main/MoonHubBridge.plugin.lua). Save file on your computer.

## 2. Save as local Studio plugin

Roblox Studio installs script-based plugins through **Save as Local Plugin**:

1. Open Roblox Studio and a place.
2. In Explorer, create a temporary `Script` under `ServerStorage`.
3. Open downloaded `.plugin.lua` file in a text editor. Copy all source and paste into temporary Script.
4. Select temporary Script. Open **Plugins** tab and choose **Save as Local Plugin**.
5. Confirm **Save**. Studio adds plugin to local plugins and starts it.
6. Delete temporary Script from `ServerStorage`; keep installed plugin.
7. Find **MoonHub** button in **Plugins** toolbar.

If **Save as Local Plugin** is missing, verify temporary object is a `Script` and selected in Explorer. Roblox Creator Hub has [official local plugin steps](https://create.roblox.com/docs/studio/plugins#save-plugin-script).

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

Open **Plugins → Manage Plugins** and disable or remove MoonHub bridge. To update, download current source and repeat local plugin installation; remove older MoonHub copy first if both toolbar buttons appear.
