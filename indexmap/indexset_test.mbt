///|
test "indexset_basic" {
  let s = IndexSet::new()
  s.insert("a")
  s.insert("b")
  s.insert("c")
  assert_true(s.contains("a"))
  assert_true(s.contains("b"))
  assert_true(!s.contains("d"))
  assert_true(s.len() == 3)
}

///|
test "indexset_duplicate_insert" {
  let s = IndexSet::new()
  s.insert("a")
  s.insert("a")
  s.insert("a")
  assert_true(s.len() == 1)
  assert_true(s.contains("a"))
}

///|
test "indexset_remove" {
  let s = IndexSet::new()
  s.insert("a")
  s.insert("b")
  s.insert("c")
  assert_true(s.remove("b"))
  assert_true(!s.contains("b"))
  assert_true(s.len() == 2)
  assert_true(!s.remove("d"))
}

///|
test "indexset_order_preserved" {
  let s = IndexSet::new()
  s.insert("c")
  s.insert("a")
  s.insert("b")
  assert_true(s.get_index_of("c") == Some(0))
  assert_true(s.get_index_of("a") == Some(1))
  assert_true(s.get_index_of("b") == Some(2))
}

///|
test "indexset_shift_remove" {
  let s = IndexSet::new()
  s.insert("a")
  s.insert("b")
  s.insert("c")
  assert_true(s.shift_remove("b"))
  assert_true(s.get_index_of("a") == Some(0))
  assert_true(s.get_index_of("c") == Some(1))
}

///|
test "indexset_move_operations" {
  let s = IndexSet::new()
  s.insert("a")
  s.insert("b")
  s.insert("c")
  assert_true(s.move_to_front("c"))
  assert_true(s.get_index_of("c") == Some(0))
  assert_true(s.move_to_back("a"))
  assert_true(s.get_index_of("a") == Some(2))
}

///|
test "indexset_pop_and_reverse" {
  let s = IndexSet::new()
  s.insert("a")
  s.insert("b")
  s.insert("c")
  assert_true(s.pop_back() == Some("c"))
  assert_true(s.pop_front() == Some("a"))
  assert_true(s.len() == 1)
  let s2 = IndexSet::new()
  s2.insert("x")
  s2.insert("y")
  s2.reverse()
  assert_true(s2.get_index_of("x") == Some(1))
  assert_true(s2.get_index_of("y") == Some(0))
}

///|
test "indexset_int_key" {
  let s : IndexSet[Int] = IndexSet::new()
  s.insert(10)
  s.insert(20)
  s.insert(30)
  assert_true(s.contains(20))
  assert_true(!s.contains(99))
  assert_true(s.get_index_of(10) == Some(0))
  assert_true(s.remove(20))
  assert_true(s.len() == 2)
}

///|
test "indexset_union_intersect" {
  let s1 = IndexSet::from_array([1, 2, 3])
  let s2 = IndexSet::from_array([2, 3, 4])
  let u = s1.union(s2)
  assert_true(u.len() == 4)
  let i = s1.intersect(s2)
  assert_true(i.len() == 2)
  assert_true(i.contains(2) && i.contains(3))
}

///|
test "indexset_difference" {
  let s1 = IndexSet::from_array([1, 2, 3])
  let s2 = IndexSet::from_array([2, 3, 4])
  let d = s1.difference(s2)
  assert_true(d.len() == 1)
  assert_true(d.contains(1))
}

///|
test "indexset_subset_superset" {
  let s1 = IndexSet::from_array([1, 2])
  let s2 = IndexSet::from_array([1, 2, 3])
  assert_true(s1.is_subset(s2))
  assert_true(s2.is_superset(s1))
  assert_true(!s2.is_subset(s1))
}

///|
test "indexset_deterministic_trait" {
  let s1 = IndexSet::from_array([1, 2, 3])
  let s2 = IndexSet::from_array([1, 2, 3])
  let s3 = IndexSet::from_array([1, 2, 4])
  assert_true(s1.fingerprint() == s2.fingerprint())
  assert_true(s1.fingerprint() != s3.fingerprint())
  assert_true(s1.ordered_eq(s2))
  assert_true(!s1.ordered_eq(s3))
}

///|
test "indexset_symmetric_difference" {
  let s1 = IndexSet::from_array([1, 2, 3])
  let s2 = IndexSet::from_array([2, 3, 4])
  let sd = s1.symmetric_difference(s2)
  assert_true(sd.contains(1))
  assert_true(sd.contains(4))
  assert_true(!sd.contains(2))
  assert_true(!sd.contains(3))
}

///|
test "indexset_is_disjoint" {
  let s1 = IndexSet::from_array([1, 2])
  let s2 = IndexSet::from_array([3, 4])
  assert_true(s1.is_disjoint(s2))
  let s3 = IndexSet::from_array([2, 3])
  assert_true(!s1.is_disjoint(s3))
}

///|
test "indexset_empty_fingerprint" {
  let s : IndexSet[Int] = IndexSet::new()
  assert_true(s.fingerprint() == @fp.fnv_offset_basis)
}

///|
test "indexset_single_element" {
  let s : IndexSet[Int] = IndexSet::new()
  s.insert(42)
  assert_true(s.len() == 1)
  assert_true(s.contains(42))
  assert_true(!s.contains(43))
}
