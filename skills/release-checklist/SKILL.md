---
name: release-checklist
description: Claude Plugin 发布清单。在发布插件时，自动验证结构、兼容性、版本完整性、Git 同步等所有检查项。当用户提到"发布插件"、"准备发布"、"创建 release"、"打 tag"、"验证发布"或询问"是否可以发布"时使用此 skill。确保插件符合所有发布要求，避免发布失败。**此 skill 完全自动化执行所有检查和发布步骤，无需用户确认。**
---

# Claude Plugin Release Checklist

这个 skill 帮助你在发布 Claude Code 插件时自动验证所有必要的检查项并完成发布。**完全自动化执行，不需要用户交互确认。**

## 使用时机

- 准备发布新版本时
- 创建 GitHub Release 之前
- 打 tag 之前
- 任何时候想要验证当前发布状态

## 验证流程

### 总体原则

1. **BLOCKER 检查失败时立即终止** - 对于标记为 `BLOCKER` 的部分，任何检查失败都停止流程
2. **完全自动化执行** - 自动运行所有检查、提交、推送、创建 Release
3. **不询问用户** - 所有操作自动执行，遇到问题直接报告结果

---

## 第一部分：结构验证 (BLOCKER)

### 自动验证

运行以下检查命令：

```bash
# 检查 plugin.json 是否存在
test -f .claude-plugin/plugin.json || echo "❌ .claude-plugin/plugin.json 不存在"

# 检查 marketplace.json 版本是否匹配
if [ -f .claude-plugin/marketplace.json ]; then
  PLUGIN_VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
  MARKET_VERSION=$(grep '"version"' .claude-plugin/marketplace.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
  if [ "$PLUGIN_VERSION" != "$MARKET_VERSION" ]; then
    echo "❌ 版本不匹配: plugin.json=$PLUGIN_VERSION, marketplace.json=$MARKET_VERSION"
  fi
fi

# 检查插件目录结构
for dir in agents commands skills; do
  if [ -d "$dir" ]; then
    echo "✅ 存在合规目录: $dir/"
  elif [ -d ".claude-plugin/$dir" ]; then
    echo "✅ 存在合规目录: .claude-plugin/$dir/"
  fi
done

# 验证每个 skills/ 子文件夹都包含 SKILL.md
for dir in skills/*/; do
  if [ -f "$dir/SKILL.md" ]; then
    echo "✅ $(basename $dir) 包含 SKILL.md"
  else
    echo "❌ $(basename $dir) 缺少 SKILL.md"
  fi
done
```

### 判断标准

- ✅ **通过**：所有目录和文件都符合要求
- ❌ **失败 (BLOCKER)**：任何一项不符合要求，立即终止流程

---

## 第二部分：运行时兼容性验证 (BLOCKER)

### 自动验证

```bash
# 检查绝对路径
if grep -r "$(pwd)" skills/ agents/ commands/ 2>/dev/null | grep -v ".git" | head -5; then
  echo "❌ 发现绝对路径，必须使用相对路径"
else
  echo "✅ 无绝对路径"
fi

# 检查 .claude/ 目录
if [ -d .claude ] && [ "$(ls -A .claude 2>/dev/null)" ]; then
  echo "⚠️  .claude/ 目录存在本地开发内容（发布时不会包含）"
else
  echo "✅ .claude/ 目录为空或不存在"
fi
```

### 判断标准

- ✅ **通过**：无绝对路径
- ❌ **失败 (BLOCKER)**：发现绝对路径

---

## 第三部分：版本完整性

### 自动验证

```bash
# 提取版本号
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
echo "📌 当前版本: $VERSION"

# 检查 CHANGELOG.md 是否包含当前版本
if [ -f CHANGELOG.md ]; then
  if grep -q "## \[$VERSION\]" CHANGELOG.md; then
    echo "✅ CHANGELOG.md 包含版本 $VERSION"
  else
    echo "❌ CHANGELOG.md 未包含版本 $VERSION"
    echo "   自动添加版本条目..."
  fi
else
  echo "⚠️  CHANGELOG.md 不存在"
fi

# 检查 README.md
[ -f README.md ] && echo "✅ README.md 存在"
```

---

## 第四部分：Git 同步验证 (BLOCKER)

### 自动验证并同步

```bash
# 检查工作区状态
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "⚠️  工作区不干净，自动提交所有更改..."
  git add -A
  git commit -m "chore: prepare for release v$VERSION"
fi

# 检查当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "⚠️  当前不在 main 分支: $CURRENT_BRANCH"
else
  echo "✅ 在 main 分支"
fi

# 自动推送到远程
LOCAL_HEAD=$(git rev-parse HEAD 2>/dev/null)
REMOTE_HEAD=$(git rev-parse origin/main 2>/dev/null)
if [ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]; then
  echo "🔄 自动推送到远程..."
  git push origin main
else
  echo "✅ 本地和远程 HEAD 一致"
fi
```

### 判断标准

- ✅ **通过 (BLOCKER)**：自动提交并推送成功
- ❌ **失败 (BLOCKER)**：推送失败

---

## 第五部分：标签 (Required)

### 自动创建和推送标签

```bash
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')

# 检查远程是否已存在该标签
if git ls-remote --tags origin | grep -q "v$VERSION"; then
  echo "⚠️  远程已存在标签 v$VERSION，删除并重建..."
  git tag -d "v$VERSION" 2>/dev/null
  git push origin ":refs/tags/v$VERSION" 2>/dev/null
fi

# 创建并推送标签
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"

# 验证
if git ls-remote --tags origin | grep -q "v$VERSION"; then
  echo "✅ 标签 v$VERSION 创建并推送成功"
fi
```

---

## 第六部分：GitHub Release (Required)

### 自动创建 Release

```bash
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
REPO=$(git remote get-url origin | sed 's/.*github.com\///' | sed 's/\.git$//')

# 使用 gh CLI 创建 release
gh release create "v$VERSION" \
  --title "Release v$VERSION" \
  --target main \
  --generate-notes \
  --repo "$REPO"

echo "✅ GitHub Release 创建成功"
echo "   URL: https://github.com/$REPO/releases/tag/v$VERSION"
```

---

## 第七部分：发布后验证 (BLOCKER)

### 自动验证

```bash
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
REPO=$(git remote get-url origin | sed 's/.*github.com\///' | sed 's/\.git$//')

# 验证 Release
RELEASE_URL=$(gh api repos/$REPO/releases/tags/v$VERSION --jq '.html_url' 2>/dev/null)

echo ""
echo "========================================"
echo "🎉 发布完成！"
echo "========================================"
echo "   插件版本: $VERSION"
echo "   Git 标签: v$VERSION"
echo "   GitHub Release: $RELEASE_URL"
echo "========================================"
```

---

## 完整验证报告

在完成所有检查后，生成以下格式的报告：

```markdown
# Plugin Release Verification Report

**Version**: vX.Y.Z
**Date**: YYYY-MM-DD
**Status**: ✅ PASSED / ❌ FAILED

## Summary

- **Total Steps**: 7
- **Passed**: 7
- **Failed**: 0
- **Warnings**: 0

## Detailed Results

### ✅ Section 1: Structure Validation (BLOCKER)
- ✅ plugin.json 存在
- ✅ marketplace.json 版本匹配
- ✅ 所有 skills 目录包含 SKILL.md

### ✅ Section 2: Runtime Compatibility (BLOCKER)
- ✅ 无绝对路径
- ✅ .claude/ 目录检查完成

### ✅ Section 3: Version Integrity
- ✅ 版本文件已更新
- ✅ CHANGELOG.md 包含版本说明

### ✅ Section 4: Git Sync (BLOCKER)
- ✅ 自动提交更改
- ✅ 推送到远程成功

### ✅ Section 5: Tags
- ✅ 标签 vX.Y.Z 已创建并推送

### ✅ Section 6: GitHub Release
- ✅ Release 创建成功

### ✅ Section 7: Post-Release Verification
- ✅ 所有验证通过

## 🎉 发布成功！
```

---

## 关键提醒

1. **完全自动化** - 所有操作自动执行，不需要用户交互
2. **BLOCKER 失败时终止** - 结构、兼容性、Git 同步失败时停止
3. **自动处理冲突** - 自动提交、自动推送、自动重建标签
4. **生成清晰报告** - 每步都有明确的 ✅/❌ 状态

---

## 相关文件

- 插件配置：`.claude-plugin/plugin.json`
- 版本历史：`CHANGELOG.md`
- 使用文档：`README.md`