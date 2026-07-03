///|
test "to_sorted_map_from_indexmap" {
  let im = @indexmap.IndexMap::from_array([(3, "c"), (1, "a"), (2, "b")])
  let sm = to_sorted_map(im)
  assert_true(sm.keys_array() == [1, 2, 3])
  assert_true(sm.get(1) == Some("a"))
  assert_true(sm.get(2) == Some("b"))
  assert_true(sm.get(3) == Some("c"))
  assert_true(sm.len() == 3)
}

///|
test "to_index_map_from_sortedmap" {
  let sm = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b"), (3, "c")])
  let im = to_index_map(sm)
  assert_true(im.len() == 3)
  assert_true(im.get(1) == Some("a"))
  assert_true(im.get(2) == Some("b"))
  assert_true(im.get(3) == Some("c"))
}

///|
test "roundtrip_indexmap_sortedmap" {
  let im = @indexmap.IndexMap::from_array([(5, "e"), (1, "a"), (3, "c")])
  let sm = to_sorted_map(im)
  let im2 = to_index_map(sm)
  assert_true(im2.len() == 3)
  assert_true(im2.get(1) == Some("a"))
  assert_true(im2.get(3) == Some("c"))
  assert_true(im2.get(5) == Some("e"))
  assert_true(im2.keys_array() == [1, 3, 5])
}

///|
test "convert_indexmap_to_sorted_map" {
  let im = @indexmap.IndexMap::from_array([("b", 2), ("a", 1), ("c", 3)])
  let sm = @convert.to_sorted_map(im)
  assert_true(sm.keys_array() == ["a", "b", "c"])
}

///|
test "convert_sortedmap_to_index_map" {
  let sm = @sortedmap.SortedMap::from_array([(1, "a"), (2, "b"), (3, "c")])
  let im = @convert.to_index_map(sm)
  assert_true(im.keys_array() == [1, 2, 3])
}
