///|
test "defaultmap_basic" {
  let m = @defaultmap.DefaultMap::new(fn() -> Int { 0 })
  assert_true(m.get("x") == 0)
  ignore(m.insert("x", 10))
  assert_true(m.get("x") == 10)
  assert_true(m.get("y") == 0)
}

///|
test "defaultmap_get_or_insert" {
  let m = @defaultmap.DefaultMap::new(fn() -> Int { 42 })
  let v1 = m.get_or_insert("key")
  assert_true(v1 == 42)
  ignore(m.insert("key", 100))
  let v2 = m.get_or_insert("key")
  assert_true(v2 == 100)
}

///|
test "defaultmap_update" {
  let m = @defaultmap.DefaultMap::new(fn() -> Int { 0 })
  m.update("cnt", fn(v : Int) -> Int { v + 1 })
  assert_true(m.get("cnt") == 1)
  m.update("cnt", fn(v : Int) -> Int { v + 1 })
  assert_true(m.get("cnt") == 2)
}

///|
test "defaultmap_remove" {
  let m = @defaultmap.DefaultMap::new(fn() -> String { "N/A" })
  ignore(m.insert("name", "Alice"))
  assert_true(m.remove("name") == Some("Alice"))
  assert_true(m.get("name") == "N/A")
}

///|
test "defaultmap_len_and_contains" {
  let m = @defaultmap.DefaultMap::new(fn() -> Int { -1 })
  assert_true(m.is_empty())
  ignore(m.insert("a", 1))
  ignore(m.insert("b", 2))
  assert_true(m.len() == 2)
  assert_true(m.contains("a"))
  assert_true(!m.contains("c"))
}

///|
test "defaultmap_iter" {
  let m = @defaultmap.DefaultMap::from_array(fn() -> Int { 0 }, [
    ("x", 1),
    ("y", 2),
    ("z", 3),
  ])
  let mut sum = 0
  m.iter().each(fn(pair : (String, Int)) -> Unit { sum = sum + pair.1 })
  assert_true(sum == 6)
}

///|
test "defaultmap_each_entry" {
  let m = @defaultmap.DefaultMap::from_array(fn() -> Int { 0 }, [
    ("a", 10),
    ("b", 20),
  ])
  let indices : Array[Int] = []
  let keys : Array[String] = []
  let vals : Array[Int] = []
  m.each_entry(fn(i : Int, k : String, v : Int) -> Unit {
    indices.push(i)
    keys.push(k)
    vals.push(v)
  })
  assert_true(indices == [0, 1])
  assert_true(keys == ["a", "b"])
  assert_true(vals == [10, 20])
}

///|
test "defaultmap_each_entry_empty" {
  let m = @defaultmap.DefaultMap::new(fn() -> Int { 0 })
  let mut called = false
  m.each_entry(fn(_i : Int, _k : String, _v : Int) -> Unit { called = true })
  assert_true(!called)
}

///|
test "defaultmap_retain" {
  let m = @defaultmap.DefaultMap::from_array(fn() -> Int { 0 }, [
    ("a", 1),
    ("b", 2),
    ("c", 3),
    ("d", 4),
  ])
  m.retain(fn(_k : String, v : Int) -> Bool { v % 2 == 0 })
  assert_true(m.len() == 2)
  assert_true(!m.contains("a"))
  assert_true(m.contains("b"))
  assert_true(!m.contains("c"))
  assert_true(m.contains("d"))
}

///|
test "defaultmap_retain_all" {
  let m = @defaultmap.DefaultMap::from_array(fn() -> Int { 0 }, [
    ("a", 1),
    ("b", 2),
  ])
  m.retain(fn(_k : String, _v : Int) -> Bool { true })
  assert_true(m.len() == 2)
}

///|
test "defaultmap_retain_none" {
  let m = @defaultmap.DefaultMap::from_array(fn() -> Int { 0 }, [
    ("a", 1),
    ("b", 2),
  ])
  m.retain(fn(_k : String, _v : Int) -> Bool { false })
  assert_true(m.is_empty())
}

///|
test "defaultmap_values" {
  let m = @defaultmap.DefaultMap::from_array(fn() -> Int { 0 }, [
    ("a", 10),
    ("b", 20),
    ("c", 30),
  ])
  let vals = m.values().to_array()
  assert_true(vals.length() == 3)
  let sum = vals[0] + vals[1] + vals[2]
  assert_true(sum == 60)
}

///|
test "defaultmap_values_empty" {
  let m : @defaultmap.DefaultMap[String, Int] = @defaultmap.DefaultMap::new(fn() -> Int {
    0
  })
  let vals = m.values().to_array()
  assert_true(vals.length() == 0)
}
