///|
test "indexmap_insert_and_get" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  assert_true(m.get("a") == Some(1))
  assert_true(m.get("b") == Some(2))
  assert_true(m.get("c") == Some(3))
  assert_true(m.get("d") == None)
}

///|
test "indexmap_len_and_empty" {
  let m = IndexMap::new()
  assert_true(m.is_empty())
  assert_true(m.len() == 0)
  ignore(m.insert("x", 10))
  assert_true(!m.is_empty())
  assert_true(m.len() == 1)
}

///|
test "indexmap_insert_overwrite" {
  let m = IndexMap::new()
  let old = m.insert("key", 1)
  assert_true(old == None)
  let old2 = m.insert("key", 2)
  assert_true(old2 == Some(1))
  assert_true(m.get("key") == Some(2))
  assert_true(m.len() == 1)
}

///|
test "indexmap_contains" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  assert_true(m.contains("a"))
  assert_true(!m.contains("b"))
}

///|
test "indexmap_get_index_of" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  assert_true(m.get_index_of("a") == Some(0))
  assert_true(m.get_index_of("b") == Some(1))
  assert_true(m.get_index_of("c") == Some(2))
  assert_true(m.get_index_of("d") == None)
}

///|
test "indexmap_get_index" {
  let m = IndexMap::new()
  ignore(m.insert("x", 10))
  ignore(m.insert("y", 20))
  assert_true(m.get_index(0) == Some(("x", 10)))
  assert_true(m.get_index(1) == Some(("y", 20)))
  assert_true(m.get_index(2) == None)
}

///|
test "indexmap_swap_remove" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  let removed = m.remove("b")
  assert_true(removed == Some(2))
  assert_true(m.len() == 2)
  assert_true(!m.contains("b"))
  assert_true(m.contains("a"))
  assert_true(m.contains("c"))
}

///|
test "indexmap_shift_remove" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  let removed = m.shift_remove("b")
  assert_true(removed == Some(2))
  assert_true(m.len() == 2)
  assert_true(m.get_index_of("a") == Some(0))
  assert_true(m.get_index_of("c") == Some(1))
}

///|
test "indexmap_clear" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  m.clear()
  assert_true(m.is_empty())
  assert_true(m.len() == 0)
}

///|
test "indexmap_retain" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  m.retain(fn(_k : String, v : Int) -> Bool { v > 1 })
  assert_true(m.len() == 2)
  assert_true(!m.contains("a"))
  assert_true(m.contains("b"))
  assert_true(m.contains("c"))
}

///|
test "indexmap_at" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  assert_true(m.at("a") == Some(1))
  assert_true(m.at("b") == Some(2))
}

///|
test "indexmap_reverse" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  m.reverse()
  assert_true(m.get_index_of("a") == Some(2))
  assert_true(m.get_index_of("b") == Some(1))
  assert_true(m.get_index_of("c") == Some(0))
}

///|
test "indexmap_move_to_front" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  assert_true(m.move_to_front("c"))
  assert_true(m.get_index_of("c") == Some(0))
  assert_true(m.get_index_of("a") == Some(1))
  assert_true(m.get_index_of("b") == Some(2))
}

///|
test "indexmap_move_to_back" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  assert_true(m.move_to_back("a"))
  assert_true(m.get_index_of("a") == Some(2))
  assert_true(m.get_index_of("b") == Some(0))
  assert_true(m.get_index_of("c") == Some(1))
}

///|
test "indexmap_pop_back_front" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  assert_true(m.pop_back() == Some(("c", 3)))
  assert_true(m.pop_front() == Some(("a", 1)))
  assert_true(m.len() == 1)
  assert_true(m.get("b") == Some(2))
}

///|
test "indexmap_rev_iter" {
  let m = IndexMap::new()
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  ignore(m.insert("c", 3))
  let arr = m.rev_iter().to_array()
  assert_true(arr[0] == ("c", 3))
  assert_true(arr[1] == ("b", 2))
  assert_true(arr[2] == ("a", 1))
}

///|
test "indexmap_bracket_syntax" {
  let m = IndexMap::new()
  m["x"] = 10
  m["y"] = 20
  assert_true(m["x"] == Some(10))
  assert_true(m["y"] == Some(20))
  assert_true(m["z"] == None)
  m["x"] = 99
  assert_true(m["x"] == Some(99))
}

///|
test "indexmap_int_key_generic" {
  let m : IndexMap[Int, String] = IndexMap::new()
  ignore(m.insert(1, "one"))
  ignore(m.insert(2, "two"))
  ignore(m.insert(3, "three"))
  assert_true(m.get(2) == Some("two"))
  assert_true(m.get_index_of(1) == Some(0))
  let removed = m.remove(2)
  assert_true(removed == Some("two"))
  assert_true(m.len() == 2)
}

///|
test "indexmap_from_array" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  assert_true(m.contains("a"))
  assert_true(m.contains("b"))
  assert_true(m.contains("c"))
  assert_true(m.len() == 3)
  assert_true(m.get("b") == Some(2))
}

///|
test "indexmap_entries" {
  let m = IndexMap::from_array([("x", 10), ("y", 20)])
  let es = m.entries()
  assert_true(es.length() == 2)
  assert_true(es[0].key == "x")
  assert_true(es[0].value == 10)
  assert_true(es[1].key == "y")
}

///|
test "indexmap_keys_array_values_array" {
  let m = IndexMap::from_array([("a", 1), ("b", 2)])
  let ks = m.keys_array()
  let vs = m.values_array()
  assert_true(ks[0] == "a" && ks[1] == "b")
  assert_true(vs[0] == 1 && vs[1] == 2)
}

///|
test "indexmap_first_last" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  assert_true(m.first() == Some(("a", 1)))
  assert_true(m.last() == Some(("c", 3)))
  let empty : IndexMap[String, Int] = IndexMap::new()
  assert_true(empty.first() == None)
  assert_true(empty.last() == None)
}

///|
test "indexmap_get_or_insert" {
  let m = IndexMap::new()
  let v1 = m.get_or_insert("key", 42)
  assert_true(v1 == 42)
  assert_true(m.len() == 1)
  let v2 = m.get_or_insert("key", 99)
  assert_true(v2 == 42)
  assert_true(m.len() == 1)
}

///|
test "indexmap_get_or_insert_with" {
  let m = IndexMap::new()
  let v1 = m.get_or_insert_with("key", fn() -> Int { 100 })
  assert_true(v1 == 100)
  let v2 = m.get_or_insert_with("key", fn() -> Int { 999 })
  assert_true(v2 == 100)
}

///|
test "indexmap_insert_before_after" {
  let m = IndexMap::from_array([("a", 1), ("c", 3)])
  assert_true(m.insert_before("c", "b", 2))
  assert_true(m.get_index_of("a") == Some(0))
  assert_true(m.get_index_of("b") == Some(1))
  assert_true(m.get_index_of("c") == Some(2))
  assert_true(m.insert_after("c", "d", 4))
  assert_true(m.get_index_of("d") == Some(3))
  assert_true(!m.insert_before("a", "a", 0))
}

///|
test "indexmap_swap_indices" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  assert_true(m.swap_indices(0, 2))
  assert_true(m.get_index_of("a") == Some(2))
  assert_true(m.get_index_of("c") == Some(0))
}

///|
test "indexmap_update" {
  let m = IndexMap::from_array([("a", 1), ("b", 2)])
  assert_true(m.update("a", fn(v : Int) -> Int { v * 10 }))
  assert_true(m.get("a") == Some(10))
  assert_true(!m.update("z", fn(v : Int) -> Int { v }))
}

///|
test "indexmap_update_or_insert" {
  let m = IndexMap::new()
  let v1 = m.update_or_insert("k", fn(v : Int) -> Int { v + 1 }, 5)
  assert_true(v1 == 5)
  assert_true(m.len() == 1)
  let v2 = m.update_or_insert("k", fn(v : Int) -> Int { v + 1 }, 5)
  assert_true(v2 == 6)
}

///|
test "indexmap_remove_entry" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  let removed = m.remove_entry("b")
  assert_true(removed == Some(("b", 2)))
  assert_true(m.len() == 2)
  assert_true(!m.contains("b"))
}

///|
test "indexmap_fingerprint_deterministic" {
  let m1 = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  let m2 = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  assert_true(
    @traits.Deterministic::fingerprint(m1) ==
    @traits.Deterministic::fingerprint(m2),
  )
}

///|
test "indexmap_fingerprint_different_data" {
  let m1 = IndexMap::from_array([("a", 1), ("b", 2)])
  let m2 = IndexMap::from_array([("x", 99), ("y", 88)])
  assert_true(
    @traits.Deterministic::fingerprint(m1) !=
    @traits.Deterministic::fingerprint(m2),
  )
}

///|
test "indexmap_fingerprint_order_matters" {
  let m1 = IndexMap::from_array([("a", 1), ("b", 2)])
  let m2 = IndexMap::from_array([("b", 2), ("a", 1)])
  assert_true(
    @traits.Deterministic::fingerprint(m1) !=
    @traits.Deterministic::fingerprint(m2),
  )
}

///|
test "indexmap_fingerprint_cached" {
  let m = IndexMap::from_array([("a", 1), ("b", 2)])
  let fp1 = @traits.Deterministic::fingerprint(m)
  let fp2 = @traits.Deterministic::fingerprint(m)
  assert_true(fp1 == fp2)
  ignore(m.insert("c", 3))
  let fp3 = @traits.Deterministic::fingerprint(m)
  assert_true(fp3 != fp1)
}

///|
test "indexmap_ordered_eq_consistency" {
  let m1 = IndexMap::from_array([("a", 1), ("b", 2)])
  let m2 = IndexMap::from_array([("a", 1), ("b", 2)])
  assert_true(@traits.Deterministic::ordered_eq(m1, m2))
  let m3 = IndexMap::from_array([("b", 2), ("a", 1)])
  assert_true(!@traits.Deterministic::ordered_eq(m1, m3))
}

///|
test "indexmap_get_or_insert_cache_invalidation" {
  let m = IndexMap::new()
  let fp1 = m.fingerprint()
  ignore(m.get_or_insert("a", 1))
  let fp2 = m.fingerprint()
  assert_true(fp2 != fp1)
  ignore(m.get_or_insert("a", 99))
  let fp3 = m.fingerprint()
  assert_true(fp3 == fp2)
}

///|
test "indexmap_get_or_insert_with_cache_invalidation" {
  let m = IndexMap::new()
  let fp1 = m.fingerprint()
  ignore(m.get_or_insert_with("x", fn() { 42 }))
  let fp2 = m.fingerprint()
  assert_true(fp2 != fp1)
}

///|
test "indexmap_remove_entry_preserves_order" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
  ignore(m.remove_entry("b"))
  assert_true(m.keys_array() == ["a", "c", "d"])
}

///|
test "indexmap_pop_back_cache_invalidation" {
  let m = IndexMap::from_array([("a", 1), ("b", 2)])
  let fp1 = m.fingerprint()
  ignore(m.pop_back())
  let fp2 = m.fingerprint()
  assert_true(fp2 != fp1)
}

///|
test "indexmap_insert_before_comprehensive" {
  let m = IndexMap::from_array([("a", 1), ("c", 3), ("e", 5)])
  assert_true(m.insert_before("c", "b", 2))
  assert_true(m.keys_array() == ["a", "b", "c", "e"])
  assert_true(m.insert_before("a", "z", 0))
  assert_true(m.keys_array() == ["z", "a", "b", "c", "e"])
  assert_true(!m.insert_before("c", "a", 99))
  assert_true(!m.insert_before("nonexist", "x", 1))
  assert_true(m.get("b") == Some(2))
  assert_true(m.get("z") == Some(0))
}

///|
test "indexmap_insert_after_comprehensive" {
  let m = IndexMap::from_array([("a", 1), ("c", 3), ("e", 5)])
  assert_true(m.insert_after("c", "d", 4))
  assert_true(m.keys_array() == ["a", "c", "d", "e"])
  assert_true(m.insert_after("e", "f", 6))
  assert_true(m.keys_array() == ["a", "c", "d", "e", "f"])
  assert_true(!m.insert_after("a", "c", 99))
  assert_true(!m.insert_after("nonexist", "x", 1))
  assert_true(m.get("d") == Some(4))
  assert_true(m.get("f") == Some(6))
}

///|
test "indexmap_sort_keys" {
  let m : IndexMap[Int, String] = IndexMap::new()
  ignore(m.insert(3, "three"))
  ignore(m.insert(1, "one"))
  ignore(m.insert(2, "two"))
  ignore(m.insert(5, "five"))
  m.sort_keys()
  assert_true(m.keys_array() == [1, 2, 3, 5])
  assert_true(m.values_array() == ["one", "two", "three", "five"])
}

///|
test "indexmap_swap_indices_comprehensive" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
  assert_true(m.swap_indices(0, 3))
  assert_true(m.keys_array() == ["d", "b", "c", "a"])
  assert_true(m.get_index_of("a") == Some(3))
  assert_true(m.get_index_of("d") == Some(0))
  assert_true(m.swap_indices(1, 2))
  assert_true(m.keys_array() == ["d", "c", "b", "a"])
  assert_true(!m.swap_indices(0, 10))
  assert_true(!m.swap_indices(-1, 1))
  assert_true(m.swap_indices(0, 0))
  assert_true(m.keys_array() == ["d", "c", "b", "a"])
}

///|
test "indexmap_to_array" {
  let m = IndexMap::from_array([("a", 1), ("b", 2), ("c", 3)])
  let arr = m.to_array()
  assert_true(arr == [("a", 1), ("b", 2), ("c", 3)])
  let empty : IndexMap[String, Int] = IndexMap::new()
  assert_true(empty.to_array() == [])
}

///|
test "indexmap_empty_fingerprint" {
  let m : IndexMap[String, Int] = IndexMap::new()
  assert_true(m.fingerprint() == @fp.fnv_offset_basis)
  let cached = m.fingerprint()
  assert_true(cached == @fp.fnv_offset_basis)
}
