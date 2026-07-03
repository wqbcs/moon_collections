///|
test "sortedmap_insert_get" {
  let m = @sortedmap.SortedMap::new()
  ignore(m.insert(5, "five"))
  ignore(m.insert(1, "one"))
  ignore(m.insert(10, "ten"))
  assert_true(m.get(1) == Some("one"))
  assert_true(m.get(5) == Some("five"))
  assert_true(m.get(10) == Some("ten"))
  assert_true(m.get(3) == None)
}

///|
test "sortedmap_sorted_order" {
  let m = @sortedmap.SortedMap::from_array([
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
test "sortedmap_remove" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b"), (3, "c")])
  assert_true(m.remove(2) == Some("b"))
  assert_true(m.get(2) == None)
  assert_true(m.len() == 2)
}

///|
test "sortedmap_range" {
  let m = @sortedmap.SortedMap::from_array([
    (1, "a"),
    (3, "c"),
    (5, "e"),
    (7, "g"),
  ])
  let r = m.range(3, 7)
  assert_true(r.length() == 3)
  assert_true(r[0] == (3, "c"))
  assert_true(r[1] == (5, "e"))
  assert_true(r[2] == (7, "g"))
}

///|
test "sortedmap_filter" {
  let m = @sortedmap.SortedMap::from_array([(1, 10), (2, 20), (3, 30)])
  let f = m.filter(fn(k : Int, _v : Int) -> Bool { k >= 2 })
  assert_true(f.len() == 2)
  assert_true(f.get(1) == None)
  assert_true(f.get(2) == Some(20))
}

///|
test "sortedmap_merge" {
  let m1 = @sortedmap.SortedMap::from_array([(1, 10), (2, 20)])
  let m2 = @sortedmap.SortedMap::from_array([(2, 30), (3, 40)])
  let merged = m1.merge(m2, fn(a : Int, b : Int) -> Int { a + b })
  assert_true(merged.get(1) == Some(10))
  assert_true(merged.get(2) == Some(50))
  assert_true(merged.get(3) == Some(40))
}

///|
test "sortedmap_lower_upper_bound" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (3, "c"), (5, "e")])
  assert_true(m.lower_bound(3) == Some((3, "c")))
  assert_true(m.lower_bound(2) == Some((3, "c")))
  assert_true(m.upper_bound(3) == Some((5, "e")))
  assert_true(m.upper_bound(5) == None)
}

///|
test "sortedmap_collection_trait" {
  let m = @sortedmap.SortedMap::from_array([(1, 10), (2, 20)])
  assert_true(m.len() == 2)
  assert_true(!m.is_empty())
}

///|
test "sortedmap_deterministic_trait" {
  let m1 = @sortedmap.SortedMap::from_array([(1, 10), (2, 20)])
  let m2 = @sortedmap.SortedMap::from_array([(1, 10), (2, 20)])
  let m3 = @sortedmap.SortedMap::from_array([(1, 10), (2, 30)])
  assert_true(m1.fingerprint() == m2.fingerprint())
  assert_true(m1.fingerprint() != m3.fingerprint())
  assert_true(m1.ordered_eq(m2))
  assert_true(!m1.ordered_eq(m3))
}

///|
test "sortedmap_contains" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (3, "c")])
  assert_true(m.contains(1))
  assert_true(!m.contains(2))
  assert_true(m.contains(3))
}

///|
test "sortedmap_clear" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b")])
  m.clear()
  assert_true(m.is_empty())
  assert_true(m.len() == 0)
}

///|
test "sortedmap_update" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b")])
  let updated = m.update(1, fn(v : String) -> String { v + "x" })
  assert_true(updated)
  assert_true(m.get(1) == Some("ax"))
  let not_updated = m.update(99, fn(v : String) -> String { v })
  assert_true(!not_updated)
}

///|
test "sortedmap_get_or_insert" {
  let m = @sortedmap.SortedMap::new()
  let v1 = m.get_or_insert(1, "default")
  assert_true(v1 == "default")
  let v2 = m.get_or_insert(1, "other")
  assert_true(v2 == "default")
}

///|
test "sortedmap_values_and_iter" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b"), (3, "c")])
  let vs = m.values().to_array()
  assert_true(vs == ["a", "b", "c"])
  let entries = m.iter().to_array()
  assert_true(entries.length() == 3)
}

///|
test "sortedmap_each" {
  let m = @sortedmap.SortedMap::from_array([(1, 10), (2, 20)])
  let mut sum = 0
  m.each(fn(_k : Int, v : Int) -> Unit { sum = sum + v })
  assert_true(sum == 30)
}

///|
test "sortedmap_map_values" {
  let m = @sortedmap.SortedMap::from_array([(1, 10), (2, 20)])
  let mapped = m.map_values(fn(v : Int) -> String { repr(v) })
  assert_true(mapped.get(1) == Some("10"))
  assert_true(mapped.get(2) == Some("20"))
}

///|
test "sortedmap_fingerprint_cache_invalidation" {
  let m = @sortedmap.SortedMap::new()
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
test "sortedmap_to_array" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b"), (3, "c")])
  let arr = m.to_array()
  assert_true(arr == [(1, "a"), (2, "b"), (3, "c")])
  let empty : @sortedmap.SortedMap[Int, String] = @sortedmap.SortedMap::new()
  assert_true(empty.to_array() == [])
}

///|
test "sortedmap_keys_array_values_array" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b"), (3, "c")])
  assert_true(m.keys_array() == [1, 2, 3])
  assert_true(m.values_array() == ["a", "b", "c"])
}

///|
test "sortedmap_to_array_and_arrays" {
  let m = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b")])
  let arr = m.to_array()
  assert_true(arr == [(1, "a"), (2, "b")])
  let ks = m.keys_array()
  assert_true(ks == [1, 2])
  let vs = m.values_array()
  assert_true(vs == ["a", "b"])
}

///|
test "sortedmap_empty" {
  let m : @sortedmap.SortedMap[Int, String] = @sortedmap.SortedMap::new()
  assert_true(m.is_empty())
  assert_true(m.min_key() == None)
  assert_true(m.max_key() == None)
  assert_true(m.get(1) == None)
}

///|
test "sortedmap_get_or_insert_with" {
  let m = @sortedmap.SortedMap::new()
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
