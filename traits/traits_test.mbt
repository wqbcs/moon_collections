///|
struct TestCollection {
  val : Int
}

///|
pub fn TestCollection::new(v : Int) -> TestCollection {
  { val: v }
}

///|
pub impl @traits.Collection for TestCollection with fn len(self) -> Int {
  self.val
}

///|
pub impl @traits.Collection for TestCollection with fn is_empty(self) -> Bool {
  self.val == 0
}

///|
pub impl @traits.Deterministic for TestCollection with fn fingerprint(self) -> UInt64 {
  42UL
}

///|
pub impl @traits.Deterministic for TestCollection with fn ordered_eq(
  self,
  other,
) -> Bool {
  self.val == other.val
}

///|
test "collection_trait_has_len_and_is_empty" {
  let tc = TestCollection::new(5)
  assert_true(!tc.is_empty())
  assert_true(tc.len() == 5)

  let empty = TestCollection::new(0)
  assert_true(empty.is_empty())
}

///|
test "deterministic_trait_extends_collection" {
  let a = TestCollection::new(10)
  assert_true(a.fingerprint() == 42UL)
  assert_true(a.len() == 10)

  let b = TestCollection::new(10)
  assert_true(a.ordered_eq(b))
}
