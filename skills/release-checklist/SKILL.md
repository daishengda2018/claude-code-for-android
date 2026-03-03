---
name: release-checklist
description: Claude Plugin 发布前验证检查清单。在发布插件前，自动验证结构、兼容性、版本完整性、Git 同步等所有检查项。当用户提到"发布插件"、"准备发布"、"创建 release"、"打 tag"、"验证发布"或询问"是否可以发布"时使用此 skill。确保插件符合所有发布要求，避免发布失败。
---

# Claude Plugin Release Checklist

这个 skill 帮助你在发布 Claude Code 插件前验证所有必要的检查项。

## 使用时机

- 准备发布新版本时
- 创建 GitHub Release 之前
- 打 tag 之前
- 任何时候想要验证当前发布状态

## 验证流程

### 总体原则

1. **BLOCKER 检查失败时立即终止** - 对于标记为 `BLOCKER` 的部分，任何检查失败都应停止流程
2. **自动验证优先** - 自动运行所有可以验证的检查命令
3. **手动步骤确认** - 对于需要用户手动操作的步骤，提供指导并询问确认
4. **生成验证报告** - 清晰展示每项检查的状态

---

## 第一部分：结构验证 (BLOCKER)

### 自动验证

运行以下检查命令：

```bash
# 检查 .claude-plugin/ 目录是否存在
test -d .claude-plugin || echo "❌ .claude-plugin/ 目录不存在"

# 检查 plugin.json 是否存在
test -f .claude-plugin/plugin.json || echo "❌ plugin.json 不存在"

# 检查 marketplace.json 版本是否匹配（如果存在）
if [ -f .claude-plugin/marketplace.json ]; then
  PLUGIN_VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
  MARKET_VERSION=$(grep '"version"' .claude-plugin/marketplace.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
  if [ "$PLUGIN_VERSION" != "$MARKET_VERSION" ]; then
    echo "❌ 版本不匹配: plugin.json=$PLUGIN_VERSION, marketplace.json=$MARKET_VERSION"
  fi
fi

# 检查合规的运行时目录
for dir in agents commands skills; do
  if [ -d ".claude-plugin/$dir" ]; then
    echo "✅ 存在合规目录: $dir/"
  fi
done

# 检查是否有额外的发布目录
EXTRA_DIRS=$(find .claude-plugin -maxdepth 1 -type d ! -name agents ! -name commands ! -name skills ! -name .claude-plugin ! -name ".*" -printf "%f ")
if [ -n "$EXTRA_DIRS" ]; then
  echo "❌ 存在不合规的发布目录: $EXTRA_DIRS"
fi

# 验证每个 skills/ 子文件夹都包含 SKILL.md
SKILL_DIRS=$(find .claude-plugin/skills -maxdepth 1 -type d ! -name skills ! -name ".*" -printf "%f " 2>/dev/null)
if [ -n "$SKILL_DIRS" ]; then
  for dir in $SKILL_DIRS; do
    if [ ! -f ".claude-plugin/skills/$dir/SKILL.md" ]; then
      echo "❌ 缺少 SKILL.md: skills/$dir/"
    fi
  done
fi

# 验证命令：检查 SKILL.md 数量
SKILL_COUNT=$(find .claude-plugin/skills -type f -name "SKILL.md" 2>/dev/null | wc -l)
DIR_COUNT=$(find .claude-plugin/skills -maxdepth 1 -type d ! -name skills ! -name ".*" 2>/dev/null | wc -l)
if [ "$SKILL_COUNT" -ne "$DIR_COUNT" ]; then
  echo "❌ SKILL.md 数量 ($SKILL_COUNT) 与 skills 子目录数量 ($DIR_COUNT) 不匹配"
fi
```

### 判断标准

- ✅ **通过**：所有目录和文件都符合要求
- ❌ **失败 (BLOCKER)**：任何一项不符合要求，立即终止流程

---

## 第二部分：运行时兼容性验证 (BLOCKER)

### 自动验证

```bash
# 检查绝对路径
if grep -r "$(pwd)" .claude-plugin/agents/ .claude-plugin/commands/ .claude-plugin/skills/ 2>/dev/null; then
  echo "❌ 发现绝对路径，必须使用相对路径"
fi

# 检查 .claude/ 目录是否存在本地开发内容
if [ -d .claude ] && [ "$(ls -A .claude 2>/dev/null)" ]; then
  echo "⚠️  .claude/ 目录存在本地开发内容（发布时不会包含）"
fi
```

### 本地安装测试（需要用户确认）

```bash
# 执行本地安装测试
echo "📝 请执行以下命令进行本地安装测试："
echo "   1. /plugin install ."
echo "   2. /plugin list"
echo ""
read -p "本地安装测试是否通过？ (y/n): " INSTALL_OK
if [ "$INSTALL_OK" != "y" ]; then
  echo "❌ 本地安装测试失败"
fi
```

### 判断标准

- ✅ **通过**：无绝对路径，本地安装测试成功
- ❌ **失败 (BLOCKER)**：发现绝对路径或安装测试失败

---

## 第三部分：版本完整性

### 自动验证

```bash
# 提取版本号
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
echo "📌 当前版本: $VERSION"

# 检查 CHANGELOG.md 是否包含当前版本
if [ -f CHANGELOG.md ]; then
  if grep -q "$VERSION" CHANGELOG.md; then
    echo "✅ CHANGELOG.md 包含版本 $VERSION"
  else
    echo "❌ CHANGELOG.md 未包含版本 $VERSION 的更新内容"
  fi
else
  echo "⚠️  CHANGELOG.md 文件不存在"
fi

# 检查 README.md
if [ -f README.md ]; then
  echo "✅ README.md 存在"
  # 可以添加更详细的检查逻辑
else
  echo "⚠️  README.md 文件不存在"
fi
```

### 判断标准

- ✅ **通过**：所有版本相关文件已更新
- ⚠️  **警告**：文件缺失或未更新（建议修复但非阻塞）
- ❌ **失败**：关键文件缺失

---

## 第四部分：Git 同步验证 (BLOCKER)

### 自动验证

```bash
# 检查工作区状态
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "❌ 工作区不干净，存在未提交或未跟踪的文件："
  git status --short
else
  echo "✅ 工作区干净"
fi

# 检查当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "⚠️  当前不在 main 分支: $CURRENT_BRANCH"
else
  echo "✅ 在 main 分支"
fi

# 检查本地和远程 HEAD 是否匹配
LOCAL_HEAD=$(git rev-parse HEAD 2>/dev/null)
REMOTE_HEAD=$(git rev-parse origin/main 2>/dev/null)
if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
  echo "✅ 本地和远程 HEAD 一致"
else
  echo "❌ 本地和远程 HEAD 不一致"
  echo "   本地: $LOCAL_HEAD"
  echo "   远程: $REMOTE_HEAD"
fi
```

### 判断标准

- ✅ **通过 (BLOCKER)**：工作区干净，在 main 分支，本地远程一致
- ❌ **失败 (BLOCKER)**：任何一项不符合

---

## 第五部分：标签 (Required)

### 前置条件检查

在执行标签操作前，确保以上所有检查都通过。

### 自动验证

```bash
# 获取当前版本
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')

# 检查远程是否已存在该标签
if git ls-remote --tags origin | grep -q "v$VERSION"; then
  echo "❌ 远程已存在标签 v$VERSION"
else
  echo "✅ 远程不存在标签 v$VERSION，可以创建"
fi
```

### 创建标签（需要用户确认）

```bash
echo "📝 准备创建标签: v$VERSION"
echo "   命令: git tag -a v$VERSION -m \"Release v$VERSION\""
read -p "是否创建标签？ (y/n): " CREATE_TAG
if [ "$CREATE_TAG" = "y" ]; then
  git tag -a "v$VERSION" -m "Release v$VERSION"
  echo "✅ 标签创建成功"
  echo "📝 下一步: 推送标签到远程"
  echo "   命令: git push origin v$VERSION"
fi
```

### 推送标签（需要用户确认）

```bash
read -p "是否推送标签到远程？ (y/n): " PUSH_TAG
if [ "$PUSH_TAG" = "y" ]; then
  git push origin "v$VERSION"
  echo "✅ 标签推送成功"

  # 验证远程标签
  if git ls-remote --tags origin | grep -q "v$VERSION"; then
    echo "✅ 远程标签验证成功"
  else
    echo "❌ 远程标签验证失败"
  fi
fi
```

---

## 第六部分：GitHub Release (Required)

### 指导用户

```bash
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')

echo "📝 创建 GitHub Release："
echo "   1. 访问: https://github.com/<owner>/<repo>/releases/new"
echo "   2. 选择标签: v$VERSION"
echo "   3. 标题: Release v$VERSION"
echo "   4. 内容: 复制 CHANGELOG.md 中对应版本的内容"
echo "   5. 勾选 'Set as the latest release'"
echo ""
read -p "GitHub Release 创建完成后，按回车继续: "
```

### 验证（需要用户确认）

```bash
read -p "Release 页面是否可正常访问且源码归档可下载？ (y/n): " RELEASE_OK
if [ "$RELEASE_OK" != "y" ]; then
  echo "❌ GitHub Release 验证失败"
fi
```

---

## 第七部分：发布后验证 (BLOCKER)

### 自动验证

```bash
# 验证 Tag 指向正确的 commit
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
LATEST_COMMIT=$(git log main --oneline -1 2>/dev/null | cut -d' ' -f1)
TAG_COMMIT=$(git log "v$VERSION" --oneline -1 2>/dev/null | cut -d' ' -f1)

if [ "$LATEST_COMMIT" = "$TAG_COMMIT" ]; then
  echo "✅ Tag v$VERSION 指向最新的 main 分支 HEAD"
else
  echo "❌ Tag v$VERSION 未指向最新的 main 分支 HEAD"
  echo "   最新 commit: $LATEST_COMMIT"
  echo "   Tag commit: $TAG_COMMIT"
fi
```

### 远程安装验证（需要用户确认）

```bash
REPO_URL=$(git config --get remote.origin.url)
echo "📝 远程安装验证："
echo "   命令: /plugin install $REPO_URL"
echo ""
read -p "远程安装是否成功？ (y/n): " REMOTE_INSTALL_OK
if [ "$REMOTE_INSTALL_OK" != "y" ]; then
  echo "❌ 远程安装验证失败"
fi
```

### 功能验证（需要用户确认）

```bash
read -p "插件的 commands/agents/skills 是否可以正常加载和触发？ (y/n): " FUNCTION_OK
if [ "$FUNCTION_OK" != "y" ]; then
  echo "❌ 功能验证失败"
fi
```

---

## 验证报告格式

在完成所有检查后，生成以下格式的报告：

```markdown
# Plugin Release Verification Report

**Version**: vX.Y.Z
**Date**: YYYY-MM-DD
**Status**: ✅ PASSED / ❌ FAILED

## Summary

- **Total Checks**: 15
- **Passed**: 13
- **Failed**: 2
- **Warnings**: 1

## Detailed Results

### ✅ Section 1: Structure Validation (BLOCKER)
- ✅ .claude-plugin/ directory exists
- ✅ plugin.json exists
- ✅ All skill directories contain SKILL.md
- ...

### ❌ Section 2: Runtime Compatibility (BLOCKER)
- ❌ Absolute paths found in skills/example/SKILL.md

### ⚠️  Section 3: Version Integrity
- ⚠️  CHANGELOG.md exists but version notes are minimal

## Action Items

1. **Critical**: Remove absolute paths from skills/example/SKILL.md
2. **Recommended**: Expand CHANGELOG.md release notes

## Next Steps

- Fix critical issues
- Re-run verification
- Create tag and release
```

---

## 关键提醒

1. **BLOCKER 检查失败时立即终止**，不要继续后续流程
2. **保持顺序执行**，不要跳过任何检查项
3. **所有用户确认步骤都需要等待用户响应**
4. **生成清晰的验证报告**，便于用户了解当前状态

---

## 相关文件

- 原始检查清单：`docs/RELEASE_CHECKLIST.md`
- 插件配置：`.claude-plugin/plugin.json`
- 版本历史：`CHANGELOG.md`
- 使用文档：`README.md`
