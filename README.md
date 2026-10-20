# PipePipe Bisub — LLM 双语字幕补丁工程

给 [PipePipe](https://github.com/InfinityLoop1308/PipePipe)（NewPipe 知名分支）加上「LLM 实时翻译双语字幕」的 patch 集合。

不 fork、不长期维护整个项目——只维护最小的补丁集，可手动/定期跟随上游重新构建。上游失效时自动收到 issue 通知。

迁移自 [NewPipe-Bisub](../NewPipe-Bisub)（bisub-28 终态），基线 **PipePipe v5.5.0-beta3**。NewPipe 版的 UI 精简 patch（隐藏非 YouTube 服务、删 kiosk/捐赠）**未迁移**——PipePipe 原生多平台 UI 全部保留。

## 功能

- 详情页「双语」按钮手动触发：将字幕轨（默认英文，优先人工字幕）通过你配置的大模型批量翻译，实时显示进度百分比
- 译文完成后字幕菜单出现 **Bilingual（双语）** 轨，选中后由自绘 `BisubSubtitleView` 渲染「原文 + 译文」双层字幕（不依赖系统字幕设置，鸿蒙可用）
- 应用内样式编辑器：字幕大小、文字颜色、背景模式（半透明/纯黑/透明描边）、内边距、圆角、最大宽度、垂直位置，所见即所得预览
- 译文按视频 + 字幕轨 + 模型 + 目标语言缓存，第二次观看零等待
- 支持任何 OpenAI 兼容接口：OpenAI / DeepSeek / Moonshot (Kimi) / 智谱 GLM / OpenRouter / 自定义

## Patch 清单

| # | 内容 |
|---|---|
| 0001 | bisub 包：流式翻译管线（BisubManager/VttParser/SubtitleTranslator/BisubPrefs/BisubStyle/BisubSubtitleView） |
| 0002 | 设置页 + 应用内样式编辑器（含中文字符串） |
| 0003 | VideoPlaybackResolver 注入双语轨（完成态缓存只读） |
| 0004 | 详情页双语按钮（默认 + layout-large-land 两个布局变体） |
| 0005 | 播放器接线：player.xml 叠加自绘 View，onCues 双喂，选轨时切换渲染层 |

## 与 NewPipe 版的实现差异（PipePipe 重构适配）

- PipePipe 把播放器拆成了 Kotlin controller：渲染接线在 `PlayerLayoutController.onCues/reapplyCues`（双喂）与 `PlayerTracksController.applyBisubStyleIfSelected`（选轨判定 + 视图切换），NewPipe 版的 `VideoPlayerUi.java` 单文件接线不复存在
- `setupSubtitleView()` 拆出无副作用的 `setupSubtitleViewStyle()`，避免 else 分支重入选轨逻辑造成递归
- `BisubManager` 内联字幕候选过滤（PipePipe 的 `ListHelper` 无 `getUrlAndNonTorrentStreams`）

## 配置方法

PipePipe 设置 → **Bilingual subtitles**：

| 设置项 | 说明 |
|---|---|
| Enable | 总开关 |
| Provider | 提供商预设，选择后自动填充 URL 和模型名 |
| API base URL | OpenAI 兼容接口地址，如 `https://api.deepseek.com/v1` |
| API key | 密钥，摘要只显示「Set / Not set」 |
| Model | 模型名，如 `deepseek-chat` |
| Target language | 译文语言，默认 `Simplified Chinese` |
| Source subtitle language | 源字幕轨语言码，默认 `en`；留空则用第一条可用轨 |

## 本地构建

```bash
./build.sh                # 基线 client b7cd5a34c + extractor 73442076 构建
./build.sh dev main       # 跟随上游 dev/main
./build.sh dev main --keep-source   # 保留源码目录以便调试
```

要求：git、JDK 25、Android SDK（`ANDROID_HOME` 环境变量或 `local.properties`）。

注意：PipePipeClient 的 `settings.gradle` 含 `includeBuild('../PipePipeExtractor')`，脚本会把两个上游仓**并排** clone 到 `src/` 下原名目录。

产物：`src/PipePipeClient/app/build/outputs/apk/debug/*.apk`

## GitHub Actions 自动构建

- 手动触发（workflow_dispatch）：可指定 client/extractor ref，默认基线 v5.5.0-beta3
- 每周一 04:00 UTC 自动跟随上游 `dev` / `main` 重建
- 构建成功 → 自动创建 `bisub-<run_number>` release 并附带 APK
- patch 无法应用或编译失败 → 自动开 issue 提醒

## 维护守则（给未来的自己）

- 上游重构 player controller 时，0005 最容易碎：先看 `PlayerTracksController.onTextTracksChanged` 的选轨判定是否还能拿到回调参数 `Tracks` 快照
- 选轨语言判定必须 `equalsIgnoreCase`（ExoPlayer 会把语言码规范化成小写，实锤教训）
- 一次 patch 失败后先用 `git am --abort` 清理再改 patch，不要在 CI 里硬续