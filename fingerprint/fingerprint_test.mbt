///|
test "fnv1a_deterministic_byte" {
  let h1 = @fingerprint.fnv1a_hash_byte(42, @fingerprint.fnv_offset_basis)
  let h2 = @fingerprint.fnv1a_hash_byte(42, @fingerprint.fnv_offset_basis)
  assert_true(h1 == h2)
}

///|
test "fnv1a_deterministic_int" {
  let h1 = @fingerprint.fnv1a_hash_int(12345, @fingerprint.fnv_offset_basis)
  let h2 = @fingerprint.fnv1a_hash_int(12345, @fingerprint.fnv_offset_basis)
  assert_true(h1 == h2)
}

///|
test "fnv1a_different_inputs_different_hashes" {
  let h1 = @fingerprint.fnv1a_hash_int(1, @fingerprint.fnv_offset_basis)
  let h2 = @fingerprint.fnv1a_hash_int(2, @fingerprint.fnv_offset_basis)
  assert_true(h1 != h2)
}

///|
test "fingerprint_strings_deterministic" {
  let fp1 = @fingerprint.fingerprint_strings(["hello", "world"])
  let fp2 = @fingerprint.fingerprint_strings(["hello", "world"])
  assert_true(fp1 == fp2)
}

///|
test "fingerprint_strings_order_matters" {
  let fp1 = @fingerprint.fingerprint_strings(["a", "b"])
  let fp2 = @fingerprint.fingerprint_strings(["b", "a"])
  assert_true(fp1 != fp2)
}

///|
test "fingerprint_ints_deterministic" {
  let fp1 = @fingerprint.fingerprint_ints([1, 2, 3])
  let fp2 = @fingerprint.fingerprint_ints([1, 2, 3])
  assert_true(fp1 == fp2)
}

///|
test "fingerprint_empty_array" {
  let fp1 = @fingerprint.fingerprint_ints([])
  assert_true(fp1 == @fingerprint.fnv_offset_basis)
}

///|
test "fingerprint_combine" {
  let a = @fingerprint.fingerprint_ints([1])
  let b = @fingerprint.fingerprint_ints([2])
  let combined = @fingerprint.combine(a, b)
  assert_true(combined != 0UL)
}

///|
test "fingerprint_uint64s" {
  let fp1 = @fingerprint.fingerprint_uint64s([0xDEADUL, 0xBEEFUL])
  let fp2 = @fingerprint.fingerprint_uint64s([0xDEADUL, 0xBEEFUL])
  assert_true(fp1 == fp2)
}

///|
test "rolling_fingerprint_incremental" {
  let rf = @fingerprint.RollingFingerprint::new()
  rf.update_int(1)
  rf.update_int(2)
  rf.update_int(3)
  let full = @fingerprint.fingerprint_ints([1, 2, 3])
  assert_true(rf.hash() == full)
  assert_true(rf.count() == 3)
}

///|
test "rolling_fingerprint_order_matters" {
  let rf1 = @fingerprint.RollingFingerprint::new()
  rf1.update_string("a")
  rf1.update_string("b")
  let rf2 = @fingerprint.RollingFingerprint::new()
  rf2.update_string("b")
  rf2.update_string("a")
  assert_true(rf1.hash() != rf2.hash())
}

///|
test "rolling_fingerprint_combine" {
  let rf1 = @fingerprint.RollingFingerprint::new()
  rf1.update_int(1)
  let rf2 = @fingerprint.RollingFingerprint::new()
  rf2.update_int(2)
  let combined = rf1.combine(rf2)
  assert_true(combined.count() == 2)
}

///|
test "rolling_fingerprint_reset" {
  let rf = @fingerprint.RollingFingerprint::new()
  rf.update_int(42)
  assert_true(!rf.is_empty())
  rf.reset()
  assert_true(rf.is_empty())
  assert_true(rf.hash() == @fingerprint.fnv_offset_basis)
}
