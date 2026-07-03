///|
test "fnv_offset_basis_is_standard" {
  assert_true(@fp.fnv_offset_basis == 14695981039346656037UL)
}

///|
test "fnv_prime_is_standard" {
  assert_true(@fp.fnv_prime == 1099511628211UL)
}

///|
test "fingerprint_determinism_invariant" {
  let m1 = @indexmap.IndexMap::new()
  ignore(m1.insert("x", 1))
  ignore(m1.insert("y", 2))
  let fp1 = m1.fingerprint()
  let fp2 = m1.fingerprint()
  assert_true(fp1 == fp2)
}

///|
test "ordered_eq_vs_standard_eq" {
  let m1 = @indexmap.IndexMap::new()
  ignore(m1.insert("a", 1))
  ignore(m1.insert("b", 2))
  let m2 = @indexmap.IndexMap::new()
  ignore(m2.insert("a", 1))
  ignore(m2.insert("b", 2))
  assert_true(m1 == m2)
  assert_true(m1.ordered_eq(m2))
}

///|
test "shift_remove_preserves_order_invariant" {
  let m = @indexmap.IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  ignore(m.insert("d", 4))
  ignore(m.remove("b"))
  let keys = m.keys_array()
  assert_true(keys[0] == "a")
  assert_true(keys[1] == "c")
  assert_true(keys[2] == "d")
}

///|
test "empty_fingerprint_equals_fnv_basis" {
  let basis = @fp.fnv_offset_basis
  let m : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  assert_true(m.fingerprint() == basis)
  let s : @indexmap.IndexSet[String] = @indexmap.IndexSet::new()
  assert_true(s.fingerprint() == basis)
  let sm : @sortedmap.SortedMap[Int, Int] = @sortedmap.SortedMap::new()
  assert_true(sm.fingerprint() == basis)
}

///|
test "fingerprint_order_sensitivity" {
  let m1 = @indexmap.IndexMap::new()
  ignore(m1.insert("a", 1))
  ignore(m1.insert("b", 2))
  let m2 = @indexmap.IndexMap::new()
  ignore(m2.insert("b", 2))
  ignore(m2.insert("a", 1))
  assert_true(m1.fingerprint() != m2.fingerprint())
  assert_true(!m1.ordered_eq(m2))
}

///|
test "fingerprint_value_sensitivity" {
  let m1 = @indexmap.IndexMap::new()
  ignore(m1.insert("key", 1))
  let m2 = @indexmap.IndexMap::new()
  ignore(m2.insert("key", 2))
  assert_true(m1.fingerprint() != m2.fingerprint())
}

///|
test "all_structures_deterministic_trait" {
  let im = @indexmap.IndexMap::new()
  ignore(im.insert(1, "a"))
  assert_true(im.fingerprint() != 0UL)

  let idxs = @indexmap.IndexSet::new()
  idxs.insert(1)
  assert_true(idxs.fingerprint() != 0UL)

  let bs = @bitmask.BitSet::new(64)
  bs.set(3)
  assert_true(bs.fingerprint() != 0UL)

  let bf = @bitmask.BitFlags::from_bits(0b1010UL)
  assert_true(bf.fingerprint() != 0UL)

  let c = @counter.Counter::new()
  c.add("x")
  assert_true(c.fingerprint() != 0UL)

  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(1))
  assert_true(rb.fingerprint() != 0UL)

  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "v"))
  assert_true(ss.fingerprint() != 0UL)

  let sm = @sortedmap.SortedMap::new()
  ignore(sm.insert(1, "a"))
  assert_true(sm.fingerprint() != 0UL)

  let cim = @compactintmap.CompactIntMap::new()
  ignore(cim.insert(1, "a"))
  assert_true(cim.fingerprint() != 0UL)

  let ds = @disjointset.DisjointSet::new(3)
  ignore(ds.union(0, 1))
  assert_true(ds.fingerprint() != 0UL)
}

///|
test "fingerprint_cache_invalidation" {
  let m = @indexmap.IndexMap::new()
  ignore(m.insert("a", 1))
  let fp1 = m.fingerprint()
  let fp1_cached = m.fingerprint()
  assert_true(fp1 == fp1_cached)
  ignore(m.insert("b", 2))
  let fp2 = m.fingerprint()
  assert_true(fp1 != fp2)
  let fp2_cached = m.fingerprint()
  assert_true(fp2 == fp2_cached)
  ignore(m.remove("a"))
  let fp3 = m.fingerprint()
  assert_true(fp2 != fp3)
  assert_true(fp1 != fp3)
}

///|
test "fingerprint_after_clear_resets" {
  let m = @indexmap.IndexMap::new()
  ignore(m.insert("x", 1))
  let fp_nonempty = m.fingerprint()
  m.clear()
  let fp_empty = m.fingerprint()
  assert_true(fp_empty == @fp.fnv_offset_basis)
  assert_true(fp_nonempty != fp_empty)
}

///|
test "counter_fingerprint_after_add_remove" {
  let c = @counter.Counter::new()
  c.add("a")
  let fp1 = c.fingerprint()
  c.add("a")
  let fp2 = c.fingerprint()
  assert_true(fp1 != fp2)
  c.subtract("a")
  let fp3 = c.fingerprint()
  assert_true(fp2 != fp3)
  c.subtract("a")
  let fp4 = c.fingerprint()
  assert_true(fp4 == @fp.fnv_offset_basis)
}

///|
test "cross_structure_composability" {
  let im = @indexmap.IndexMap::new()
  ignore(im.insert(1, 10))
  ignore(im.insert(2, 20))
  let c = @counter.Counter::from_array([1, 1, 2])
  assert_true(im.fingerprint() != c.fingerprint())
  let filtered = im.filter(fn(_k : Int, v : Int) -> Bool { v > 10 })
  assert_true(filtered.len() == 1)
  assert_true(filtered.contains(2))
}

///|
test "defaultmap_fingerprint_deterministic" {
  let dm1 = @defaultmap.DefaultMap::new(fn() -> Int { 0 })
  ignore(dm1.insert("a", 1))
  let dm2 = @defaultmap.DefaultMap::new(fn() -> Int { 0 })
  ignore(dm2.insert("a", 1))
  assert_true(dm1.fingerprint() == dm2.fingerprint())
}

///|
test "all_empty_fingerprints_are_fnv_basis" {
  let basis = @fp.fnv_offset_basis
  let im : @indexmap.IndexMap[String, Int] = @indexmap.IndexMap::new()
  assert_true(im.fingerprint() == basis)
  let idxs : @indexmap.IndexSet[String] = @indexmap.IndexSet::new()
  assert_true(idxs.fingerprint() == basis)
  let sm : @sortedmap.SortedMap[Int, Int] = @sortedmap.SortedMap::new()
  assert_true(sm.fingerprint() == basis)
  let cim : @compactintmap.CompactIntMap[Int] = @compactintmap.CompactIntMap::new()
  assert_true(cim.fingerprint() == basis)
  let dm : @defaultmap.DefaultMap[String, Int] = @defaultmap.DefaultMap::new(fn() -> Int {
    0
  })
  assert_true(dm.fingerprint() == basis)
  let c : @counter.Counter[String] = @counter.Counter::new()
  assert_true(c.fingerprint() == basis)
}

///|
test "all_fingerprint_caching_consistent" {
  let m = @indexmap.IndexMap::new()
  ignore(m.insert("a", 1))
  let fp1 = m.fingerprint()
  let fp2 = m.fingerprint()
  assert_true(fp1 == fp2)
  let sm = @sortedmap.SortedMap::new()
  ignore(sm.insert(1, "a"))
  let sfp1 = sm.fingerprint()
  let sfp2 = sm.fingerprint()
  assert_true(sfp1 == sfp2)
  let cim = @compactintmap.CompactIntMap::new()
  ignore(cim.insert(1, "a"))
  let cfp1 = cim.fingerprint()
  let cfp2 = cim.fingerprint()
  assert_true(cfp1 == cfp2)
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(1))
  let rfp1 = rb.fingerprint()
  let rfp2 = rb.fingerprint()
  assert_true(rfp1 == rfp2)
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "v"))
  let ssfp1 = ss.fingerprint()
  let ssfp2 = ss.fingerprint()
  assert_true(ssfp1 == ssfp2)
  let ds = @disjointset.DisjointSet::new(3)
  ignore(ds.union(0, 1))
  let dfp1 = ds.fingerprint()
  let dfp2 = ds.fingerprint()
  assert_true(dfp1 == dfp2)
}
