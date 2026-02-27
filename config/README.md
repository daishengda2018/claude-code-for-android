# Static Check Configurations

本目录包含从 WeShare-Android 项目迁移的静态代码检查配置。

## 📁 目录结构

```
config/
├── detekt/
│   └── detekt.yml           ← Kotlin 静态分析配置
├── checkstyle/
│   └── checkstyle.xml       ← Java 代码风格配置
└── README.md                ← 本文档
```

## 🔧 配置说明

### 1. Detekt (Kotlin 静态分析)

**文件：** `detekt/detekt.yml` (818 行)

**用途：**
- Kotlin 代码质量检查
- 复杂度分析
- 代码异味检测
- 协程使用检查

**主要规则类别：**
- `complexity` - 复杂度检查（LargeClass, LongMethod, NestedBlockDepth 等）
- `coroutines` - 协程使用检查（InjectDispatcher, SleepInsteadOfDelay 等）
- `style` - 代码风格（MagicNumber, OptionalWhenBraces 等）
- `potential-bugs` - 潜在 Bug（AvoidNotNullAssertionOnNullableProperty 等）

**重要配置：**
```yaml
complexity:
  LargeClass:
    active: true
    threshold: 800        # 从 600 放宽到 800
  LongMethod:
    active: true
    threshold: 100        # 从 60 放宽到 100
  NestedBlockDepth:
    active: true
    threshold: 4

coroutines:
  InjectDispatcher:
    active: true
  RedundantSuspendModifier:
    active: true
  SleepInsteadOfDelay:
    active: true
```

### 2. Checkstyle (Java 代码风格)

**文件：** `checkstyle/checkstyle.xml` (132 行)

**用途：**
- Java 代码风格检查
- 基于 Effective Java 的最佳实践
- 命名规范检查

**主要规则：**
- `EqualsHashCode` - 覆盖 equals 时必须覆盖 hashCode
- `InterfaceIsType` - 接口只用于定义类型
- `NestedIfDepth` - if 嵌套深度检查（最大 3 层）
- `JavadocType` - 公开 API 需要 Javadoc
- `AvoidStarImport` - 禁止使用 * 导入
- `EmptyBlock` - catch 块不能为空
- `NeedBraces` - if/else/for 必须使用大括号

### 3. Pre-commit Hook

**文件：** `scripts/pre-commit` (已复制)

**用途：**
- Git 提交前自动运行静态检查
- 支持 Detekt 和 Checkstyle
- 只检查修改的 Kotlin/Java 文件

**工作流程：**
```bash
git commit
  ↓
pre-commit hook 运行
  ↓
检测 Kotlin 文件 → 运行 Detekt
检测 Java 文件 → 运行 Checkstyle
  ↓
检查通过 → 允许提交
检查失败 → 阻止提交
```

## 🎯 与 Plugin 的集成

### 方式 1：参考 Detekt/Checkstyle 规则

将 Detekt 和 Checkstyle 的检查规则整合到 `android-code-reviewer.md` agent 中：

```markdown
## 复杂度检查

参考 Detekt 配置：
- LargeClass: > 800 行
- LongMethod: > 100 行
- NestedBlockDepth: > 4 层

检测示例：
```kotlin
// ❌ 过长的方法
fun tooLongMethod() {
    // 100+ 行代码
}

// ✅ 拆分为小方法
fun focusedMethod() {
    // 简短 focused
}
```
```

### 方式 2：互补使用

- **Plugin (AI)** - 理解代码语义，检测复杂问题
- **Detekt/Checkstyle (工具)** - 精确模式匹配，强制风格统一

**建议工作流：**
```bash
# 1. AI Review
/android-code-review --target staged

# 2. Detekt/Checkstyle 验证
./gradlew detekt checkstyle

# 3. 提交
git commit  # pre-commit hook 自动运行检查
```

## 📋 使用建议

### 在 test-android 项目中集成

1. **复制配置到测试项目**
```bash
# 将配置复制到 test-android/
cp -r config/detekt test-android/
cp -r config/checkstyle test-android/
cp config/detekt/detekt.yml test-android/detekt.yml
cp config/checkstyle/checkstyle.xml test-android/checkstyle.xml
```

2. **在 build.gradle 中添加 Detekt 插件**
```gradle
plugins {
    id 'io.gitlab.arturbosch.detekt' version '1.23.1'
}

detekt {
    config = files("$rootDir/detekt.yml")
    buildUponDefaultConfig = true
}
```

3. **运行检查**
```bash
cd test-android/
./gradlew detekt
./gradlew checkstyle
```

### 验证 Plugin 的检查能力

使用这些配置中的测试用例验证 `android-code-reviewer` agent 是否能检测到相同的问题：

**示例：**
```kotlin
// 测试 LargeClass 规则（阈值 800 行）
// 在 test-android 中创建一个 > 800 行的类
// 运行 /android-code-review
// 验证是否报告 "Class too large"
```

## 🔄 维护

### 更新配置

当 WeShare-Android 项目更新配置时：

```bash
# 重新复制
cp /path/to/WeShare-Android/config/detekt/detekt.yml config/detekt/
cp /path/to/WeShare-Android/config/checkstyle/checkstyle.xml config/checkstyle/

# 提交更新
git add config/
git commit -m "chore: Update static check configs from WeShare-Android"
```

### 同步规则到 Plugin

当 Detekt/Checkstyle 添加新规则时，考虑将这些规则添加到 `android-code-reviewer.md`：

1. 查看新规则的文档
2. 编写测试用例
3. 更新 agent 检测逻辑
4. 验证检测效果

## 📚 参考资料

- [Detekt 官方文档](https://detekt.dev/)
- [Checkstyle 官方文档](https://checkstyle.sourceforge.io/)
- [Effective Java (Joshua Bloch)](https://www.oreilly.com/library/view/effective-java/9780134686097/)

---

**来源：** WeShare-Android 项目
**迁移日期：** 2026-02-27
**维护者：** daishengda2018
