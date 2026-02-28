# Release Checklist - 发布检查清单

**版本**: v1.0
**最后更新**: 2025-02-28
**适用**: 所有 Claude Code 插件发布

---

## 📋 发布前准备

### Phase 1: 代码完成确认

- [ ] **功能实现完成**
  - [ ] 所有代码改动已提交
  - [ ] 测试用例已创建并验证
  - [ ] 文档已更新（CHANGELOG, README, 设计文档等）

- [ ] **版本文件准备** - ⚠️ **关键步骤**
  - [ ] `.claude/plugin-manifest.json` - 版本号已更新
  - [ ] `.claude-plugin/plugin.json` - 版本号已更新
  - [ ] `.claude-plugin/marketplace.json` - 版本号和描述已更新
  - [ ] 所有版本文件中的版本号一致

**验证命令**:
```bash
# 检查所有版本文件是否一致
grep -h '"version"' .claude/plugin-manifest.json .claude-plugin/plugin.json .claude-plugin/marketplace.json
# 应该全部显示相同的版本号
```

---

### Phase 2: 提交代码

- [ ] **最终检查**
  - [ ] `git status` - 工作目录干净
  - [ ] `git diff` - 确认所有改动都已提交
  - [ ] `git log --oneline -5` - 确认提交历史

- [ ] **推送代码到远程**
  ```bash
  git push origin main
  ```

- [ ] **验证推送成功**
  ```bash
  git rev-parse HEAD == git rev-parse origin/main
  # 应该输出相同
  ```

---

### Phase 3: 创建 Git Tag

- [ ] **确认当前 HEAD 正确**
  ```bash
  git log --oneline -1
  # 应该显示最新的提交
  ```

- [ ] **创建 annotated tag**
  ```bash
  git tag -a v{VERSION} -m "Release v{VERSION} - {简短描述}"
  ```

- [ ] **推送 tag 到远程**
  ```bash
  git push origin v{VERSION}
  ```

- [ ] **验证 tag 已推送**
  ```bash
  git ls-remote --tags origin | grep v{VERSION}
  # 应该看到 tag 引用
  ```

**⚠️ 注意**: 创建 tag 后不要再推送新提交到 main，否则需要移动 tag

---

### Phase 4: 创建 GitHub Release

- [ ] **删除旧的 Release (如果存在)**
  ```bash
  gh release delete v{VERSION} -y
  ```

- [ ] **准备 Release notes**
  - [ ] 主要改进说明
  - [ ] 功能列表
  - [ ] 改进数据（如果有量化指标）
  - [ ] 安装/升级步骤
  - [ ] 文档链接

- [ ] **创建 GitHub Release**
  ```bash
  gh release create v{VERSION} \
    --title "v{VERSION} - {标题}" \
    --notes-file RELEASE_NOTES.md
  ```

- [ ] **验证 Release 创建成功**
  ```bash
  gh release view v{VERSION}
  # 应该显示完整的 Release 信息
  ```

---

### Phase 5: 验证发布

- [ ] **本地验证**
  ```bash
  # 1. 检查 tag 位置
  git log v{VERSION} --oneline -1

  # 2. 检查版本文件
  git show v{VERSION}:.claude-plugin/plugin.json | grep version

  # 3. 验证同步状态
  git rev-parse HEAD == git rev-parse origin/main
  ```

- [ ] **远程验证**
  ```bash
  # 1. 检查 GitHub Release 页面
  gh release view v{VERSION} --web

  # 2. 检查 tag 已推送
  git ls-remote --tags origin | grep v{VERSION}
  ```

- [ ] **内容验证**
  - [ ] Release URL 可访问
  - [ ] Source code zip 可下载
  - [ ] Release notes 显示正确
  - [ ] 版本号显示正确

---

## 🔧 v3.0.2 遇到的问题与解决方案

### 问题 1: 版本文件未完全更新

**问题描述**:
- 只更新了 `.claude/plugin-manifest.json`
- 忘记更新 `.claude-plugin/plugin.json` 和 `.claude-plugin/marketplace.json`
- 导致用户看到不一致的版本信息

**解决方案**:
- ✅ 在 checklist 中明确列出所有需要更新的版本文件
- ✅ 添加验证命令确保所有版本文件一致

**预防措施**:
```bash
# 发布前必须执行此命令
grep -h '"version"' .claude/plugin-manifest.json .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

---

### 问题 2: Git tag 提前创建

**问题描述**:
- 在完成所有工作之前就创建了 tag
- 后续添加文档提交后，tag 指向了旧的 commit

**解决方案**:
- ✅ 在 checklist 中明确 tag 创建时机（在所有代码推送之后）
- ✅ 强调 tag 创建后不要再推送新提交

**预防措施**:
- 按顺序执行：代码完成 → 推送代码 → 创建 tag → 推送 tag
- 如果需要后续提交，必须移动 tag

---

### 问题 3: Tag 与 HEAD 不一致

**问题描述**:
- v3.0.2 tag 指向 e068c87
- 当前 HEAD 是 b8d2ff4（多了一个文档提交）
- 导致用户看到的是旧版本信息

**解决方案**:
- ✅ 删除旧的本地和远程 tag
- ✅ 在最新 HEAD 重新创建 tag
- ✅ 删除并重新创建 GitHub Release

**预防措施**:
```bash
# 如果 tag 创建后又有新提交，必须移动 tag
git tag -d v{VERSION}
git push origin :refs/tags/v{VERSION}
git tag -a v{VERSION} -m "Release v{VERSION}" HEAD
git push origin v{VERSION}
gh release delete v{VERSION} -y
gh release create v{VERSION} ...
```

---

### 问题 4: GitHub Release 未创建

**问题描述**:
- 只创建了 git tag
- 没有创建对应的 GitHub Release
- 用户无法从 GitHub 页面下载

**解决方案**:
- ✅ 在 checklist 中明确 GitHub Release 创建步骤
- ✅ 提供完整的 gh release 命令示例

**预防措施**:
- Tag 创建后立即创建 GitHub Release
- 验证 Release URL 可访问

---

### 问题 5: Plugin discover 显示旧版本

**问题描述**:
- 用户在 `/plugin discover` 中看到的是 3.0.0 而不是 3.0.2
- 原因是 tag 指向的不是最新提交

**解决方案**:
- ✅ 移动 tag 到最新 HEAD
- ✅ 重新创建 GitHub Release

**预防措施**:
- 确保 tag 指向最新的 HEAD
- 确保 GitHub Release 也指向最新的 tag

---

## 📊 标准发布流程

### 顺序执行（不可跳过）

```bash
# 1. 代码完成并提交
git add .
git commit -m "chore: release v{VERSION}"

# 2. 推送代码
git push origin main

# 3. 验证所有版本文件
grep -h '"version"' .claude/plugin-manifest.json .claude-plugin/plugin.json .claude-plugin/marketplace.json

# 4. 创建 tag
git tag -a v{VERSION} -m "Release v{VERSION}"

# 5. 推送 tag
git push origin v{VERSION}

# 6. 创建 GitHub Release
gh release create v{VERSION} --title "v{VERSION}" --notes "Release notes..."

# 7. 验证
gh release view v{VERSION}
git log v{VERSION} --oneline -1
```

---

## 🚨 常见错误与处理

### 错误 1: 版本文件不一致

**症状**:
```bash
grep -h '"version"' .claude/plugin-manifest.json .claude-plugin/plugin.json
# 输出不同的版本号
```

**处理**:
1. 更新所有版本文件到相同版本号
2. 重新提交
3. 重新创建 tag（如果已创建）

---

### 错误 2: Tag 已存在

**症状**:
```bash
git tag -a v{VERSION}
# error: tag 'v{VERSION}' already exists
```

**处理**:
```bash
# 删除旧的 tag
git tag -d v{VERSION}
git push origin :refs/tags/v{VERSION}

# 创建新的 tag
git tag -a v{VERSION} -m "Release v{VERSION}"
git push origin v{VERSION}
```

---

### 错误 3: Tag 创建后又有新提交

**症状**:
```bash
git log v{VERSION}..HEAD --oneline
# 显示有未包含在 tag 中的提交
```

**处理**:
```bash
# 选项 1: 移动 tag（推荐）
git tag -d v{VERSION}
git push origin :refs/tags/v{VERSION}
git tag -a v{VERSION} -m "Release v{VERSION}" HEAD
git push origin v{VERSION}
gh release delete v{VERSION} -y
gh release create v{VERSION} ...

# 选项 2: 撤销新提交（不推荐）
git reset --hard v{VERSION}
```

---

### 错误 4: Release 已存在

**症状**:
```bash
gh release create v{VERSION}
# error: Release already exists
```

**处理**:
```bash
# 删除旧 Release
gh release delete v{VERSION} -y

# 重新创建
gh release create v{VERSION} ...
```

---

## ✅ 发布后检查

- [ ] **本地检查**
  - [ ] `git status` - 干净
  - [ ] `git tag -l | grep v{VERSION}` - tag 存在
  - [ ] `git log v{VERSION} --oneline -1` - tag 指向正确

- [ ] **远程检查**
  - [ ] `git ls-remote --tags origin | grep v{VERSION}` - tag 已推送
  - [ ] `gh release view v{VERSION}` - Release 存在
  - [ ] 浏览器访问 Release URL - 页面正常

- [ ] **内容检查**
  - [ ] 版本号显示正确
  - [ ] Release notes 完整
  - [ ] 下载链接可用
  - [ ] 文档链接正确

---

## 📝 发布记录模板

```markdown
## Release v{VERSION}

### 发布日期
YYYY-MM-DD

### 提交
- 共 {N} 个提交
- Tag: {COMMIT_HASH}
- Release: https://github.com/{owner}/{repo}/releases/tag/v{VERSION}

### 主要改进
- 改进 1
- 改进 2
- 改进 3

### 遇到的问题
- 问题 1 → 解决方案
- 问题 2 → 解决方案

### 发布检查项
- [x] 版本文件更新
- [x] 代码推送
- [x] Tag 创建
- [x] Tag 推送
- [x] Release 创建
- [x] 验证完成

### 下次改进
- 改进点 1
- 改进点 2
```

---

## 🎯 最佳实践

### DO ✅

1. **按顺序执行** checklist 中的每个步骤
2. **每个阶段都要验证**再进入下一阶段
3. **使用自动化命令**减少手动操作错误
4. **详细记录 Release notes**
5. **发布后立即验证**所有链接和内容

### DON'T ❌

1. **不要提前创建 tag** - 在所有工作完成之前
2. **不要跳过验证步骤** - 节费的时间会节省更多的时间
3. **不要忘记更新所有版本文件** - 使用 grep 命令检查
4. **不要在 tag 创建后推送新提交** - 除非移动 tag
5. **不要忽略本地与远程的同步** - 使用 git rev-parse 验证

---

## 🔄 持续改进

每次发布后更新此文档：
- 记录遇到的新问题
- 添加新的检查项
- 改进流程和命令
- 更新最佳实践

---

**文档维护**: 每次发布后更新
**版本历史**:
- v1.0 (2025-02-28) - 初始版本，基于 v3.0.2 发布经验
