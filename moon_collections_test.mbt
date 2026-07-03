///|
test "factory_functions_work" {
  let m = new_index_map()
  ignore(m.insert("key", 42))
  assert_true(m.len() == 1)
  let bs = new_bit_set(64)
  bs.set(3)
  assert_true(bs.contains(3))
  let bf = new_bit_flags()
  assert_true(bf.is_empty())
  let dm = new_default_map(fn() -> Int { 0 })
  assert_true(dm.get("x") == 0)
  let cim = new_compact_int_map()
  ignore(cim.insert(1, "a"))
  assert_true(cim.get(1) == Some("a"))
  let ds = new_disjoint_set(5)
  assert_true(ds.component_count() == 5)
  let rf = new_rolling_fingerprint()
  rf.update_int(42)
  assert_true(rf.count() == 1)
  let rb = new_ring_buffer(4)
  ignore(rb.push_back(1))
  assert_true(rb.len() == 1)
  let ss = new_sparse_set(10)
  ignore(ss.insert(5, "v"))
  assert_true(ss.contains(5))
  let sm = new_sorted_map()
  ignore(sm.insert(3, "c"))
  assert_true(sm.get(3) == Some("c"))
}

///|
test "collection_len_trait_dispatch" {
  let m = new_index_map()
  ignore(m.insert("a", 1))
  assert_true(collection_len(m) == 1)
}

///|
test "diff_functions" {
  assert_true(lcs_length([1, 2, 3], [1, 3]) == 2)
  assert_true(edit_distance([1, 2], [1, 3]) == 1)
}

///|
test "empty_collections_edge_cases" {
  // Empty IndexMap
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  assert_true(m.len() == 0)
  assert_true(m.is_empty())
  assert_true(m.first() == None)
  assert_true(m.last() == None)
  assert_true(m.get("nonexistent") == None)
  assert_true(m.pop_front() == None)
  assert_true(m.pop_back() == None)

  // Empty IndexSet
  let s : @indexmap.IndexSet[Int] = @indexmap.IndexSet::new()
  assert_true(s.is_empty())
  assert_true(!s.contains(0))
  assert_true(s.pop_front() == None)
  assert_true(s.pop_back() == None)

  // Empty BitSet
  let bs = @bitmask.BitSet::new(0)
  assert_true(bs.is_empty())
  assert_true(bs.first_one() == None)
  assert_true(bs.last_one() == None)
  assert_true(bs.first_zero() == None)
  assert_true(!bs.contains(0))

  // Empty RingBuffer
  let rb : @ringbuffer.RingBuffer[Int] = @ringbuffer.RingBuffer::new(4)
  assert_true(rb.len() == 0)
  assert_true(rb.front() == None)
  assert_true(rb.back() == None)
  assert_true(rb.pop_front() == None)
  assert_true(rb.pop_back() == None)

  // Empty SortedMap
  let sm : @sortedmap.SortedMap[Int, String] = @sortedmap.SortedMap::new()
  assert_true(sm.min_key() == None)
  assert_true(sm.max_key() == None)
  assert_true(sm.floor(5) == None)
  assert_true(sm.ceil(5) == None)

  // Empty CompactIntMap
  let cim : @compactintmap.CompactIntMap[String] = @compactintmap.CompactIntMap::new()
  assert_true(cim.floor_key(5) == None)
  assert_true(cim.ceil_key(5) == None)

  // Empty SparseSet
  let ss : @sparseset.SparseSet[String] = @sparseset.SparseSet::new(10)
  assert_true(ss.is_empty())
  assert_true(ss.len() == 0)
}

///|
test "single_element_operations" {
  // IndexMap single element
  let m = new_index_map()
  ignore(m.insert("only", 1))
  assert_true(m.len() == 1)
  assert_true(m.first() == Some(("only", 1)))
  assert_true(m.last() == Some(("only", 1)))
  assert_true(m.get_index(0) == Some(("only", 1)))

  // BitSet single element
  let bs = @bitmask.BitSet::new(64)
  bs.set(42)
  assert_true(bs.count_ones() == 1)
  assert_true(bs.first_one() == Some(42))
  assert_true(bs.last_one() == Some(42))
  bs.clear(42)
  assert_true(bs.is_empty())

  // RingBuffer single element
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(99))
  assert_true(rb.len() == 1)
  assert_true(rb.front() == Some(99))
  assert_true(rb.back() == Some(99))
}

///|
test "clone_independence" {
  let m1 = @indexmap.IndexMap::from_array([("a", 1), ("b", 2)])
  let m2 = @indexmap.IndexMap::clone(m1)
  assert_true(m1 == m2)
  ignore(m2.insert("c", 3))
  assert_true(m1.len() == 2)
  assert_true(m2.len() == 3)

  let s1 = @indexmap.IndexSet::from_array([1, 2, 3])
  let s2 = @indexmap.IndexSet::clone(s1)
  assert_true(s1.len() == s2.len())
  s2.insert(4)
  assert_true(s1.len() == 3)

  let sm1 = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b")])
  let sm2 = @sortedmap.SortedMap::clone(sm1)
  assert_true(sm1.to_array() == sm2.to_array())
}

///|
test "bitset_inplace_ops" {
  let a = @bitmask.BitSet::new(64)
  a.set(0)
  a.set(2)
  let b = @bitmask.BitSet::new(64)
  b.set(1)
  b.set(2)

  a.union_with(b)
  assert_true(a.contains(0))
  assert_true(a.contains(1))
  assert_true(a.contains(2))
  assert_true(a.count_ones() == 3)

  a.clear_all()
  a.set(0)
  a.set(1)
  a.set(2)
  a.intersect_with(b)
  assert_true(!a.contains(0))
  assert_true(a.contains(1))
  assert_true(a.contains(2))
  assert_true(a.count_ones() == 2)

  a.clear_all()
  a.set(0)
  a.set(2)
  a.set(3)
  a.difference_with(b)
  assert_true(a.contains(0))
  assert_true(a.contains(3))
  assert_true(!a.contains(2))
}

///|
test "bitset_complement_empty_invariant" {
  // complement of empty BitSet must be empty (len=0 → no bits defined)
  let empty = @bitmask.BitSet::none()
  let c = empty.complement()
  assert_true(c.len() == 0)
  assert_true(c.is_empty())
  assert_true(c.contains(0) == false)

  // complement of complement returns to original state
  let bs = @bitmask.BitSet::new(64)
  bs.set(3)
  bs.set(7)
  let c1 = bs.complement()
  let c2 = c1.complement()
  assert_true(c2.contains(3))
  assert_true(c2.contains(7))
  assert_true(!c2.contains(5))
  assert_true(c2.len() == bs.len())
}

///|
test "bitset_set_all_bounds_invariant" {
  // set_all must NOT set bits beyond self.len
  let bs = @bitmask.BitSet::new(10)
  bs.set_all()
  assert_true(bs.contains(0))
  assert_true(bs.contains(9))
  assert_true(!bs.contains(10))
  assert_true(!bs.contains(63))
  assert_true(bs.count_ones() == 10)
  assert_true(bs.all_set())

  // set_all + complement should give empty set for the defined range
  let bs2 = @bitmask.BitSet::new(20)
  bs2.set_all()
  let c = bs2.complement()
  assert_true(c.is_empty())
  assert_true(c.count_ones() == 0)
}
