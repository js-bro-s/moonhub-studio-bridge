const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const test = require('node:test');

const plugin = readFileSync(join(__dirname, '..', 'MoonHubBridge.plugin.lua'), 'utf8');

test('plugin uploads animation payloads with bearer authentication', () => {
  assert.match(plugin, /Url = API_BASE \.\. "\/upload", Method = "POST"/);
  assert.match(plugin, /Authorization = "Bearer " \.\. key/);
  assert.match(plugin, /payload_json = payload/);
});

test('plugin imports public animation codes from the documented API route', () => {
  assert.match(plugin, /Url = API_BASE \.\. "\/anim\/" \.\. code, Method = "GET"/);
  assert.match(plugin, /animation\.payload_json/);
  assert.match(plugin, /animation\.fps or 60/);
});

test('plugin restores editable keyframes and selects imported sequence', () => {
  assert.match(plugin, /Instance\.new\("KeyframeSequence"\)/);
  assert.match(plugin, /Instance\.new\("Keyframe"\)/);
  assert.match(plugin, /Instance\.new\("Pose"\)/);
  assert.match(plugin, /ServerStorage:FindFirstChild\("MoonAnimator2Saves"\)/);
  assert.match(plugin, /Selection:Set\(\{sequence\}\)/);
});

test('plugin source contains no embedded live API key', () => {
  assert.doesNotMatch(plugin, /mh_live_[a-z0-9]{16,}/i);
});
