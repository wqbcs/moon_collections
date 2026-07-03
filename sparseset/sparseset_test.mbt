///|
test "sparseset_insert_get" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(3, "three"))
  ignore(ss.insert(7, "seven"))
  assert_true(ss.get(3) == Some("three"))
  assert_true(ss.get(7) == Some("seven"))
  assert_true(ss.get(5) == None)
  assert_true(ss.contains(3))
  assert_true(!ss.contains(5))
}

///|
test "sparseset_remove" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "a"))
  ignore(ss.insert(2, "b"))
  ignore(ss.insert(3, "c"))
  assert_true(ss.remove(2) == Some("b"))
  assert_true(!ss.contains(2))
  assert_true(ss.len() == 2)
  assert_true(ss.contains(1))
  assert_true(ss.contains(3))
}

///|
test "sparseset_overwrite" {
  let ss = @sparseset.SparseSet::new(10)
  assert_true(ss.insert(1, "first") == None)
  assert_true(ss.insert(1, "second") == Some("first"))
  assert_true(ss.get(1) == Some("second"))
}

///|
test "sparseset_clear" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "a"))
  ignore(ss.insert(2, "b"))
  ss.clear()
  assert_true(ss.is_empty())
  assert_true(!ss.contains(1))
}

///|
test "sparseset_each" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, 10))
  ignore(ss.insert(2, 20))
  ignore(ss.insert(3, 30))
  let mut sum = 0
  ss.each(fn(_k : Int, v : Int) -> Unit { sum = sum + v })
  assert_true(sum == 60)
}

///|
test "sparseset_collection_trait" {
  let ss = @sparseset.SparseSet::new(10)
  assert_true(ss.len() == 0)
  assert_true(ss.is_empty())
  ignore(ss.insert(1, "a"))
  assert_true(ss.len() == 1)
  assert_true(!ss.is_empty())
}

///|
test "sparseset_deterministic_trait" {
  let ss1 = @sparseset.SparseSet::new(10)
  ignore(ss1.insert(1, "a"))
  ignore(ss1.insert(2, "b"))
  let ss2 = @sparseset.SparseSet::new(10)
  ignore(ss2.insert(1, "a"))
  ignore(ss2.insert(2, "b"))
  let ss3 = @sparseset.SparseSet::new(10)
  ignore(ss3.insert(1, "a"))
  ignore(ss3.insert(3, "c"))
  assert_true(ss1.fingerprint() == ss2.fingerprint())
  assert_true(ss1.fingerprint() != ss3.fingerprint())
  assert_true(ss1.ordered_eq(ss2))
  assert_true(!ss1.ordered_eq(ss3))
}

///|
test "sparseset_fingerprint_includes_capacity" {
  let ss1 = @sparseset.SparseSet::new(10)
  ignore(ss1.insert(1, "a"))
  let ss2 = @sparseset.SparseSet::new(20)
  ignore(ss2.insert(1, "a"))
  assert_true(ss1.fingerprint() != ss2.fingerprint())
}

///|
test "sparseset_fingerprint_cache_invalidation" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "a"))
  let fp1 = ss.fingerprint()
  let fp1_cached = ss.fingerprint()
  assert_true(fp1 == fp1_cached)
  ignore(ss.insert(2, "b"))
  let fp2 = ss.fingerprint()
  assert_true(fp1 != fp2)
}

///|
test "sparseset_iter" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "a"))
  ignore(ss.insert(2, "b"))
  let items = ss.iter().to_array()
  assert_true(items.length() == 2)
}

///|
test "sparseset_value_eq" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "hello"))
  assert_true(ss.value_eq(1, "hello"))
  assert_true(!ss.value_eq(1, "world"))
  assert_true(!ss.value_eq(99, "hello"))
}

///|
test "sparseset_update" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(5, "start"))
  assert_true(ss.update(5, fn(v : String) -> String { v + "_updated" }))
  assert_true(ss.get(5) == Some("start_updated"))
  assert_true(!ss.update(99, fn(v : String) -> String { v }))
}

///|
test "sparseset_contains_value" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(1, "apple"))
  ignore(ss.insert(2, "banana"))
  assert_true(ss.contains_value("apple"))
  assert_true(ss.contains_value("banana"))
  assert_true(!ss.contains_value("cherry"))
}

///|
test "sparseset_each_index" {
  let ss = @sparseset.SparseSet::new(10)
  ignore(ss.insert(3, "c"))
  ignore(ss.insert(1, "a"))
  ignore(ss.insert(2, "b"))
  let indices : Array[Int] = []
  ss.each_index(fn(k : Int) -> Unit { indices.push(k) })
  assert_true(indices.length() == 3)
  assert_true(indices[0] == 3)
  assert_true(indices[1] == 1)
  assert_true(indices[2] == 2)
}
