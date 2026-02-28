# Architecture Detection Patterns

> **规则范围**: ARCH-001 到 ARCH-009
> **严重等级**: P1 (HIGH)
> **Token 优化版本**: 1,500 (原始: 2,800)

---

## ARCH-001: 生命周期违规

### 检测模式

**生命周期后访问**:
- `onDestroy()` 后访问 View → `view.findViewById(...)` → 视图已销毁
- `onStop()` 后执行耗时操作 → 后台任务继续运行
- Fragment `onDestroyView()` 后访问 `binding` → 内存泄漏

**生命周期前操作**:
- `onCreate()` 前 View 未初始化 → 访问 `binding.root` → NPE
- 构造函数中访问 View → View 尚未创建

### 修复建议

1. **Lifecycle-aware 组件**: → `DefaultLifecycleObserver`
2. **生命周期感知协程**: → `lifecycleScope.launch { repeatOnLifecycle(...) }`
3. **Flow 收集**: → `lifecycle.repeatOnLifecycle(STARTED) { flow.collect { } }`
4. **Fragment**: → 在 `onDestroyView()` 中置空 `binding`

---

## ARCH-002: ViewModel 误用

### 检测模式

**ViewModel 持有 View**:
- `viewModel.context` → ViewModel 不应持有 Context
- `viewModel.activity` → 导致内存泄漏
- `viewModel.view` → 违反 MVVM 架构

**ViewModel 中访问 Android API**:
- `ViewModel` 中调用 `getString()` → 不应访问 Android 资源
- `ViewModel` 中使用 `Toast` → UI 逻辑应在 Activity/Fragment

### 修复建议

1. **依赖注入**: → 通过构造函数传入 Repository/UseCase
2. **ApplicationContext**: → 必须时使用 `Application` Context (而非 Activity)
3. **事件模式**: → 使用 `Channel`/`SharedFlow` 向 UI 发送事件

---

## ARCH-003: Fragment 反模式

### 检测模式

**Fragment 传递 Context**:
- `fragment.context` 作为参数传递 → 可能导致内存泄漏
- Fragment 构造函数接收 Context → 构造函数不应有参数

**Fragment 事务问题**:
- `fragmentTransaction.add()` 无 `addToBackStack` → 用户无法返回
- `fragmentTransaction.replace()` 频繁调用 → Fragment 重建，状态丢失
- 多个 Fragment 叠加 → 透明叠加性能问题

**过度使用 Fragment**:
- 单纯 UI 元素使用 Fragment → 应用 `View` 或 Composable
- Fragment 嵌套 > 2 层 → 复杂度爆炸

### 修复建议

1. **传递数据**: → 使用 `Bundle` 或 `FragmentResult API`
2. **事务管理**: → 使用 KTX 扩展 `commitNow` / `commit`
3. **状态保留**: → `setRetainInstance(true)` 或 ViewModel
4. **简化**: → 简单 UI 使用 View/Compose

---

## ARCH-004: 资源硬编码

### 检测模式

**字符串硬编码**:
- `text = "Hello"` → 应使用 `R.string.hello`
- `Log.d("TAG", "Error: ...")` → 日志消息应资源化

**尺寸硬编码**:
- `layoutParams.width = 100` → 应使用 `dp` 资源
- `textView.textSize = 14f` → 应使用 `sp` 资源

**颜色硬编码**:
- `Color.parseColor("#FF0000")` → 应使用 `R.color.error`
- `0xFF0000` → 应使用颜色资源

**图标/图片硬编码**:
- 硬编码文件名 → 应使用 `R.drawable.icon_name`

### 修复建议

1. **字符串**: → `strings.xml` (支持国际化)
2. **尺寸**: → `dimens.xml` (适配不同屏幕)
3. **颜色**: → `colors.xml` (主题一致性)
4. **图标**: → `R.drawable.*` 资源引用

---

## ARCH-005: 主线程阻塞

### 检测模式

**主线程 I/O**:
- `File(path).readText()` → 文件 I/O 在主线程
- `URL("http://...").readText()` → 网络请求在主线程
- `database.query("...").execute()` → 数据库查询在主线程

**主线程计算**:
- 复杂算法（图像处理、加密）在 `onClick()` 中执行
- 大量数据解析（JSON、XML）在主线程
- `while` 循环无挂起

**同步锁**:
- `synchronized` 块在主线程 → 可能导致 ANR
- `wait()` / `sleep()` 在主线程 → 直接 ANR

### 修复建议

1. **I/O 操作**: → `Dispatchers.IO` + `withContext`
2. **网络**: → Retrofit + 协程
3. **数据库**: → Room + 挂起函数
4. **计算密集**: → `Dispatchers.Default`

---

## ARCH-006: 弃用 API 使用

### 检测模式

**已弃用 API**:
- `startActivityForResult(...)` → 使用 `Activity Contract`
- `onActivityResult(...)` → 使用 `Activity Contract`
- `AsyncTask` → 使用协程
- `findViewById` 频繁调用 → 使用 View Binding / Compose
- `ActivityResultContracts.GetContent()` → 新的 Contract API

**过时权限**:
- `requestPermissions(...)` → 使用 `PermissionContract`
- `onRequestPermissionsResult` → 使用 Contract

### 修复建议

1. **Activity Result**: → `registerForActivityResult(Contract)`
2. **协程**: → 替代 AsyncTask/Thread
3. **ViewBinding**: → 替代 findViewById
4. **Permission**: → `registerForActivityResult(RequestPermission())`

---

## ARCH-007: 权限处理缺陷

### 检测模式

**无运行时检查**:
- 直接访问敏感 API（相机、位置）无 `checkSelfPermission`
- 请求权限后立即使用（未等待回调）

**无合理说明**:
- 请求权限但未调用 `shouldShowRequestPermissionRationale`
- 用户拒绝后仍请求（无"永久拒绝"处理）

**条件权限**:
- 核心功能需要的权限被拒绝 → 无降级方案

### 修复建议

1. **检查**: → `ContextCompat.checkSelfPermission` → 请求 → 处理结果
2. **说明**: → `shouldShowRequestPermissionRationale` → 显示 UI 说明
3. **降级**: → 权限被拒绝时提供替代功能（如"手动上传"替代"自动拍照"）

---

## ARCH-008: 配置变更问题

### 检测模式

**状态丢失**:
- 屏幕旋转后数据消失 → 未保存状态
- `ViewModel` 未使用 → 重建时状态丢失
- `onSaveInstanceState` 未实现 → 系统杀死进程后数据丢失

**重复创建**:
- 配置变更为每个对象创建新对象 → 性能问题
- 在 `onCreate` 中初始化昂贵资源 → 重复初始化

### 修复建议

1. **ViewModel**: → 自动在配置变更时存活
2. **SavedStateHandle**: → 保存进程死亡时的状态
3. **onSaveInstanceState**: → 保存少量关键数据
4. **单例**: → 使用 `by viewModels()` 避免重复创建

---

## ARCH-009: View Binding 违规

### 检测模式

**频繁 findViewById**:
- 同一 View 多次调用 `findViewById` → 性能浪费
- `findViewById` 每次返回 null 检查 → 代码冗余

**View 缓存问题**:
- ViewHolder 未缓存 View → RecyclerView 性能问题
- `convertView` 为 null 时每次重新 findViewById

### 修复建议

1. **ViewBinding**: → 每个布局生成绑定类
2. **数据绑定**: → `DataBindingUtil.setContentView`
3. **Kotlin Android Extensions** (已弃用): → 迁移到 ViewBinding
4. **ViewHolder**: → 缓存所有子 View

---

## 检测优先级

| 规则 | 检测优先级 | 影响 |
|------|-----------|------|
| ARCH-005 | 🔴 最高 | 主线程阻塞导致 ANR |
| ARCH-001 | 🔴 最高 | 生命周期违规导致崩溃/泄漏 |
| ARCH-006 | 🟠 高 | 弃用 API 将在未来版本失效 |
| ARCH-002 | 🟠 高 | ViewModel 误用导致架构混乱 |
| ARCH-007 | 🟡 中 | 权限问题影响用户体验 |
| ARCH-003 | 🟡 中 | Fragment 反模式导致内存泄漏 |
| ARCH-008 | 🟡 中 | 配置变更导致状态丢失 |
| ARCH-009 | 🟢 低 | ViewBinding 问题影响性能 |
| ARCH-004 | 🟢 低 | 资源硬编码影响可维护性 |

---

## Token 优化说明

**原始版本**: 2,800 tokens (321 行，200 行代码示例 = 62.3%)
**优化版本**: 1,500 tokens (纯检测模式，无冗余代码示例)
**节省**: 46%
