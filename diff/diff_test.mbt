///|
test "diff_arrays_basic" {
  let d = @diff.diff_arrays([1, 2, 3], [2, 3, 4])
  assert_true(d.added.length() == 1)
  assert_true(d.added[0] == 4)
  assert_true(d.removed.length() == 1)
  assert_true(d.removed[0] == 1)
}

///|
test "diff_arrays_empty" {
  let d = @diff.diff_arrays([1, 2], [1, 2])
  assert_true(d.is_empty())
  assert_true(d.total_changes() == 0)
}

///|
test "diff_arrays_all_added" {
  let d = @diff.diff_arrays([], [1, 2, 3])
  assert_true(d.added.length() == 3)
  assert_true(d.removed.length() == 0)
  assert_true(d.total_changes() == 3)
}

///|
test "diff_arrays_all_removed" {
  let d = @diff.diff_arrays([1, 2, 3], [])
  assert_true(d.added.length() == 0)
  assert_true(d.removed.length() == 3)
  assert_true(d.total_changes() == 3)
}

///|
test "lcs_length_basic" {
  let lcs = @diff.lcs_length([1, 2, 3, 4], [2, 4, 6])
  assert_true(lcs == 2)
}

///|
test "lcs_length_identical" {
  let lcs = @diff.lcs_length([1, 2, 3], [1, 2, 3])
  assert_true(lcs == 3)
}

///|
test "lcs_length_disjoint" {
  let lcs = @diff.lcs_length([1, 2], [3, 4])
  assert_true(lcs == 0)
}

///|
test "edit_distance_basic" {
  let dist = @diff.edit_distance([1, 2, 3], [1, 3, 2])
  assert_true(dist == 2)
}

///|
test "edit_distance_identical" {
  let dist = @diff.edit_distance([1, 2, 3], [1, 2, 3])
  assert_true(dist == 0)
}

///|
test "edit_distance_empty" {
  let dist = @diff.edit_distance([], [1, 2])
  assert_true(dist == 2)
}

///|
test "diff_sequences_basic" {
  let sd = @diff.diff_sequences([1, 2, 3], [1, 3, 4])
  assert_true(sd.distance == 2)
  assert_true(sd.ops.length() >= 3)
}
