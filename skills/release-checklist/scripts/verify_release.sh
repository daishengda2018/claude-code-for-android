#!/bin/bash
# Claude Plugin Release Verification Script
# 自动执行发布检查清单验证

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0
BLOCKER_FAILURES=0

# 辅助函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED_CHECKS++))
    ((TOTAL_CHECKS++))
}

log_failure() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED_CHECKS++))
    ((TOTAL_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNING_CHECKS++))
    ((TOTAL_CHECKS++))
}

log_blocker() {
    echo -e "${RED}🚫 BLOCKER FAILURE: $1${NC}"
    ((BLOCKER_FAILURES++))
    log_failure "$1"
}

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_blocker "当前目录不是 git 仓库"
    exit 1
fi

# 检查是否在根目录（查找 .claude-plugin 目录）
if [ ! -d ".claude-plugin" ]; then
    log_blocker ".claude-plugin/ 目录不存在，请在插件根目录运行此脚本"
    exit 1
fi

echo "=========================================="
echo "  Claude Plugin Release Verification"
echo "=========================================="
echo ""

# 获取版本号
VERSION=$(grep '"version"' .claude-plugin/plugin.json 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
if [ -z "$VERSION" ]; then
    log_blocker "无法从 plugin.json 提取版本号"
    exit 1
fi
log_info "目标版本: v$VERSION"
echo ""

# ========================================
# Section 1: Structure Validation (BLOCKER)
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 1: Structure Validation (BLOCKER)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查 plugin.json
if [ -f ".claude-plugin/plugin.json" ]; then
    log_success "plugin.json 存在"
else
    log_blocker "plugin.json 不存在"
fi

# 检查合规的运行时目录
VALID_DIRS_FOUND=false
for dir in agents commands skills; do
    if [ -d ".claude-plugin/$dir" ]; then
        log_success "存在合规目录: $dir/"
        VALID_DIRS_FOUND=true
    fi
done

if [ "$VALID_DIRS_FOUND" = false ]; then
    log_warning "未找到任何运行时目录 (agents/commands/skills)"
fi

# 检查不合规的发布目录
EXTRA_DIRS=$(find .claude-plugin -maxdepth 1 -type d ! -name agents ! -name commands ! -name skills ! -name .claude-plugin ! -name ".*" -printf "%f " 2>/dev/null)
if [ -n "$EXTRA_DIRS" ]; then
    log_blocker "存在不合规的发布目录: $EXTRA_DIRS"
else
    log_success "无不合规的发布目录"
fi

# 验证 skills/ 目录中的 SKILL.md
if [ -d ".claude-plugin/skills" ]; then
    SKILL_COUNT=$(find .claude-plugin/skills -maxdepth 2 -type f -name "SKILL.md" 2>/dev/null | wc -l)
    DIR_COUNT=$(find .claude-plugin/skills -maxdepth 1 -type d ! -name skills ! -name ".*" 2>/dev/null | wc -l)

    log_info "SKILL.md 文件数: $SKILL_COUNT"
    log_info "Skills 子目录数: $DIR_COUNT"

    if [ "$SKILL_COUNT" -eq "$DIR_COUNT" ]; then
        log_success "每个 skills 子目录都包含 SKILL.md"
    else
        log_blocker "SKILL.md 数量 ($SKILL_COUNT) 与子目录数量 ($DIR_COUNT) 不匹配"
    fi

    # 检查具体的缺失 SKILL.md
    for dir in .claude-plugin/skills/*/; do
        if [ -d "$dir" ]; then
            dir_name=$(basename "$dir")
            if [ ! -f "$dir/SKILL.md" ]; then
                log_blocker "缺少 SKILL.md: skills/$dir_name/"
            fi
        fi
    done
fi

# 检查 marketplace.json 版本匹配
if [ -f ".claude-plugin/marketplace.json" ]; then
    MARKET_VERSION=$(grep '"version"' .claude-plugin/marketplace.json | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    if [ "$VERSION" = "$MARKET_VERSION" ]; then
        log_success "plugin.json 和 marketplace.json 版本一致"
    else
        log_blocker "版本不匹配: plugin.json=$VERSION, marketplace.json=$MARKET_VERSION"
    fi
fi

echo ""

# ========================================
# Section 2: Runtime Compatibility (BLOCKER)
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 2: Runtime Compatibility (BLOCKER)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查绝对路径
CURRENT_DIR=$(pwd)
ABSOLUTE_PATHS=$(grep -r "$CURRENT_DIR" .claude-plugin/agents/ .claude-plugin/commands/ .claude-plugin/skills/ 2>/dev/null || true)

if [ -n "$ABSOLUTE_PATHS" ]; then
    log_blocker "发现绝对路径（必须使用相对路径）:"
    echo "$ABSOLUTE_PATHS" | head -5
    if [ $(echo "$ABSOLUTE_PATHS" | wc -l) -gt 5 ]; then
        echo "  ... 还有更多"
    fi
else
    log_success "无绝对路径，使用相对路径"
fi

# 检查 .claude/ 目录
if [ -d ".claude" ] && [ "$(ls -A .claude 2>/dev/null)" ]; then
    log_warning ".claude/ 目录存在本地开发内容（发布时不会包含）"
else
    log_success ".claude/ 目录为空或不存在"
fi

echo ""

# ========================================
# Section 3: Version Integrity
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 3: Version Integrity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查 CHANGELOG.md
if [ -f "CHANGELOG.md" ]; then
    if grep -q "$VERSION" CHANGELOG.md; then
        log_success "CHANGELOG.md 包含版本 $VERSION"
    else
        log_warning "CHANGELOG.md 未包含版本 $VERSION 的更新内容"
    fi
else
    log_warning "CHANGELOG.md 文件不存在"
fi

# 检查 README.md
if [ -f "README.md" ]; then
    log_success "README.md 存在"
else
    log_warning "README.md 文件不存在"
fi

echo ""

# ========================================
# Section 4: Git Sync Validation (BLOCKER)
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 4: Git Sync Validation (BLOCKER)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查工作区状态
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    log_blocker "工作区不干净，存在未提交或未跟踪的文件:"
    git status --short
else
    log_success "工作区干净"
fi

# 检查当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    log_success "在主分支: $CURRENT_BRANCH"
else
    log_warning "当前不在主分支: $CURRENT_BRANCH"
fi

# 检查本地和远程 HEAD 是否匹配
LOCAL_HEAD=$(git rev-parse HEAD 2>/dev/null)
REMOTE_HEAD=$(git rev-parse origin/$CURRENT_BRANCH 2>/dev/null || echo "")

if [ -z "$REMOTE_HEAD" ]; then
    log_warning "无法获取远程分支 origin/$CURRENT_BRANCH"
elif [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
    log_success "本地和远程 HEAD 一致"
else
    log_blocker "本地和远程 HEAD 不一致"
    echo "  本地: $LOCAL_HEAD"
    echo "  远程: $REMOTE_HEAD"
fi

echo ""

# ========================================
# Section 5: Tag Check
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 5: Tag Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查远程是否已存在该标签
if git ls-remote --tags origin 2>/dev/null | grep -q "v$VERSION"; then
    log_failure "远程已存在标签 v$VERSION"
else
    log_success "远程不存在标签 v$VERSION，可以创建"
fi

echo ""

# ========================================
# Summary Report
# ========================================
echo "=========================================="
echo "  Summary Report"
echo "=========================================="
echo ""
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo -e "Warnings: ${YELLOW}$WARNING_CHECKS${NC}"
echo ""

if [ $BLOCKER_FAILURES -gt 0 ]; then
    echo -e "${RED}🚫 STATUS: FAILED - $BLOCKER_FAILURES BLOCKER issue(s) found${NC}"
    echo ""
    echo "必须修复所有 BLOCKER 问题后才能继续发布流程。"
    exit 1
else
    echo -e "${GREEN}✅ STATUS: PASSED - Ready for release${NC}"
    echo ""
    echo "下一步操作:"
    echo "  1. 创建标签: git tag -a v$VERSION -m 'Release v$VERSION'"
    echo "  2. 推送标签: git push origin v$VERSION"
    echo "  3. 创建 GitHub Release"
    exit 0
fi
