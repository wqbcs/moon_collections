///|
pub fn[K : Hash + Eq, V] new_index_map() -> @indexmap.IndexMap[K, V] {
  @indexmap.IndexMap::new()
}

///|
pub fn new_bit_set(capacity : Int) -> @bitmask.BitSet {
  @bitmask.BitSet::new(capacity)
}

///|
pub fn new_bit_flags() -> @bitmask.BitFlags {
  @bitmask.BitFlags::new()
}

///|
pub fn[K : Hash + Eq] new_counter() -> @counter.Counter[K] {
  @counter.Counter::new()
}

///|
pub fn[K : Hash + Eq] new_index_set() -> @indexmap.IndexSet[K] {
  @indexmap.IndexSet::new()
}

///|
pub fn[K : Hash + Eq, V] new_default_map(
  default_fn : () -> V,
) -> @defaultmap.DefaultMap[K, V] {
  @defaultmap.DefaultMap::new(default_fn)
}

///|
pub fn[V] new_compact_int_map() -> @compactintmap.CompactIntMap[V] {
  @compactintmap.CompactIntMap::new()
}

///|
pub fn new_disjoint_set(size : Int) -> @disjointset.DisjointSet {
  @disjointset.DisjointSet::new(size)
}

///|
pub fn new_rolling_fingerprint() -> @fp.RollingFingerprint {
  @fp.RollingFingerprint::new()
}

///|
pub fn fingerprint_ints(ints : Array[Int]) -> UInt64 {
  @fp.fingerprint_ints(ints)
}

///|
pub fn fingerprint_strings(strings : Array[String]) -> UInt64 {
  @fp.fingerprint_strings(strings)
}

///|
pub fn[T] new_ring_buffer(capacity : Int) -> @ringbuffer.RingBuffer[T] {
  @ringbuffer.RingBuffer::new(capacity)
}

///|
pub fn[V] new_sparse_set(capacity : Int) -> @sparseset.SparseSet[V] {
  @sparseset.SparseSet::new(capacity)
}

///|
pub fn[K, V] new_sorted_map() -> @sortedmap.SortedMap[K, V] {
  @sortedmap.SortedMap::new()
}

///|
pub fn[K : Compare, V] to_sorted_map(
  im : @indexmap.IndexMap[K, V],
) -> @sortedmap.SortedMap[K, V] {
  @convert.to_sorted_map(im)
}

///|
pub fn[K : Hash + Eq, V] to_index_map(
  sm : @sortedmap.SortedMap[K, V],
) -> @indexmap.IndexMap[K, V] {
  @convert.to_index_map(sm)
}

///|
pub fn lcs_length(old : Array[Int], new : Array[Int]) -> Int {
  @diff.lcs_length(old, new)
}

///|
pub fn edit_distance(old : Array[Int], new : Array[Int]) -> Int {
  @diff.edit_distance(old, new)
}

///|
pub fn[T : @traits.Collection] collection_len(c : T) -> Int {
  c.len()
}
