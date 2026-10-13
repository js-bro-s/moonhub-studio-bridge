---
layout: page
title: Troubleshooting
permalink: /troubleshooting/
---

## Plugin button missing

- Confirm plugin appears under **Plugins → Manage Plugins** and is enabled.
- Close and reopen Studio after local install.
- Remove duplicate older MoonHub plugin if multiple buttons appear.

## Upload says API key missing or invalid

- Paste full `mh_live_...` value into plugin **API KEY** field.
- Click outside field to persist setting.
- Check that key remains active in [creator dashboard](https://moonhub.dev/dashboard).
- Revoke and issue a new key if original key was exposed.

## HTTP request fails

- Enable **Allow HTTP Requests** under place **Game Settings → Security**.
- Confirm Studio can reach `moonhub.dev`.
- Sign in and verify Supabase and R2 services are configured. Gallery sample mode does not enable publishing or downloads.

## No sequence or poses found

- Select a `KeyframeSequence`, or object containing one, in Explorer.
- Confirm sequence has at least one keyframe and keyframes contain `Pose` objects.
- Select exact sequence when folder contains multiple animation saves.

## Imported animation looks wrong

- Confirm rig type matches target rig.
- Built-in hierarchy mapping targets common R6 and R15 part names. FPS Arms and Custom may need retargeting.
- Bridge transfers pose transforms and 60 FPS frame timing only. It does not restore editor metadata, easing, or rig-specific animation settings.
- Test in an unpublished place before using in released experience.

## Revoke exposed key

Open [moonhub.dev/dashboard](https://moonhub.dev/dashboard), revoke compromised key, then issue replacement. Plugin stores API key in local Studio plugin settings. Never put key in shared game source or screenshots.
