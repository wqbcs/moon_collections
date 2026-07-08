# moon_collections

> **确定性数据处理框架 / Deterministic Data Processing Framework for MoonBit/WASM**
> 12 种数据结构 · 2 个开放特征 · FNV-1a 指纹 · 零不确定性
> 12 data structures · 2 open traits · FNV-1a fingerprinting · zero nondeterminism

[![CI](https://github.com/wqbcs/moon_collections/actions/workflows/ci.yml/badge.svg)](https://github.com/wqbcs/moon_collections/actions/workflows/ci.yml)

---

## 中文介绍

### 问题：WASM 中的不确定性

当编译到 WebAssembly 时，标准基于哈希的集合会产生**不确定的输出**：

- `HashMap` 迭代顺序因运行而异 → JSON 序列化不可预测
- `remove()` 末尾交换 → 顺序被静默破坏
- 无法跨分布式节点验证两个集合是否"相同"
- 没有用于缓存失效、审计日志或共识协议的指纹

**这是正确性问题，不是性能问题。** 不确定性破坏了可重现性、测试和分布式共识。

### 解决方案：三个原则

1. **DETERMINISTIC（确定性）** — 相同输入 → 始终相同输出
2. **VERIFIABLE（可验证）** — 通过指纹进行结构相等性比较
3. **COMPOSABLE（可组合）** — 操作保持确定性

---

## English Introduction

### The Problem: Nondeterminism in WASM

When compiling to WebAssembly, standard hash-based collections produce **nondeterministic output**:

- `HashMap` iteration order varies across runs → JSON serialization is unpredictable
- `remove()` swaps with last element → order is destroyed silently
- No way to verify two collections are "the same" across distributed nodes
- No fingerprint for cache invalidation, audit logging, or consensus protocols

**This is a correctness issue, not a performance issue.** Nondeterminism breaks reproducibility, testing, and distributed consensus.

### The Solution: Three Principles

1. **DETERMINISTIC** — Same input → same output, always
2. **VERIFIABLE** — Structural equality with fingerprint
3. **COMPOSABLE** — Operations preserve determinism

---

## 安装 / Install

```bash
moon add wqbcs/moon_collections
```

> **环境要求 / Requirements**：MoonBit 工具链 ≥ **0.10.3**（`moon check --deny-warn`、保留字检查等特性需要该版本）。

## 快速开始 / Quick Start

```moonbit nocheck
let m = @indexmap.IndexMap::new()
m.insert("name", "Alice")
m.insert("age", "30")
m.insert("city", "Beijing")

// 确定性迭代 — 始终相同顺序 / Deterministic iteration — always same order
m.keys_array() // => ["name", "age", "city"]

// 指纹验证 / Fingerprint verification
m.fingerprint() // => 14528911724609714292UL (已计算并缓存 / computed, cached)

// 位置感知相等性 / Position-aware equality
let m2 = @indexmap.IndexMap::new()
m2.insert("name", "Alice")
m2.insert("age", "30")
m2.insert("city", "Beijing")
m.ordered_eq(m2) // => true (相同顺序，相同值 / same order, same values)

// 删除保持顺序（默认 shift_remove）/ Remove preserves order (shift_remove by default)
m.remove("age")
m.keys_array() // => ["name", "city"]
```

### 最小可运行示例 / Minimal Runnable Example

在你自己的项目中（已执行 `moon add wqbcs/moon_collections`）：

```moonbit nocheck
///|
fn main {
  let m = @indexmap.IndexMap::new()
  m.insert("name", "Alice")
  m.insert("age", "30")
  m.insert("city", "Beijing")
  println(m.keys_array()) // ["name", "age", "city"]
  println(m.fingerprint()) // 稳定的 UInt64 指纹（相同输入 => 相同值）
  let m2 = @indexmap.IndexMap::new()
  m2.insert("name", "Alice")
  m2.insert("age", "30")
  m2.insert("city", "Beijing")
  println(m.ordered_eq(m2)) // true（相同顺序、相同值）
}
```

本仓库自带可直接运行的演示（`cmd/main`）：

```bash
moon run cmd/main
```

---

## 数据结构 / Data Structures

| 结构 / Structure | 描述 / Description | Collection | Deterministic |
|-----------|-------------|:----------:|:-------------:|
| **IndexMap[K,V]** | 有序哈希映射 / Ordered hash map | ✅ | ✅ |
| **IndexSet[K]** | 保序集合 / Ordered set | ✅ | ✅ |
| **BitSet** | 位集合 / Bit collection | ✅ | ✅ |
| **BitFlags** | 64位标志 / 64-bit flags | ✅ | ✅ |
| **Counter[K]** | 频率计数器 / Frequency counter | ✅ | ✅ |
| **DefaultMap[K,V]** | 默认值映射 / Map with default value | ✅ | ✅ |
| **CompactIntMap[V]** | 整型键映射（二分搜索）/ Sorted integer map | ✅ | ✅ |
| **SortedMap[K,V]** | 比较排序映射 / Compare-based sorted map | ✅ | ✅ |
| **RingBuffer[T]** | 环形缓冲区 / Circular buffer | ✅ | ✅ |
| **SparseSet[V]** | 稀疏集（ECS优化）/ ECS sparse set | ✅ | ✅ |
| **DisjointSet** | 并查集 / Union-Find | ✅ | ✅ |
| **Diff** | LCS + 编辑距离 / Edit distance | ✗ | ✗ |

---

## 核心特征 / Core Traits

```moonbit nocheck
///|
pub(open) trait Collection {
  fn len(Self) -> Int
  fn is_empty(Self) -> Bool
}

///|
pub(open) trait Deterministic: Collection {
  fn fingerprint(Self) -> UInt64
  fn ordered_eq(Self, Self) -> Bool
}
```

All 11 data structures implement `Collection`. All implement `Deterministic` (except Diff which is algorithm-only).

所有 11 种数据结构实现了 `Collection`。全部（除 Diff 外）实现了 `Deterministic`。

---

## 特性 / Features

### 中文

- **12 种确定性数据结构**：IndexMap、IndexSet、BitSet、BitFlags、Counter、DefaultMap、CompactIntMap、SortedMap、RingBuffer、SparseSet、DisjointSet、Diff
- **FNV-1a 指纹验证**：惰性缓存，O(n) 首次计算，O(1) 后续访问
- **Collection + Deterministic 开放特征**：可实现自定义确定性类型
- **`remove()` 默认 shift_remove**：保持插入顺序
- **WASM 安全**：`get()`/`at()` 返回 `Option`（无异常中断）
- **跨结构转换**：IndexMap ↔ SortedMap 双向转换
- **完整 CI/CD**：GitHub Actions 自动执行 `moon check --deny-warn` · `moon test` · `moon fmt` · `moon info` 四步校验
- **311 个测试用例**，全部通过

### English

- **12 deterministic data structures**: IndexMap, IndexSet, BitSet, BitFlags, Counter, DefaultMap, CompactIntMap, SortedMap, RingBuffer, SparseSet, DisjointSet, Diff
- **FNV-1a fingerprinting**: Lazy caching, O(n) first call, O(1) cached access
- **Collection + Deterministic open traits**: Implement custom deterministic types
- **`remove()` defaults to shift_remove**: Preserves insertion order
- **WASM safety**: `get()`/`at()` return `Option` (no abort/trap)
- **Cross-structure conversion**: IndexMap ↔ SortedMap bidirectional
- **Full CI/CD**: GitHub Actions runs `moon check --deny-warn`, `moon test`, `moon fmt`, `moon info` in CI
- **311 test cases**, all passing

---

## 许可证 / License

Apache-2.0
