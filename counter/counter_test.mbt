///|
test "counter_basic" {
  let c = @counter.Counter::new()
  c.add("a")
  c.add("b")
  c.add("a")
  assert_true(c.get("a") == 2)
  assert_true(c.get("b") == 1)
  assert_true(c.get("c") == 0)
}

///|
test "counter_from_array" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a", "b"])
  assert_true(c.get("a") == 3)
  assert_true(c.get("b") == 2)
  assert_true(c.get("c") == 1)
}

///|
test "counter_subtract" {
  let c = @counter.Counter::from_array(["a", "a", "a"])
  c.subtract("a")
  assert_true(c.get("a") == 2)
  c.subtract("a")
  c.subtract("a")
  assert_true(c.get("a") == 0)
  assert_true(!c.contains("a"))
}

///|
test "counter_total" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c"])
  assert_true(c.total() == 4)
}

///|
test "counter_most_common" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a", "b"])
  let mc = c.most_common(2)
  assert_true(mc.length() == 2)
  assert_true(mc[0].0 == "a" && mc[0].1 == 3)
  assert_true(mc[1].0 == "b" && mc[1].1 == 2)
}

///|
test "counter_elements" {
  let c = @counter.Counter::new()
  c.set("a", 3)
  c.set("b", 2)
  let elems = c.elements()
  assert_true(elems.length() == 5)
}

///|
test "counter_add_subtract_counter" {
  let c1 = @counter.Counter::from_array(["a", "a", "b"])
  let c2 = @counter.Counter::from_array(["a", "c"])
  let sum = c1.add_counter(c2)
  assert_true(sum.get("a") == 3)
  assert_true(sum.get("b") == 1)
  assert_true(sum.get("c") == 1)
  let diff = c1.subtract_counter(c2)
  assert_true(diff.get("a") == 1)
  assert_true(!diff.contains("c"))
}

///|
test "counter_set_and_remove" {
  let c = @counter.Counter::new()
  c.set("x", 5)
  assert_true(c.get("x") == 5)
  c.set("x", 0)
  assert_true(!c.contains("x"))
  let c2 = @counter.Counter::new()
  c2.set("y", 3)
  assert_true(c2.remove("y") == 3)
  assert_true(c2.is_empty())
}

///|
test "counter_int_key" {
  let c : @counter.Counter[Int] = @counter.Counter::new()
  c.add(1)
  c.add(2)
  c.add(1)
  assert_true(c.get(1) == 2)
  assert_true(c.get(2) == 1)
}

///|
test "counter_iter" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a"])
  let result = c.iter().to_array()
  assert_true(result.length() == 3)
}

///|
test "counter_filter" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a"])
  let filtered = c.filter(fn(_k : String, v : Int) -> Bool { v >= 2 })
  assert_true(filtered.len() == 1)
  assert_true(filtered.get("a") == 3)
}

///|
test "counter_map_keys" {
  let c = @counter.Counter::from_array(["a", "b", "a"])
  let mapped = c.map_keys(fn(k : String) -> Int { k.length() })
  assert_true(mapped.get(1) == 3)
}

///|
test "counter_scale" {
  let c = @counter.Counter::from_array(["a", "b", "a"])
  let scaled = c.scale(3)
  assert_true(scaled.get("a") == 6)
  assert_true(scaled.get("b") == 3)
}

///|
test "counter_add_counter_merge" {
  let c1 = @counter.Counter::from_array(["x", "x", "y"])
  let c2 = @counter.Counter::from_array(["y", "z", "z", "z"])
  let sum = c1.add_counter(c2)
  assert_true(sum.get("x") == 2)
  assert_true(sum.get("y") == 2)
  assert_true(sum.get("z") == 3)
  assert_true(sum.total() == 7)
  let empty = @counter.Counter::new()
  let sum2 = c1.add_counter(empty)
  assert_true(sum2.get("x") == 2)
  assert_true(sum2.get("y") == 1)
}

///|
test "counter_subtract_counter_diff" {
  let c1 = @counter.Counter::from_array(["a", "a", "a", "b", "b"])
  let c2 = @counter.Counter::from_array(["a", "b", "c"])
  let diff = c1.subtract_counter(c2)
  assert_true(diff.get("a") == 2)
  assert_true(diff.get("b") == 1)
  assert_true(!diff.contains("c"))
  let diff2 = c2.subtract_counter(c1)
  assert_true(diff2.get("c") == 1)
  assert_true(!diff2.contains("a"))
}

///|
test "counter_items" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a"])
  let items = c.items()
  assert_true(items.length() == 3)
  let mut found_a = false
  let mut found_b = false
  let mut found_c = false
  let mut i = 0
  while i < items.length() {
    let (k, v) = items[i]
    if k == "a" {
      assert_true(v == 3)
      found_a = true
    }
    if k == "b" {
      assert_true(v == 1)
      found_b = true
    }
    if k == "c" {
      assert_true(v == 1)
      found_c = true
    }
    i = i + 1
  }
  assert_true(found_a && found_b && found_c)
  let empty : @counter.Counter[String] = @counter.Counter::new()
  assert_true(empty.items().length() == 0)
}

///|
test "counter_elements_expand" {
  let c = @counter.Counter::new()
  c.set("a", 2)
  c.set("b", 3)
  c.set("c", 1)
  let elems = c.elements()
  assert_true(elems.length() == 6)
  let mut count_a = 0
  let mut count_b = 0
  let mut count_c = 0
  let mut i = 0
  while i < elems.length() {
    match elems[i] {
      "a" => count_a = count_a + 1
      "b" => count_b = count_b + 1
      "c" => count_c = count_c + 1
      _ => ()
    }
    i = i + 1
  }
  assert_true(count_a == 2)
  assert_true(count_b == 3)
  assert_true(count_c == 1)
}

///|
test "counter_most_common_stable_sort" {
  let c = @counter.Counter::new()
  c.add("a")
  c.add("b")
  c.add("c")
  let top = c.most_common(3)
  assert_true(top.length() == 3)
  assert_true(top[0] == ("a", 1))
  assert_true(top[1] == ("b", 1))
  assert_true(top[2] == ("c", 1))
}

///|
test "counter_retain" {
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a"])
  c.retain(fn(_k : String, v : Int) -> Bool { v >= 2 })
  assert_true(c.len() == 1)
  assert_true(c.get("a") == 3)
  assert_true(c.get("b") == 0)
}

///|
test "counter_empty" {
  let c : @counter.Counter[String] = @counter.Counter::new()
  assert_true(c.is_empty())
  assert_true(c.total() == 0)
  assert_true(c.most_common(0).length() == 0)
}

///|
test "counter_most_common_zero" {
  let c = @counter.Counter::from_array(["a", "b"])
  assert_true(c.most_common(0).length() == 0)
}

///|
test "counter_from_array_with_weight" {
  let c = @counter.Counter::from_array_with_weight([
    ("a", 3),
    ("b", 2),
    ("a", 1),
  ])
  assert_true(c.get("a") == 4)
  assert_true(c.get("b") == 2)
  assert_true(c.total() == 6)
}

///|
test "counter_from_array_with_weight_zero" {
  // Items with weight 0 should not be stored
  let c = @counter.Counter::from_array_with_weight([("a", 5), ("b", 0)])
  assert_true(c.get("a") == 5)
  assert_true(!c.contains("b"))
}
