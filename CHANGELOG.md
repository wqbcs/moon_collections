# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-07-03

### Added

**Clone Methods**
- `IndexMap.clone()` — deep copy preserving all entries and fingerprint cache state
- `IndexSet.clone()` — deep copy via `from_array(to_array())`
- `SortedMap.clone()` — deep copy preserving sorted order
- `CompactIntMap.clone()` — deep copy preserving sorted entries

**BitSet Enhancements**
- `iter_ones()` — iterate over all set bit positions
- `iter_zeros()` — iterate over all unset bit positions within `[0, len)`
- `first_zero()` / `last_zero()` — find first/last unset bit
- `union_with(other)` — in-place union (modifies self, reduces allocations)
- `intersect_with(other)` — in-place intersection
- `difference_with(other)` — in-place difference

**SortedMap Enhancements**
- `range(from, to)` — now uses binary search to locate start position (was O(n), now O(log n + k))
- `floor(key)` — largest key ≤ given key
- `ceil(key)` — smallest key ≥ given key

**CompactIntMap Enhancements**
- `floor_key(key)` / `ceil_key(key)` — binary-search-based integer key boundary queries

**DisjointSet Enhancements**
- `component_elements(x)` — return all elements in the same component as x

**RingBuffer Enhancements**
- `sort(T : Compare)` — in-place sort of buffer contents
- `find_last(T : Eq)` — find last occurrence index of an item

### Fixed

- `BitSet.complement()` — now masks out bits beyond `self.len` (was flipping bits in unused storage area, causing `contains()` to return incorrect results for positions ≥ len)
- `diff_sequences` — substitution paths now emit `Delete`+`Insert` pair instead of just `Delete` (edit sequence was undercounting substitutions)
- `diff_arrays` — O(n×m) → O(n+m) using IndexSet for O(1) membership check
- `diff/moon.pkg` — added missing `indexmap` dependency
- `Counter.subtract_counter` — no longer produces negative counts (removes keys that go to zero or below)
- `Counter.set` — now treats `count ≤ 0` as removal (was only removing on `count == 0`, allowing negative values to persist)
- `Counter.map_keys` — fixed double evaluation of `f(k)` (was calling `f(k)` twice per entry)
- `RingBuffer.pop_back` — tail pointer now updated only on successful pop (was mutating tail before confirming data existed)
- `RingBuffer.ordered_eq` — now includes `capacity` check, consistent with `fingerprint()`
- `SparseSet.ordered_eq` — now includes `capacity` check, consistent with `fingerprint()`
- `fnv1a_hash_int` — fixed for negative values (MoonBit's `%` produces negative remainder, causing early loop termination and only 1-byte hash instead of 8)
- `SortedMap.filter` — O(n²) → O(n) by filtering entries array directly instead of repeated `insert`
- `SortedMap.map_values` — O(n²) → O(n) by building entries array directly
- `SortedMap.merge` — O((n+m)²) → O(n+m) using two-pointer merge of sorted arrays
- `SortedMap.range(from, to)` — now reuses existing `binary_search` and adds `from > to` early exit guard
- `to_sorted_map` — O(n²) → O(n log n) using sort + `from_sorted_entries` instead of repeated insert
- `DisjointSet.component_size` — O(n) → O(1) via dedicated `size` array maintained during union
- `DisjointSet.all_components` — O(n²) → O(n) via two-pass counting and allocation
- All 293 tests passing (up from 290)

## [0.2.3] - 2026-07-10

### Fixed

- `IndexMap::new()` — `fp_dirty` 初始值 `false→true`，与其他 10 个结构体一致，消除潜在的不一致

### Performance

- `IndexMap::clone()` — 直接拷贝 `entries` 数组 + 单遍重建 `indices`，替代 O(n) `insert` 路径
- `BitSet.to_bit_string()` — O(n²)→O(n)，使用 `Array[String]::join("")` 替代字符串逐次拼接
- `BitFlags.to_bit_string()` — 同上修复
- `BitSet.first_one` / `last_one` / `first_zero` / `last_zero` — 块级跳过优化（稀疏位集下从 O(n) 降至 O(n/64)）
- `BitSet.next_one` / `prev_one` — 块级跳过优化

### Tests

- 新增 4 个块级边界测试（跨块扫描、中空块跳过、全块零查找、跨块 next/prev）
- 总测试用例数：311 → 315

## [0.2.4] - 2026-07-10

### Fixed

- `BitSet.first_zero()` / `last_zero()` — 对抗性审查发现：truncate 后 `bits.length()` 可能大于 `len` 所需块数，导致 `effective_bits < 0` 时产生负值位移（`1UL << -54`）行为未定义。添加 `effective_bits <= 0` 保护跳过区块
- `BitSet.prev_one()` — 添加显式 `self.len == 0` 保护（当 `self.len == 0` 时 `start = -1` 可能进入无效路径）
- 新增回归测试验证 truncate + first_zero 场景（316 → 316 测试全通过）

## [0.1.0] - 2026-06-08

### Added

**Core Framework**
- `Collection` open trait: `len()`, `is_empty()`
- `Deterministic` open trait: `fingerprint()`, `ordered_eq()` — verifiable determinism
- FNV-1a fingerprint module with lazy caching (`fp_cache` + `fp_dirty`)
- `RollingFingerprint` for incremental hash updates

**Data Structures (12)**
- `IndexMap[K,V]` — ordered hash map, 46+ methods, O(1) key+index access
- `IndexSet[K]` — ordered set with union/intersect/difference/symmetric_difference
- `BitSet` — dynamic bit collection, 36+ methods, set operations
- `BitFlags` — 64-bit flags with BitAnd/BitOr/BitXOr operators
- `Counter[K]` — deterministic frequency counter, most_common with stable order
- `DefaultMap[K,V]` — map with default value on miss
- `CompactIntMap[V]` — sorted integer key map (binary search, no hashing)
- `SortedMap[K,V]` — Compare-based sorted map with range/lower_bound/upper_bound
- `RingBuffer[T]` — fixed-capacity circular buffer for WASM streaming
- `SparseSet[V]` — ECS-optimized sparse set, O(1) all operations
- `DisjointSet` — Union-Find with path compression + union by rank
- `Diff` — LCS + edit distance + sequence diff (no HashMap dependency)

**Deterministic Guarantees**
- `remove()` defaults to `shift_remove` (preserves insertion order)
- `IndexMap.at()` returns `V?` (no abort/trap in WASM)
- All 11 data structures implement `Collection` + `Deterministic` traits
- Fingerprint includes position + key hash + value hash
- Fingerprint order sensitivity: different insertion order → different fingerprint
- Fingerprint value sensitivity: different values → different fingerprint

**Composition Operations**
- `IndexMap.filter()`, `map_values()`, `merge()`
- `IndexSet.union()`, `intersect()`, `difference()`, `symmetric_difference()`
- `IndexSet.is_subset()`, `is_superset()`, `is_disjoint()`
- `SortedMap.filter()`, `map_values()`, `merge()`, `range()`
- `Counter.filter()`, `scale()`, `map_keys()`

**Infrastructure**
- 268 tests (all passing), including whitebox invariant tests
- WASM-GC target builds successfully
- `moon check` 0 errors, `moon fmt` passes
- Apache-2.0 license
- AI usage declaration

### Fixed

- `BitSet.fingerprint()` now includes `len` field (was missing, could collide for different-capacity BitSets)
- `SparseSet.fingerprint()` now includes `capacity` field (was missing, could collide for different-capacity SparseSets)
- `IndexMap.get_or_insert()` and `get_or_insert_with()` now set `fp_dirty = true` on insertion (was missing, could return stale cached fingerprint)
- `IndexMap.pop_back()` now sets `fp_dirty = true` (was missing, could return stale cached fingerprint)
- `IndexMap.remove_entry()` now uses `shift_remove` semantics (was using `swap_remove`, violating default-order-preservation principle)
- `DisjointSet.fingerprint()` and `ordered_eq()` now fully compress paths before comparing (ensures logical equivalence, not physical representation)
- `RingBuffer.rotate_left()` and `rotate_right()` now handle negative `n` correctly via `((n % count) + count) % count`
- `cmd/main/main.mbt` migrated from deprecated `Show` (string interpolation) to `Debug` (`repr()`)
- Removed all unused trait bounds: `Counter::map_keys[K]`, `SortedMap::new[K]`, `new_sorted_map[K]`

### Added (since initial)

- `DefaultMap.iter()` — delegate to underlying IndexMap
- `Counter.iter()` — delegate to underlying IndexMap
- `DisjointSet.clear()` — reset all elements to individual sets
- `DisjointSet.from_array(size, pairs)` — construct from union pairs
- **All 11 Deterministic structures now have fp_cache + fp_dirty lazy caching** (fingerprint O(n) first call, O(1) cached)
  - IndexMap, SortedMap, CompactIntMap, RingBuffer, SparseSet, BitSet, DisjointSet (direct)
  - Counter, DefaultMap, IndexSet (via IndexMap delegation)
  - BitFlags (single UInt64, O(1) already)
- `IndexMap.to_array()`, `SortedMap.to_array()`, `CompactIntMap.to_array()` — from_array/to_array symmetry
- `SortedMap.keys_array()`, `SortedMap.values_array()`, `CompactIntMap.keys_array()`, `CompactIntMap.values_array()`
- `convert` package: `to_sorted_map()` (IndexMap→SortedMap), `to_index_map()` (SortedMap→IndexMap)
- `Counter.most_common()` now uses stable sort (equal counts preserve insertion order)
- 268 total tests (up from 174)
