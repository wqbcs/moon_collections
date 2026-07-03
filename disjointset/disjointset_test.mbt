///|
test "disjointset_basic" {
  let ds = @disjointset.DisjointSet::new(5)
  assert_true(ds.component_count() == 5)
  assert_true(ds.connected(0, 1) == false)
  assert_true(ds.union(0, 1))
  assert_true(ds.connected(0, 1))
  assert_true(ds.component_count() == 4)
}

///|
test "disjointset_chain" {
  let ds = @disjointset.DisjointSet::new(6)
  ignore(ds.union(0, 1))
  ignore(ds.union(1, 2))
  ignore(ds.union(3, 4))
  assert_true(ds.connected(0, 2))
  assert_true(ds.connected(3, 4))
  assert_true(!ds.connected(0, 3))
  assert_true(ds.component_count() == 3)
}

///|
test "disjointset_union_same" {
  let ds = @disjointset.DisjointSet::new(3)
  assert_true(ds.union(0, 1))
  assert_true(!ds.union(0, 1))
  assert_true(ds.component_count() == 2)
}

///|
test "disjointset_all_connected" {
  let ds = @disjointset.DisjointSet::new(4)
  ignore(ds.union(0, 1))
  ignore(ds.union(1, 2))
  ignore(ds.union(2, 3))
  assert_true(ds.component_count() == 1)
  assert_true(ds.connected(0, 3))
}

///|
test "disjointset_component_size" {
  let ds = @disjointset.DisjointSet::new(5)
  ignore(ds.union(0, 1))
  ignore(ds.union(0, 2))
  assert_true(ds.component_size(0) == 3)
  assert_true(ds.component_size(3) == 1)
}

///|
test "disjointset_all_components" {
  let ds = @disjointset.DisjointSet::new(5)
  ignore(ds.union(0, 1))
  ignore(ds.union(3, 4))
  let comps = ds.all_components()
  assert_true(comps.length() == 3)
}

///|
test "disjointset_collection_trait" {
  let ds = @disjointset.DisjointSet::new(5)
  assert_true(ds.len() == 5)
  assert_true(!ds.is_empty())
}

///|
test "disjointset_deterministic_trait" {
  let ds1 = @disjointset.DisjointSet::new(4)
  ignore(ds1.union(0, 1))
  let ds2 = @disjointset.DisjointSet::new(4)
  ignore(ds2.union(0, 1))
  let ds3 = @disjointset.DisjointSet::new(4)
  ignore(ds3.union(2, 3))
  assert_true(ds1.fingerprint() == ds2.fingerprint())
  assert_true(ds1.fingerprint() != ds3.fingerprint())
  assert_true(ds1.ordered_eq(ds2))
  assert_true(!ds1.ordered_eq(ds3))
}

///|
test "disjointset_fingerprint_logical_equivalence" {
  let ds1 = @disjointset.DisjointSet::new(4)
  ignore(ds1.union(0, 1))
  ignore(ds1.union(1, 2))
  ignore(ds1.connected(0, 2))
  let ds2 = @disjointset.DisjointSet::new(4)
  ignore(ds2.union(0, 1))
  ignore(ds2.union(1, 2))
  assert_true(ds1.fingerprint() == ds2.fingerprint())
  assert_true(ds1.ordered_eq(ds2))
}

///|
test "disjointset_clear" {
  let ds = DisjointSet::new(5)
  ignore(ds.union(0, 1))
  ignore(ds.union(2, 3))
  assert_true(ds.component_count() == 3)
  ds.clear()
  assert_true(ds.component_count() == 5)
  assert_true(!ds.connected(0, 1))
}

///|
test "disjointset_from_array" {
  let ds = DisjointSet::from_array(5, [(0, 1), (2, 3)])
  assert_true(ds.component_count() == 3)
  assert_true(ds.connected(0, 1))
  assert_true(ds.connected(2, 3))
  assert_true(!ds.connected(0, 2))
}

///|
test "disjointset_size_len_consistency" {
  let ds = @disjointset.DisjointSet::new(5)
  assert_true(ds.size() == ds.len())
  ignore(ds.union(0, 1))
  assert_true(ds.size() == ds.len())
}

///|
test "disjointset_fingerprint_cache_invalidation" {
  let ds = DisjointSet::new(4)
  let fp1 = ds.fingerprint()
  let fp1_cached = ds.fingerprint()
  assert_true(fp1 == fp1_cached)
  ignore(ds.union(0, 1))
  let fp2 = ds.fingerprint()
  assert_true(fp1 != fp2)
}

///|
test "disjointset_single_element" {
  let ds = DisjointSet::new(1)
  assert_true(ds.component_count() == 1)
  assert_true(ds.len() == 1)
}

///|
test "disjointset_component_elements" {
  let ds = DisjointSet::new(5)
  ignore(ds.union(0, 1))
  ignore(ds.union(0, 2))
  ignore(ds.union(3, 4))
  let comp_a = ds.component_elements(0)
  assert_true(comp_a.length() == 3)
  assert_true(comp_a.contains(0))
  assert_true(comp_a.contains(2))
  let comp_b = ds.component_elements(3)
  assert_true(comp_b.length() == 2)
  assert_true(comp_b.contains(4))
  let comp_c = ds.component_elements(99)
  assert_true(comp_c.length() == 0)
}

///|
test "disjointset_logical_equivalence" {
  // Two DisjointSets with same logical structure but different
  // union sequences must produce identical fingerprints.
  let ds1 = DisjointSet::new(4)
  ignore(ds1.union(0, 1))
  ignore(ds1.union(2, 3))
  ignore(ds1.union(0, 2))
  // ds1: all 4 elements in one component via (0-1, 2-3, 0-2)

  let ds2 = DisjointSet::new(4)
  ignore(ds2.union(1, 2))
  ignore(ds2.union(2, 3))
  ignore(ds2.union(0, 3))
  // ds2: all 4 elements in one component via (1-2, 2-3, 0-3)

  assert_true(ds1.connected(0, 3))
  assert_true(ds2.connected(0, 3))
  assert_true(ds1.component_count() == 1)
  assert_true(ds2.component_count() == 1)
  assert_true(ds1.fingerprint() == ds2.fingerprint())
  assert_true(ds1.ordered_eq(ds2))
}
