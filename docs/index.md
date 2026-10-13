---
layout: page
title: MoonHub Studio Bridge
permalink: /
---

Move Roblox `KeyframeSequence` saves between Studio and MoonHub. Publish selected animation poses to get a shareable `MH-####` code. Import public codes back into Studio as editable keyframes.

[Install the plugin]({{ '/installation/' | relative_url }}) · [Read usage guide]({{ '/usage/' | relative_url }}) · [Troubleshoot]({{ '/troubleshooting/' | relative_url }})

## What bridge transfers

- `KeyframeSequence` keyframe times and descendant `Pose.CFrame` transforms.
- Position and quaternion tracks, with Motor6D `C0` and `C1` offsets when source rig exposes matching motors.
- Animation title, category, rig selection, and fixed 60 FPS frame mapping.

Imports create a new `KeyframeSequence` under `ServerStorage.MoonAnimator2Saves`. Bridge does not recreate Moon Animator editor metadata, easing settings, or asset-specific rig setup. Review imported poses on target rig before using animation in a published experience.

## Requirements

- Roblox Studio desktop app.
- MoonHub account and creator API key for uploads.
- HTTP requests enabled in place settings for upload and import.

Import codes use public animation data. API key needed only for export. Keep key private; revoke from [MoonHub dashboard](https://moonhub.dev/dashboard) if exposed.

## Source

Plugin source lives in [`MoonHubBridge.plugin.lua`](https://github.com/js-bro-s/moonhub-studio-bridge/blob/main/MoonHubBridge.plugin.lua). Read source before installing. Plugin sends selected keyframe data to `https://moonhub.dev/api/upload` and fetches public data from `https://moonhub.dev/api/anim/:code`.
