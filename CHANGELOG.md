# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- 移除 `.claude/settings.local.json` 中高風險的命令白名單項目，包括任意 Python 執行、廣泛文件讀取以及敏感路徑存取，並清理冗餘項目。
- 移除 `.qwen/settings.json` 中高風險的命令白名單項目，防止潛在的任意代碼執行與敏感資訊外洩。
- 清理白名單中無效的代碼片段雜訊。
