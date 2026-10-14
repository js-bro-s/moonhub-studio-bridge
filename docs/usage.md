---
layout: page
title: Use bridge
permalink: /usage/
---

## Browse the public library

1. Open a place in Studio. Enable HTTP requests for that place.
2. Open **Plugins → MoonHub**. The **Browse** tab loads recent public animations.
3. Type a title, `MH-####` code, or tag in **Search**. Results update after you stop typing.
4. Pick a category chip to narrow results. Select **Load more** to page further.
5. Select a result to see its description and tags. Select **Import to ServerStorage**. Plugin fetches full keyframe data and adds an editable sequence under `ServerStorage.MoonAnimator2Saves`.

Browsing and importing public animations need no API key. You can also type a short code such as `MH-8492` under **Import by short code**.

## Upload Studio save to MoonHub

1. Open place in Studio. Enable HTTP requests for that place.
2. Open **Plugins → MoonHub → Settings**. Paste your API key from the [MoonHub dashboard](https://moonhub.dev/dashboard). Select **Validate key** to confirm it.
3. Select a `KeyframeSequence` in Explorer, or a folder/model containing one.
4. Open the **Export** tab. The selection card shows keyframes, frames, and poses. If several sequences are found, pick one from the list.
5. Edit title, category, rig, and tags. Rig is detected from pose names.
6. Select **Upload selected save to MoonHub**.
7. Copy the returned link from the result box. The status bar shows the `MH-####` code.

Bridge sorts keyframes by time and maps times to the nearest 60 FPS frame. It exports each descendant `Pose` using its name and `CFrame`. Matching `Motor6D` names provide `C0`/`C1` transform offsets.

Upload failure appears in the status bar. Check API key, place HTTP setting, internet, and selected sequence. Web uploads also support `.rbxm` and normalized `.json` files.

Imports rebuild keyframes and named poses from normalized tracks. They do not download original `.rbxm` bytes or recreate private Moon Animator metadata. R6 and R15 use built-in pose hierarchy mapping. FPS Arms and Custom rigs may need hierarchy correction or retargeting before playback.

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
