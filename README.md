# MoonHub Studio Bridge

![CI](https://github.com/js-bro-s/moonhub-studio-bridge/actions/workflows/ci.yml/badge.svg)

Browse the public MoonHub library from Roblox Studio, import animations as editable `KeyframeSequence` saves, and upload selected Studio poses to get shareable `MH-####` codes.

## Install

1. Get the plugin from [moonhub.dev/studio](https://moonhub.dev/studio): use the download button, or run the one-line install command for macOS or Windows.
2. Restart Studio. **MoonHub** appears on the Plugins tab. See the [Studio installation guide](https://js-bro-s.github.io/moonhub-studio-bridge/installation/) for details.

## Developer docs

Read the [MoonHub Studio Bridge docs](https://js-bro-s.github.io/moonhub-studio-bridge/) for installation, usage, supported data, and troubleshooting.

## Requirements

- Roblox Studio desktop app.
- A MoonHub account and creator API key for publishing.
- HTTP requests enabled in place settings.

Imports of public animation codes do not require an API key. The plugin saves your API key in local Roblox Studio plugin settings and sends it only as a bearer token to `https://moonhub.dev/api/upload`.

## Source

Review [`MoonHubBridge.plugin.lua`](MoonHubBridge.plugin.lua) before installing. The plugin transfers keyframe pose data; it does not recreate private Moon Animator editor metadata or asset-specific rig setup.

## Development

Source lives in `src/` as modules. `scripts/build.cjs` bundles them into the single `MoonHubBridge.plugin.lua` that users download. Edit `src/`, run `node scripts/build.cjs`, and commit both. CI fails if the bundle is stale.

## Checks

GitHub Actions runs source-contract tests (including a bundle freshness check), Selene lint, and Jekyll docs builds on pushes and pull requests. Run plugin contract tests locally with `node --test tests/*.test.cjs`.
