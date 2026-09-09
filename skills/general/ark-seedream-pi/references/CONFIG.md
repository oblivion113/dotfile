# Seedream Configuration Guide

The Seedream skill's API key detection strategy, configuration notes, and technical implementation details.

## API key detection strategy (three priority tiers)

The skill auto-detects the API key in the following order of priority. Most users never need to configure anything manually.

### Tier 1: The user sends the key directly in conversation (highest priority)

The user sends an API key starting with `ark-` directly in conversation:

```
User: ark-xxxxxxxxxxxx
```

**Handling logic:**
1. The key format is validated automatically (it must start with `ark-`)
2. By default the key is used for this session only and is not written to any config file
3. To save it as global configuration, the user must explicitly say "save this API key"; only then is `--save-api-key` passed and the key written
4. The original config file is backed up before writing (with API keys redacted)

This is the friendliest flow: the user sends the key once and never thinks about it again.

### Tier 2: Platform-specific detection (read the config of the current platform)

The skill detects the current platform first, then reads the API key from the corresponding location:

| Platform | Detection method | Field | Notes |
|------|---------|--------|------|
| **OpenClaw** | `~/.openclaw/` directory exists | `models.providers.*.apiKey` | Iterates all providers, takes the first valid key |
| **Hermes** | `~/.hermes/` directory exists | `model.api_key` | Field in the YAML config file |
| **Claude Code** | `~/.claude/` directory or env var exists | `env.ANTHROPIC_AUTH_TOKEN` in `~/.claude/settings.json`, or the `ANTHROPIC_AUTH_TOKEN` session env var | Does not overwrite an existing token |

Only the current platform's config is read; the skill never reads other tools' configs across platforms.

### Tier 3: Fallback compatibility (generic environment variable scan)

If platform detection finds no key, or the current platform is none of the three above, the skill scans the common naming variants for API keys (restricted to common field names to avoid false matches):

```
ANTHROPIC_AUTH_TOKEN
API_KEY
API_Key
API_Keys
api_key
apiKey
```

### None found: prompt the user explicitly

If all three tiers come up empty, the skill tells the user clearly: send an API key starting with `ark-` directly in conversation; it is used for this session only by default, and saving it to the global configuration requires explicit confirmation.

## Technical implementation notes (advanced users)

### Automatic prompt optimization
Enabled by default; automatically improves quality descriptors:

```javascript
// Automatically appended optimization terms:
"电影质感, 专业摄影, 8K分辨率, 极致细节, 光影层次, 色彩饱满"
```

Turned off automatically when the user says "don't optimize" or "use the original prompt".

### 10 built-in style presets
Style keywords are recognized automatically from user input:
- 电影风、二次元、插画风、写实风、国潮风
- 赛博朋克、水彩风、3D渲染、暗黑风、治愈系

### Three-tier save-path fallback
| Priority | Path | Notes |
|-------|------|------|
| 1 | `~/Desktop/Seedream-Images/` | Desktop preferred when available |
| 2 | `~/Seedream-Images/` | Falls back to the home directory without a desktop |
| 3 | `./Seedream-Images/` | Final fallback: the current working directory |

## Model quick reference

| Model ID | Notes |
|---------|------|
| **`doubao-seedream-5.0-lite`** | **Default and recommended** — fast, good quality, suitable for the vast majority of scenarios |

## Advanced configuration (normally unnecessary)

To use a separate account or custom configuration, override with these environment variables:

| Environment variable | Description | Default |
|---------|------|--------|
| `ARK_SEEDREAM_MODEL` | Custom model ID | `doubao-seedream-5.0-lite` |
| `ARK_SEEDREAM_API_BASE_URL` | Custom API base URL | Official endpoint |
| `ARK_SEEDREAM_SAVE_PATH` | Image save path | Auto-detected |
| `ARK_API_BASE_URL` | Global API base URL (fallback) | - |
| `ARK_SAVE_PATH` | Global save path (fallback) | - |

The API key comes from the three-tier auto-detection strategy and normally needs no environment variable.
