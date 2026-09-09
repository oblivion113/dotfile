# Seedream Example Scenarios

Typical usage scenarios of the Seedream skill, for development and testing reference.

## Scenario 1: Simple text-to-image

**User input:**
```
给我画一只可爱的英短蓝猫，趴在洒满阳光的木质窗台上
```

**Parameter mapping:**
```javascript
{
  prompt: "一只可爱的英短蓝猫，趴在洒满阳光的木质窗台上，背景是模糊的城市街景，暖色调，电影质感，8K分辨率",
  size: "2K",
  mode: "text-to-image",
  optimize: true
}
```

## Scenario 2: A coherent image set

**User input:**
```
生成一组共4张治愈系插画，主题为同一间咖啡馆的四季变迁
```

**Parameter mapping:**
```javascript
{
  prompt: "生成4张一组的连贯插画：同一间温馨咖啡馆的四季变迁。第1张春天樱花飘落，第2张夏天阳光斑驳，第3张秋天金黄落叶，第4张冬天温暖雪景。统一吉卜力画风，保持构图和色彩一致，温暖明亮",
  size: "2K",
  sequential: true,  // coherent-set mode
  count: 4,
  optimize: true
}
```

## Scenario 3: Image-to-image

**User input:**
```
[发了一张图片] 参考这张图的构图，把风格换成赛博朋克，保持主体不变
```

**Parameter mapping:**
```javascript
{
  prompt: "赛博朋克风格，霓虹灯，雨夜，高科技感，蓝色紫色调",
  reference_images: ["data:image/jpeg;base64,..."],
  mode: "image-to-image",
  reference_strength: 0.7,
  optimize: true
}
```

## Full parameter reference

| Parameter | Type | Default | Description |
|------|------|--------|------|
| `prompt` | string | - | Image description prompt (required) |
| `mode` | string | `text-to-image` | Generation mode: `text-to-image` / `image-to-image` |
| `size` | string | `2K` | Resolution: `2K` / `3K` / explicit pixel size |
| `sequential` | boolean | `false` | Whether to generate a coherent set of images (consistent style) |
| `count` | integer | `4` | Number of images in a set (1–15) |
| `reference_images` | array | - | Reference image list (up to 14 images) |
| `reference_strength` | number | `0.7` | Influence strength of reference images (0–1) |
| `optimize` | boolean | `true` | Whether to auto-optimize the prompt |
| `watermark` | boolean | `true` | Whether to add a watermark |
| `stream` | boolean | `auto` | Streaming output (auto-enabled when sequential=true) |
| `enable_web_search` | boolean | `false` | Whether to enable web search (breaking news, live events, etc.) |
| `response_format` | string | `jpeg` | Image format: `png` / `jpeg` |
