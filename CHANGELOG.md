# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
