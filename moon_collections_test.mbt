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
