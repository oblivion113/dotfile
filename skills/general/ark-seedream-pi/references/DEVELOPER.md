# Seedream Agent Developer Guide

For Agent developers: image preprocessing, script invocation, and streaming output.

## Image preprocessing (the Agent layer's responsibility)

The skill accepts reference images in the following formats; the Agent layer is responsible for the conversion:

### Supported formats
```javascript
// 1. Base64 data URI (recommended)
"data:image/jpeg;base64,/9j/4AAQSkZJRg..."
"data:image/png;base64,iVBORw0KGgo..."

// 2. HTTP/HTTPS URL (must be publicly accessible)
"https://example.com/image.jpg"
```

**Image limits:**
- Single image size: ≤ 10MB
- Formats: JPEG / PNG / WebP
- Count: up to 14 images
- Recommended resolution: ≥ 1024x1024

## Invoking the script

### Mode 1: single-image generation
```bash
# Basic usage
node scripts/generate.js --prompt "一只可爱的小猫"

# Full parameters
node scripts/generate.js \
  --prompt "一只可爱的小猫" \
  --size "2K" \
  --mode "text-to-image" \
  --watermark true \
  --optimize true \
  --response_format "jpeg"
```

**Example output (JSON):**
```json
{
  "success": true,
  "images": [
    {
      "url": "https://ark.example.com/images/xxx.jpg",
      "local_path": "/Users/xxx/Desktop/Seedream-Images/2026-04-27/seedream_123456_1.jpg",
      "width": 2048,
      "height": 2048
    }
  ],
  "metadata": {
    "generation_time": 12.5,
    "size": "2K"
    "mode": "text-to-image",
    "image_count": 1
  }
}
```

### Mode 2: coherent set generation (streaming output)
```bash
node scripts/generate.js \
  --prompt "春夏秋冬四季变迁，同一地点" \
  --sequential true \
  --count 4 \
  --stream true
```

**Properties of streaming output:**
- Each image is returned as soon as it is generated, without waiting for the whole set
- Time to first visible image drops by 75%
- Style, palette, and composition stay consistent automatically

## Streaming progress feedback

When `sequential=true`, the skill prints real-time progress to stderr:

```
🎨 正在生成第 1/4 张图...
✅ 第 1 张已生成并保存
🎨 正在生成第 2/4 张图...
✅ 第 2 张已生成并保存
...
```

The Agent layer can capture stderr and show the user live progress.

## Result presentation rules for the Agent layer (important)

The skill separates stderr and stdout by design:

| Stream | Content | Purpose | Agent-layer handling |
|--------|------|------|------------------|
| **stderr** | Progress, logs, hints | Human-readable real-time feedback | Print line by line for the user |
| **stdout** | Final JSON result (with image links) | Parsed by the Agent | Do not print raw; parse and present structured |

### Correct handling flow

```javascript
// 1. Capture stderr and stdout separately
const { stderr, stdout } = await execAsync('node scripts/generate.js --prompt "xxx"');

// 2. Show stderr to the user line by line (real-time progress)
showToUser(stderr);

// 3. Parse the stdout JSON, then present the final result formatted
const result = JSON.parse(stdout);

// 4. Final result: the image files must be shown to the user!
if (result.success && result.images) {
  for (const img of result.images) {
    if (img.download_success) {
      // Key point: send the local file to the user (not just a path string)
      sendFileToUser(img.local_path);
      // The online link can be shown alongside
      sendTextToUser(`🔗 在线链接: ${img.url}`);
    } else {
      sendTextToUser(`❌ 第 ${img.index} 张下载失败: ${img.download_error}\n🔗 原始链接: ${img.url}`);
    }
  }
}
```

### Common mistakes

- Showing only stderr without parsing the stdout JSON → the user never sees the image links/files
- Printing the stdout JSON directly → the user sees raw gibberish
- Showing only online links without reading and sending the local files → poor user experience

## Supported native API endpoints

### Text-to-image / image-to-image / coherent sets (unified endpoint)
```http
POST https://ark.cn-beijing.volces.com/api/plan/v3/images/generations
Content-Type: application/json
Authorization: Bearer ark-xxx

{
  "prompt": "一只可爱的小猫",
  "size": "2K"
}
```

**Notes:**
- All image generation capabilities (text-to-image, image-to-image, coherent sets) use this single endpoint
- **The image count of a coherent set is not passed through fields such as `num_images`, `count`, or `max_images`.** The count is triggered by prompt semantics, e.g. `"生成4张一组的连贯插画..."`. The script's `--count` is used only for prompt construction, local validation, progress display, and metadata records

## Error handling recommendations

The Agent layer should handle these common errors:

| Error type | Recommended handling |
|----------|---------|
| API key not configured | Ask the user to send a key starting with ark-; use it for this session only by default, and require explicit confirmation before saving to global config |
| Network error | Retry automatically 2–3 times; inform the user on failure |
| Image download failed | Return the generated online URL and ask the user to save it manually |
| Invalid parameters | Correct them into the valid range automatically and tell the user |
