# BiPipe — 双语字幕视频播放器

基于 [PipePipe](https://github.com/InfinityLoop1308/PipePipe)（NewPipe 分支）的 Android 客户端，叠加双语字幕翻译、点词查词、生词本、云备份等语言学习功能。

不 fork 上游、不长期维护整个项目——只维护 **51 个 client patch + 4 个 extractor patch**，通过 CI 自动应用到上游源码并构建 APK。

## 功能

### 双语字幕翻译
- 详情页「双语」按钮一键触发，将字幕轨通过大模型批量翻译，实时显示进度
- 译文完成后字幕菜单出现双语轨，自绘渲染「原文 + 译文」双层字幕（不依赖系统字幕设置）
- 应用内样式编辑器：字幕大小、颜色、背景模式、内边距、圆角、最大宽度、垂直位置，所见即所得预览
- 译文按视频 + 字幕轨 + 模型 + 目标语言缓存，二次观看零等待
- 多翻译 profile 随时切换，已缓存的翻译在字幕菜单直接选
- 翻译引擎：OpenAI / DeepSeek / Moonshot (Kimi) / 智谱 GLM / OpenRouter / 百度 / 小牛 / Google / Microsoft / DeepL / LibreTranslate / 自定义

### 点词查词
- 播放时点按字幕中的单词弹出词典释义（有道词典 / 微软免费翻译）
- 释义含音标（可点击播放发音）、考试标签、词形变化、网络释义
- 播放器内深色半透明磨砂弹窗，不遮挡视频
- 查词时静默暂停播放（不唤起控制层），关闭弹窗自动恢复

### 生词本 + 墨墨背单词同步
- 查词弹窗一键加入生词本，本地缓存释义（离线可查）
- 生词本卡片页：单词 + 音标 + 释义预览 + 日期
- 批量多选删除 / 同步
- 一键同步到墨墨背单词云词本（`//` 前缀自动还原原形：looked → look）
- 未同步筛选 + 懒加载

### 学习中心
- 设置一级入口：双语阅读书架 + 生词本
- 阅读书架：收藏的双语字幕缓存，点击进入双语对照阅读页
- 三种阅读模式：双语对照 / 仅原文 / 仅译文
- 缓存自动清理（可配置阈值，阅读书架中的永不清）

### 云备份
- 支持 WebDAV（坚果云 / Nextcloud / 群晖 / AList 等）和 S3 系（AWS / R2 / B2 / MinIO / Storj 等）
- 自动定时备份 + 保留份数自动清理
- 备份内容：数据库 + 所有设置 + 翻译缓存 + 生词本 + 阅读书架 + 云配置
- 恢复后自动重连云备份

### 其他
- BiPipe 品牌化：自定义图标 + 启动屏 + 关于页
- YouTube 评论时间戳转弹幕（普通视频也能有弹幕）
- Sleep timer Toast 反馈
- 调试日志系统（`adb logcat -s Bisub`）
- 仅保留 YouTube / BiliBili / NicoNico 三个服务

## 下载安装

从 [Releases](../../releases) 页下载最新 APK，直接安装。

支持架构：arm64-v8a / armeabi-v7a / x86 / x86_64

## 配置

### 翻译引擎
设置 → 双语字幕 → Translation profile：
- 选择 Provider（如 DeepSeek），填入 API base URL、API key、Model
- 可创建多个 profile 随时切换
- 免费引擎（Google / Microsoft）零配置即可使用

### 点词查词
设置 → 双语字幕 → 点词查词：
- 词典提供商：有道词典（默认）/ 微软翻译
- 查词时暂停视频：默认开

### 云备份
设置 → 备份与恢复 → 云备份：
- 选择后端（WebDAV / S3），填入服务器地址和凭证
- 设置自动备份频率和保留份数

### 墨墨背单词同步
生词本页顶部「墨墨背单词开放 API」按钮：
- 获取 token：墨墨 App → 我的 → 更多设置 → 实验功能 → 开放 API
- 同步后生词本中的词自动加 `//` 前缀，墨墨会还原原形

## 架构

```
patches/              51 个 client patch（0001-0051）
patches-extractor/    4 个 extractor patch（0001-0004）
.github/workflows/    CI 构建工作流
.upstream-state       上游 SHA 记录
build.sh              本地构建脚本
```

CI 流程：clone 上游 PipePipeClient + PipePipeExtractor → `git am` 应用所有 patch → `./gradlew assembleDebug` → 发布 Release

上游基线：PipePipe v5.5.0（client dev `b91f008fb` + extractor main `1a09d20e`）

## 本地构建

```bash
./build.sh                           # 默认基线构建
./build.sh dev main                  # 跟随上游 dev/main
./build.sh dev main --keep-source    # 保留源码目录以便调试
```

要求：git、JDK 25、Android SDK

## 致谢

- [PipePipe](https://github.com/InfinityLoop1308/PipePipe) — NewPipe 分支，反检测优化
- [NewPipe](https://github.com/TeamNewPipe/NewPipe) — 原始项目

## 许可证

[GPL-3.0](LICENSE) — 继承自 PipePipe / NewPipe