///|
pub(open) trait Collection {
  fn len(Self) -> Int
  fn is_empty(Self) -> Bool
}

///|
pub(open) trait Deterministic: Collection {
  fn fingerprint(Self) -> UInt64
  fn ordered_eq(Self, Self) -> Bool
}
