---
layout: page
title: MoonHub Studio Bridge
permalink: /
---

Browse public MoonHub animations in Roblox Studio, import them as editable keyframes, and upload selected `KeyframeSequence` saves to get shareable `MH-####` codes.

[Install the plugin]({{ '/installation/' | relative_url }}) · [Read usage guide]({{ '/usage/' | relative_url }}) · [Troubleshoot]({{ '/troubleshooting/' | relative_url }})

## What bridge transfers

- `KeyframeSequence` keyframe times and descendant `Pose.CFrame` transforms.
- Position and quaternion tracks, with Motor6D `C0` and `C1` offsets when source rig exposes matching motors.
- Animation title, category, rig selection, and fixed 60 FPS frame mapping.

Imports create a new `KeyframeSequence` under `ServerStorage.MoonAnimator2Saves`. Bridge does not recreate Moon Animator editor metadata, easing settings, or asset-specific rig setup. Review imported poses on target rig before using animation in a published experience.

## Requirements

- Roblox Studio desktop app.
- HTTP requests enabled in place settings for browsing, upload, and import.
- MoonHub creator API key for uploads only.

Browse and import use public animation data. Keep upload key private; revoke it from [MoonHub dashboard](https://moonhub.dev/dashboard) if exposed.

## Source

Plugin source lives in the [MoonHub repository](https://github.com/js-bro-s/moonhub.dev/blob/main/public/MoonHubBridge.plugin.lua) and is served at [moonhub.dev/MoonHubBridge.plugin.lua](https://moonhub.dev/MoonHubBridge.plugin.lua). Read source before installing. Plugin browses `https://moonhub.dev/api/animations`, fetches full tracks from `https://moonhub.dev/api/anim/:code`, and sends selected keyframe data to `https://moonhub.dev/api/upload`.
