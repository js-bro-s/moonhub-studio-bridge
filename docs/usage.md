---
layout: page
title: Use bridge
permalink: /usage/
---

## Browse the public library

1. Open a place in Studio. Enable HTTP requests for that place.
2. Open **Plugins → MoonHub**. The **BROWSE LIBRARY** view opens first.
3. Enter a title or `MH-####` code. Press Enter, or load the library.
4. Cycle the category filter and load again to narrow results.
5. Select **IMPORT** on an animation. Plugin fetches its full keyframe data and adds an editable sequence under `ServerStorage.MoonAnimator2Saves`.

Browsing and importing public animations need no API key. Results show title, category, rig, short code, and author. Search requests return metadata only; plugin fetches animation tracks after you choose a result.

## Upload Studio save to MoonHub

1. Open place in Studio. Enable HTTP requests for that place.
2. Select a `KeyframeSequence` in Explorer, or select a folder/model containing one. Exact sequence selection avoids choosing wrong descendant when folder has several saves.
3. Open **Plugins → MoonHub**, then select **UPLOAD SAVE**.
4. Enter API key from your [MoonHub dashboard](https://moonhub.dev/dashboard). Plugin stores it in local Studio plugin settings.
5. Cycle **EXPORT CATEGORY** and **RIG TYPE** until desired values appear. Plugin remembers choices locally.
6. Select **UPLOAD SELECTED SAVE TO MOONHUB**.
7. Read success status and copy returned `MH-####` code. Open link in status to view published animation.

Bridge exports sequence name as title. It sorts keyframes by time and maps times to nearest 60 FPS frame. It exports each descendant `Pose` using its name and `CFrame`. Matching `Motor6D` names provide `C0`/`C1` transform offsets.

Upload failure appears in plugin status. Check API key, place HTTP setting, internet, and selected sequence. Web uploads also support `.rbxm` and normalized `.json` files.

## Import by short code

1. Copy public code such as `MH-8492` from animation page.
2. Open **Plugins → MoonHub**, then select **UPLOAD SAVE**.
3. Enter code under **IMPORT BY SHORT CODE**.
4. Select **IMPORT CODE INTO SERVERSTORAGE**.
5. In Explorer, open `ServerStorage → MoonAnimator2Saves` and select imported `KeyframeSequence`.

Import needs HTTP requests but no API key. Plugin rebuilds keyframes and named poses from normalized tracks. It does not download original `.rbxm` bytes or recreate private Moon Animator metadata. R6 and R15 use built-in pose hierarchy mapping. FPS Arms and Custom rigs may need hierarchy correction or retargeting before playback.

## Normalized track format

Web and Studio API accept tracks with position XYZ followed by quaternion XYZW per keyframe:

```json
{
  "boneName": "RightUpperArm",
  "times": [0],
  "values": [0, 0, 0, 0, 0, 0, 1],
  "c0": [0, 0, 0, 0, 0, 0, 1],
  "c1": [0, 0, 0, 0, 0, 0, 1]
}
```

Each `times` value is a frame number. Each `values` key occupies seven consecutive numbers. Optional `c0` and `c1` describe matching Motor6D offsets.
