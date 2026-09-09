---
name: ark-seedream-pi
license: MIT
description: |
  Triggers when the user wants to generate images locally — text-to-image,
  image-to-image (from reference images), or coherent image sets with a unified
  style. Trigger phrases include "generate an image", "draw", "seedream",
  「生图/画图/画一张/参考这个画/生成一组图」. Calls the Seedream image
  generation endpoint of the VolcEngine Ark Agent Plan. Not for video
  generation.
compatibility: Requires Node.js 18+ and network access to the VolcEngine Ark API.
---

# Ark Seedream Image Generation

Agents invoke `scripts/generate.js` (relative to this SKILL.md, Node 18+, zero dependencies) to call the image generation endpoint of the VolcEngine Ark Agent Plan, saving JPEG/PNG files to a local directory.

## API key: pass it explicitly on every call; never let the script search for it

The script's auto-detection only reads the config files of Claude Code, OpenClaw, and Hermes. None of them exist on this machine, so detection always comes up empty. Agents must therefore pass `--api-key` explicitly, taking the value from `ARK_IMAGE_GEN_API_KEY` in `~/.config/secrets/keys.sh`:

```bash
node scripts/generate.js --prompt "一只趴在窗台上的英短蓝猫" \
  --api-key "$(sed -n 's/^export ARK_IMAGE_GEN_API_KEY=//p' ~/.config/secrets/keys.sh)"
```

Read the key from the file rather than relying on the environment variable already being set: agent shells are typically non-interactive and do not source `~/.zshrc`, so the variable is usually absent even though it is exported for interactive shells.

Never pass `--save-api-key`: it writes the key into the config of harnesses such as OpenClaw that do not exist on this machine, which is a wasted write. The key already lives in `~/.config/secrets/keys.sh`; a second persistent copy is unnecessary. Never print the key's value to the user or into files under version control.

The script defaults to base URL `https://ark.cn-beijing.volces.com/api/plan/v3` and model `doubao-seedream-5.0-lite`. Override either with the `ARK_*` environment variables listed in `references/CONFIG.md`; set `ARK_SEEDREAM_SAVE_PATH` only to change the default save directory.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `--prompt` | required | Image description; the more specific, the better |
| `--mode` | `text-to-image` | `text-to-image` / `image-to-image`; passing `--reference_images` implies the latter |
| `--size` | `2K` | `2K` / `3K` or an explicit pixel size |
| `--sequential` | `false` | Switch for coherent image sets (rules in the next section) |
| `--count` | `4` | Number of images in a set, 1–15 |
| `--reference_images` | - | Reference images, as a JSON array or comma-separated list; HTTP URLs or base64 data URIs, up to 14 images |
| `--reference_strength` | `0.7` | Influence strength of reference images, 0–1 |
| `--watermark` | `true` | Whether to add a watermark |
| `--optimize` | `true` | Automatic prompt optimization (10 built-in style presets, see `references/CONFIG.md`) |
| `--stream` | auto | Streaming output; enabled automatically when `sequential=true` |
| `--enable_web_search` | auto | Web search; enabled automatically when the prompt contains words such as 「最新/今天/新闻」 |
| `--response_format` | `jpeg` | `jpeg` (small files) / `png` (lossless) |

Both `--key value` and `--key=value` forms are accepted.

## Coherent image sets require set semantics in the prompt

`--sequential` is only an API parameter; the API actually infers set intent from the prompt text. Passing the flag while the prompt contains no set description usually yields a single image. With `sequential=true`, the prompt must therefore do three things at once: include a strong phrase such as 「N 张一组的连贯插画/漫画」; describe each image one by one; and state style-consistency constraints (「统一画风」「同一角色」and the like). For example:

```
--sequential --count 4 --prompt "生成4张一组的连贯插画：春天的樱花、夏天的海滩、秋天的红叶、冬天的雪景，统一画风，保持风格一致"
```

## Output and saving

Images are saved by default to `~/Desktop/Seedream-Images/<current date>/`, alongside a `seedream_<timestamp>_metadata.json` recording the prompt, parameters, and elapsed time. The script finally prints a JSON result to stdout (containing `images`, `metadata.save_dir`, `metadata.generation_time`); Agents use it to report the save directory and image count to the user. If an individual image fails to download, hand the returned URL to the user for manual download.

For troubleshooting, full examples, and the style-preset vocabulary, see `references/`: `EXAMPLES.md` (typical scenarios), `CONFIG.md` (configuration and models), `DEVELOPER.md` (reference-image preprocessing and streaming details).
