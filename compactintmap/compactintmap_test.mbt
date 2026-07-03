///|
test "compactintmap_basic" {
  let m = @compactintmap.CompactIntMap::new()
  ignore(m.insert(5, "five"))
  ignore(m.insert(1, "one"))
  ignore(m.insert(10, "ten"))
  assert_true(m.get(5) == Some("five"))
  assert_true(m.get(1) == Some("one"))
  assert_true(m.get(10) == Some("ten"))
  assert_true(m.get(3) == None)
}

///|
test "compactintmap_sorted_order" {
  let m = @compactintmap.CompactIntMap::from_array([
    (5, "five"),
    (1, "one"),
    (10, "ten"),
  ])
  assert_true(m.min_key() == Some(1))
  assert_true(m.max_key() == Some(10))
  let ks = m.keys().to_array()
  assert_true(ks[0] == 1 && ks[1] == 5 && ks[2] == 10)
}

///|
test "compactintmap_remove" {
  let m = @compactintmap.CompactIntMap::from_array([
    (1, "a"),
    (2, "b"),
    (3, "c"),
  ])
  assert_true(m.remove(2) == Some("b"))
  assert_true(m.get(2) == None)
  assert_true(m.len() == 2)
}

///|
test "compactintmap_update" {
  let m = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 20)])
  assert_true(m.update(1, fn(v : Int) -> Int { v * 3 }))
  assert_true(m.get(1) == Some(30))
  assert_true(!m.update(99, fn(v : Int) -> Int { v }))
}

///|
test "compactintmap_overwrite" {
  let m = @compactintmap.CompactIntMap::new()
  let old = m.insert(1, "first")
  assert_true(old == None)
  let old2 = m.insert(1, "second")
  assert_true(old2 == Some("first"))
  assert_true(m.get(1) == Some("second"))
}

///|
test "compactintmap_each" {
  let m = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 20), (3, 30)])
  let mut sum = 0
  m.each(fn(_k : Int, v : Int) -> Unit { sum = sum + v })
  assert_true(sum == 60)
}

///|
test "compactintmap_clear" {
  let m = @compactintmap.CompactIntMap::from_array([(1, "a")])
  m.clear()
  assert_true(m.is_empty())
}

///|
test "compactintmap_collection_trait" {
  let m = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 20)])
  assert_true(m.len() == 2)
  assert_true(!m.is_empty())
}

///|
test "compactintmap_deterministic_trait" {
  let m1 = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 20)])
  let m2 = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 20)])
  let m3 = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 30)])
  assert_true(m1.fingerprint() == m2.fingerprint())
  assert_true(m1.fingerprint() != m3.fingerprint())
  assert_true(m1.ordered_eq(m2))
  assert_true(!m1.ordered_eq(m3))
}

///|
test "compactintmap_min_max_key" {
  let m = @compactintmap.CompactIntMap::from_array([
    (5, "a"),
    (10, "b"),
    (3, "c"),
  ])
  assert_true(m.min_key() == Some(3))
  assert_true(m.max_key() == Some(10))
}

///|
test "compactintmap_update_string" {
  let m = @compactintmap.CompactIntMap::from_array([(1, "a"), (2, "b")])
  ignore(m.update(1, fn(v : String) -> String { v + "x" }))
  assert_true(m.get(1) == Some("ax"))
}

///|
test "compactintmap_each_key_order" {
  let m = @compactintmap.CompactIntMap::from_array([
    (5, "e"),
    (1, "a"),
    (3, "c"),
  ])
  let keys : Array[Int] = []
  m.each(fn(k : Int, _v : String) -> Unit { keys.push(k) })
  assert_true(keys == [1, 3, 5])
}

///|
test "compactintmap_each_empty" {
  let m = @compactintmap.CompactIntMap::new()
  let mut called = false
  m.each(fn(_k : Int, _v : Int) -> Unit { called = true })
  assert_true(!called)
}

///|
test "compactintmap_iter" {
  let m = @compactintmap.CompactIntMap::from_array([(1, 10), (2, 20), (3, 30)])
  let pairs = m.iter().to_array()
  assert_true(pairs.length() == 3)
  assert_true(pairs[0] == (1, 10))
  assert_true(pairs[1] == (2, 20))
  assert_true(pairs[2] == (3, 30))
}

///|
test "compactintmap_iter_empty" {
  let m : @compactintmap.CompactIntMap[Int] = @compactintmap.CompactIntMap::new()
  let pairs = m.iter().to_array()
  assert_true(pairs.length() == 0)
}

///|
test "compactintmap_from_array_consistency" {
  let pairs : Array[(Int, String)] = [(5, "e"), (1, "a"), (3, "c"), (1, "dup")]
  let m = @compactintmap.CompactIntMap::from_array(pairs)
  assert_true(m.len() == 3)
  assert_true(m.get(1) == Some("dup"))
  assert_true(m.get(3) == Some("c"))
  assert_true(m.get(5) == Some("e"))
  let ks = m.keys().to_array()
  assert_true(ks == [1, 3, 5])
}

///|
test "compactintmap_from_array_empty" {
  let m : @compactintmap.CompactIntMap[Int] = @compactintmap.CompactIntMap::new()
  assert_true(m.is_empty())
  assert_true(m.len() == 0)
}

///|
test "compactintmap_clear_multiple" {
  let m = @compactintmap.CompactIntMap::from_array([
    (1, "a"),
    (2, "b"),
    (3, "c"),
  ])
  assert_true(m.len() == 3)
  m.clear()
  assert_true(m.is_empty())
  assert_true(m.len() == 0)
  assert_true(m.get(1) == None)
  assert_true(m.get(2) == None)
  ignore(m.insert(10, "new"))
  assert_true(m.get(10) == Some("new"))
  assert_true(m.len() == 1)
}

///|
test "compactintmap_fingerprint_cache_invalidation" {
  let m = @compactintmap.CompactIntMap::new()
  ignore(m.insert(1, "a"))
  let fp1 = m.fingerprint()
  let fp1_cached = m.fingerprint()
  assert_true(fp1 == fp1_cached)
  ignore(m.insert(2, "b"))
  let fp2 = m.fingerprint()
  assert_true(fp1 != fp2)
  ignore(m.remove(1))
  let fp3 = m.fingerprint()
  assert_true(fp2 != fp3)
}

///|
test "compactintmap_get_or_insert" {
  let m = @compactintmap.CompactIntMap::new()
  let v1 = m.get_or_insert(1, "default")
  assert_true(v1 == "default")
  let v2 = m.get_or_insert(1, "other")
  assert_true(v2 == "default")
  assert_true(m.get(1) == Some("default"))
}

///|
test "compactintmap_to_array" {
  let m = @compactintmap.CompactIntMap::from_array([
    (1, "a"),
    (2, "b"),
    (3, "c"),
  ])
  let arr = m.to_array()
  assert_true(arr == [(1, "a"), (2, "b"), (3, "c")])
  let empty : @compactintmap.CompactIntMap[String] = @compactintmap.CompactIntMap::new()
  assert_true(empty.to_array() == [])
}

///|
test "compactintmap_keys_array_values_array" {
  let m = @compactintmap.CompactIntMap::from_array([
    (1, "a"),
    (2, "b"),
    (3, "c"),
  ])
  assert_true(m.keys_array() == [1, 2, 3])
  assert_true(m.values_array() == ["a", "b", "c"])
}

///|
test "compactintmap_to_array_and_arrays" {
  let m = @compactintmap.CompactIntMap::from_array([(1, "a"), (2, "b")])
  let arr = m.to_array()
  assert_true(arr == [(1, "a"), (2, "b")])
  let ks = m.keys_array()
  assert_true(ks == [1, 2])
  let vs = m.values_array()
  assert_true(vs == ["a", "b"])
}

///|
test "compactintmap_get_or_insert_with" {
  let m = @compactintmap.CompactIntMap::new()
  let mut called = false
  let v1 = m.get_or_insert_with(1, fn() -> Int {
    called = true
    42
  })
  assert_true(v1 == 42)
  assert_true(called)
  let v2 = m.get_or_insert_with(1, fn() -> Int { 99 })
  assert_true(v2 == 42)
}
