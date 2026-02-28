# Performance Detection Patterns

> **规则范围**: PERF-001 到 PERF-008
> **严重等级**: P2 (MEDIUM)
> **Token 优化版本**: 1,200 (原始: 2,400)

---

## PERF-001: 布局低效

### 检测模式

**深层嵌套**:
- 布局层级 > 6 → 渲染性能下降
- `LinearLayout` 嵌套 `LinearLayout` → 可用 ConstraintLayout 替代

**过度绘制**:
- 背景重叠 → 多层 View 覆盖同一区域
- `android:background` 在父容器和子 View 都设置 → 过度绘制

**无重量级 View**:
- `include` 包含复杂布局 → 重复加载
- `<merge>` 未使用 → 增加层级

### 修复建议

1. **ConstraintLayout**: → 替代嵌套 LinearLayout/RelativeLayout
2. **merge**: → 使用 `<merge>` 减少层级
3. **ViewStub**: → 延迟加载不常用布局
4. **工具**: → Layout Inspector 检查过度绘制

---

## PERF-002: ANR 风险

### 检测模式

**主线程操作**:
- 主线程网络请求 → `URL(...).readText()`
- 主线程数据库查询 → `db.query(...)`
- 主线程文件 I/O → `File(...).readText()`
- 主线程同步锁 → `synchronized`, `wait()`

**耗时操作**:
- 复杂算法在主线程 → 图像处理、加密
- 大量数据解析 → JSON/XML 解析 > 100ms

### 修复建议

1. **网络**: → 协程 + `Dispatchers.IO`
2. **数据库**: → Room + 挂起函数
3. **文件**: → `withContext(Dispatchers.IO)`
4. **算法**: → `Dispatchers.Default` (计算密集)

---

## PERF-003: Bitmap 管理

### 检测模式

**内存占用**:
- 加载原图到内存 → `BitmapFactory.decodeResource` 加载 4K 图片
- 多个 Bitmap 同时加载 → OOM 崩溃
- 无采样率 → 不必要的内存占用

**内存泄漏**:
- Bitmap 缓存无清理 → 内存持续增长
- Drawable 持有 View 引用 → 泄漏

### 修复建议

1. **采样**: → `inSampleSize` 缩小图片
2. **库**: → Glide/Coil (自动缓存、采样)
3. **格式**: → 使用 `RGB_565` 替代 `ARGB_8888` (无损场景)
4. **回收**: → 使用 `LruCache` 管理缓存

---

## PERF-004: 启动性能

### 检测模式

**Application 初始化**:
- `onCreate()` 中同步初始化 → 启动延迟
- 第三方 SDK 同步初始化 → 阻塞主线程

**Activity 启动**:
- `onCreate()` 中执行耗时操作 → 首屏慢
- setContentView 前执行大量操作 → 白屏时间长

### 修复建议

1. **异步初始化**: → `Application.onCreate` 使用协程异步初始化
2. **延迟初始化**: → 使用 `lazy` 延迟到真正需要时初始化
3. **启动器**: → 使用 AppStartup 库管理初始化顺序
4. **首屏优化**: → 预加载数据，使用 Skeleton UI

---

## PERF-005: 内存泄漏

### 检测模式

**静态引用**:
- `static Activity/View` → 长生命周期持有短生命周期
- 单例持有 Activity → 泄漏

**非静态内部类**:
- Handler 非静态 → 持有外部类引用
- Runnable/匿名类 → 持有外部类引用

**未注销监听器**:
- `broadcastReceiver.registerReceiver()` 但未 `unregisterReceiver()`
- EventBus 订阅未取消

### 修复建议

1. **静态内部类** → Handler/Runnable 使用 `static class` + `WeakReference`
2. **生命周期**: → `onDestroy()` 中注销监听器、清除引用
3. **工具**: → LeakCanary 检测泄漏

---

## PERF-006: 列表性能

### 检测模式

**RecyclerView 问题**:
- `notifyDataSetChanged()` 频繁调用 → 全量刷新，性能差
- 无 DiffUtil → 动画卡顿
- `onBindViewHolder` 中执行耗时操作 → 滑动卡顿

**ViewHolder 问题**:
- `onCreateViewHolder` 每次创建新 View → 复用失效
- `setHasStableIds(true)` 但 `getItemId()` 返回不一致 → 动画错误

### 修复建议

1. **DiffUtil**: → 使用 `ListAdapter` + DiffUtil 自动计算差异
2. **异步绑定**: → Glide/Coil 异步加载图片
3. **优化**: → `onBindViewHolder` 中只更新数据，不执行耗时操作

---

## PERF-007: SharedPreferences 问题

### 检测模式

**主线程阻塞**:
- `getSharedPreferences(...)` 首次调用 → ANR
- `prefs.edit().putString(...).commit()` → 同步写入阻塞

**频繁调用**:
- 每次启动都读取大量 SP → 启动慢
- 每次滑动都写入 SP → 卡顿

### 修复建议

1. **异步**: → `apply()` 替代 `commit()`
2. **批量**: → 批量读取/写入，减少次数
3. **迁移**: → 使用 DataStore (性能更好，类型安全)

---

## PERF-008: 网络优化

### 检测模式

**无缓存**:
- 每次都请求网络 → 流量浪费、响应慢
- 无 HTTP 缓存策略 → 重复请求

**请求优化**:
- 无请求合并 → 多个小请求
- 无压缩 → 传输数据量大
- 无超时设置 → 请求挂起

**响应解析**:
- 主线程解析 JSON → 卡顿
- 无分页 → 一次加载大量数据

### 修复建议

1. **缓存**: → OkHttp Cache + Retrofit
2. **合并**: → GraphQL 或批量接口
3. **压缩**: → 启用 GZIP
4. **分页**: → Jetpack Paging 3
5. **异步**: → 协程解析 JSON

---

## 检测优先级

| 规则 | 检测优先级 | 影响 |
|------|-----------|------|
| PERF-002 | 🔴 最高 | ANR 导致用户体验极差 |
| PERF-003 | 🟠 高 | Bitmap OOM 导致崩溃 |
| PERF-005 | 🟠 高 | 内存泄漏导致 OOM |
| PERF-006 | 🟡 中 | 列表卡顿影响体验 |
| PERF-004 | 🟡 中 | 启动慢影响第一印象 |
| PERF-001 | 🟡 中 | 布局性能影响流畅度 |
| PERF-007 | 🟢 低 | SP 问题不影响功能 |
| PERF-008 | 🟢 低 | 网络优化影响体验 |

---

## Token 优化说明

**原始版本**: 2,400 tokens (284 行，179 行代码示例 = 63.0%)
**优化版本**: 1,200 tokens (纯检测模式，无冗余代码示例)
**节省**: 50%
