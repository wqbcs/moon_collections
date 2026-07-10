///|
test "bitset_set_and_contains" {
  let bs = BitSet::new(128)
  bs.set(3)
  bs.set(7)
  bs.set(42)
  assert_true(bs.contains(3))
  assert_true(bs.contains(7))
  assert_true(bs.contains(42))
  assert_true(!bs.contains(0))
  assert_true(!bs.contains(5))
}

///|
test "bitset_clear" {
  let bs = BitSet::new(64)
  bs.set(5)
  assert_true(bs.contains(5))
  bs.clear(5)
  assert_true(!bs.contains(5))
}

///|
test "bitset_toggle" {
  let bs = BitSet::new(64)
  bs.toggle(3)
  assert_true(bs.contains(3))
  bs.toggle(3)
  assert_true(!bs.contains(3))
}

///|
test "bitset_count_ones" {
  let bs = BitSet::new(128)
  bs.set(0)
  bs.set(3)
  bs.set(7)
  assert_true(bs.count_ones() == 3)
}

///|
test "bitset_is_empty" {
  let bs = BitSet::new(64)
  assert_true(bs.is_empty())
  bs.set(5)
  assert_true(!bs.is_empty())
}

///|
test "bitset_union" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  let bs2 = BitSet::new(128)
  bs2.set(3)
  bs2.set(5)
  let result = bs1.union(bs2)
  assert_true(result.contains(1))
  assert_true(result.contains(3))
  assert_true(result.contains(5))
}

///|
test "bitset_intersect" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  let bs2 = BitSet::new(128)
  bs2.set(3)
  bs2.set(5)
  let result = bs1.intersect(bs2)
  assert_true(!result.contains(1))
  assert_true(result.contains(3))
  assert_true(!result.contains(5))
}

///|
test "bitset_is_subset" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  let bs2 = BitSet::new(128)
  bs2.set(1)
  bs2.set(3)
  bs2.set(5)
  assert_true(bs1.is_subset(bs2))
  assert_true(!bs2.is_subset(bs1))
}

///|
test "bitset_is_disjoint" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  let bs2 = BitSet::new(128)
  bs2.set(5)
  bs2.set(7)
  assert_true(bs1.is_disjoint(bs2))
  bs2.set(3)
  assert_true(!bs1.is_disjoint(bs2))
}

///|
test "bitset_from_indices" {
  let bs = BitSet::from_indices([3, 7, 42])
  assert_true(bs.contains(3))
  assert_true(bs.contains(7))
  assert_true(bs.contains(42))
  assert_true(!bs.contains(0))
  assert_true(!bs.contains(1))
}

///|
test "bitflags_trait_bitand" {
  let a = BitFlags::from_bits(0b1010UL)
  let b = BitFlags::from_bits(0b1100UL)
  let c = a & b
  assert_true(c.bits() == 0b1000UL)
}

///|
test "bitflags_trait_bitor" {
  let a = BitFlags::from_bits(0b1010UL)
  let b = BitFlags::from_bits(0b1100UL)
  let c = a | b
  assert_true(c.bits() == 0b1110UL)
}

///|
test "bitflags_trait_bitxor" {
  let a = BitFlags::from_bits(0b1010UL)
  let b = BitFlags::from_bits(0b1100UL)
  let c = a ^ b
  assert_true(c.bits() == 0b0110UL)
}

///|
test "bitflags_insert_remove" {
  let f = BitFlags::new().insert(0b0010UL).insert(0b1000UL)
  assert_true(f.contains(0b0010UL))
  assert_true(f.contains(0b1000UL))
  let f2 = f.remove(0b0010UL)
  assert_true(!f2.contains(0b0010UL))
  assert_true(f2.contains(0b1000UL))
}

///|
test "bitflags_toggle" {
  let f = BitFlags::new().toggle(0b0001UL)
  assert_true(f.contains(0b0001UL))
  let f2 = f.toggle(0b0001UL)
  assert_true(!f2.contains(0b0001UL))
}

///|
test "bitflags_is_subset_superset" {
  let a = BitFlags::from_bits(0b0011UL)
  let b = BitFlags::from_bits(0b0111UL)
  assert_true(a.is_subset(b))
  assert_true(b.is_superset(a))
  assert_true(!b.is_subset(a))
}

///|
test "bitflags_is_disjoint" {
  let a = BitFlags::from_bits(0b0011UL)
  let b = BitFlags::from_bits(0b1100UL)
  assert_true(a.is_disjoint(b))
  let c = BitFlags::from_bits(0b0110UL)
  assert_true(!a.is_disjoint(c))
}

///|
test "bitflags_count_zeros" {
  let f = BitFlags::from_bits(0b1010UL)
  assert_true(f.count_zeros() == 62)
}

///|
test "bitflags_to_bit_string" {
  let f = BitFlags::from_bits(0b1010UL)
  let s = f.to_bit_string()
  assert_true(s.length() == 64)
  assert_true(s == s)
}

///|
test "bitset_none" {
  let bs = BitSet::none()
  assert_true(bs.is_empty())
  assert_true(bs.length() == 0)
}

///|
test "bitset_first_one_last_one" {
  let bs = BitSet::new(128)
  bs.set(3)
  bs.set(7)
  bs.set(42)
  assert_true(bs.first_one() == Some(3))
  assert_true(bs.last_one() == Some(42))
  let empty = BitSet::new(64)
  assert_true(empty.first_one() == None)
  assert_true(empty.last_one() == None)
}

///|
test "bitset_next_one_prev_one" {
  let bs = BitSet::new(128)
  bs.set(3)
  bs.set(7)
  bs.set(42)
  assert_true(bs.next_one(4) == Some(7))
  assert_true(bs.next_one(8) == Some(42))
  assert_true(bs.next_one(43) == None)
  assert_true(bs.prev_one(10) == Some(7))
  assert_true(bs.prev_one(6) == Some(3))
}

///|
test "bitset_to_indices" {
  let bs = BitSet::new(128)
  bs.set(1)
  bs.set(3)
  bs.set(5)
  let indices = bs.to_indices()
  assert_true(indices.length() == 3)
  assert_true(indices[0] == 1 && indices[1] == 3 && indices[2] == 5)
}

///|
test "bitset_capacity" {
  let bs = BitSet::new(128)
  assert_true(bs.capacity() >= 128)
}

///|
test "bitset_resize" {
  let bs = BitSet::new(64)
  bs.set(5)
  bs.resize(200)
  assert_true(bs.contains(5))
  assert_true(bs.length() == 200)
}

///|
test "bitset_truncate" {
  let bs = BitSet::new(128)
  bs.set(5)
  bs.set(80)
  bs.truncate(50)
  assert_true(bs.contains(5))
  assert_true(!bs.contains(80))
  assert_true(bs.length() == 50)
}

///|
test "bitset_is_strict_subset" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  let bs2 = BitSet::new(128)
  bs2.set(1)
  bs2.set(2)
  assert_true(bs1.is_strict_subset(bs2))
  assert_true(!bs2.is_strict_subset(bs1))
}

///|
test "bitset_any_all_set" {
  let bs = BitSet::new(64)
  assert_true(!bs.any())
  bs.set(5)
  assert_true(bs.any())
  let bs2 = BitSet::new(4)
  bs2.set(0)
  bs2.set(1)
  bs2.set(2)
  bs2.set(3)
  assert_true(bs2.all_set())
}

///|
test "bitset_count_zeros" {
  let bs = BitSet::new(8)
  bs.set(0)
  bs.set(2)
  bs.set(4)
  assert_true(bs.count_zeros() == 5)
}

///|
test "bitflags_collection_trait" {
  let f = BitFlags::from_bits(0b1010UL)
  assert_true(f.len() == 2)
  assert_true(!f.is_empty())
  let empty = BitFlags::new()
  assert_true(empty.len() == 0)
  assert_true(empty.is_empty())
}

///|
test "bitflags_deterministic_trait" {
  let f1 = BitFlags::from_bits(0b1010UL)
  let f2 = BitFlags::from_bits(0b1010UL)
  let f3 = BitFlags::from_bits(0b1100UL)
  assert_true(f1.fingerprint() == f2.fingerprint())
  assert_true(f1.fingerprint() != f3.fingerprint())
  assert_true(f1.ordered_eq(f2))
  assert_true(!f1.ordered_eq(f3))
}

///|
test "bitset_fingerprint_includes_len" {
  let bs32 = BitSet::new(32)
  let bs64 = BitSet::new(64)
  bs32.set(3)
  bs64.set(3)
  assert_true(bs32.fingerprint() != bs64.fingerprint())
}

///|
test "bitset_fingerprint_deterministic" {
  let bs1 = BitSet::new(64)
  bs1.set(1)
  bs1.set(3)
  bs1.set(7)
  let bs2 = BitSet::new(64)
  bs2.set(1)
  bs2.set(3)
  bs2.set(7)
  assert_true(bs1.fingerprint() == bs2.fingerprint())
}

///|
test "bitset_difference" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  bs1.set(5)
  let bs2 = BitSet::new(128)
  bs2.set(3)
  bs2.set(5)
  bs2.set(7)
  let diff = bs1.difference(bs2)
  assert_true(diff.contains(1))
  assert_true(!diff.contains(3))
  assert_true(!diff.contains(5))
  assert_true(!diff.contains(7))
}

///|
test "bitset_symmetric_difference" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  let bs2 = BitSet::new(128)
  bs2.set(3)
  bs2.set(5)
  let sd = bs1.symmetric_difference(bs2)
  assert_true(sd.contains(1))
  assert_true(!sd.contains(3))
  assert_true(sd.contains(5))
}

///|
test "bitset_complement" {
  let bs = BitSet::new(8)
  bs.set(1)
  bs.set(3)
  let comp = bs.complement()
  assert_true(!comp.contains(1))
  assert_true(comp.contains(0))
  assert_true(!comp.contains(3))
  assert_true(comp.contains(2))
}

///|
test "bitset_is_superset" {
  let bs1 = BitSet::new(128)
  bs1.set(1)
  bs1.set(3)
  bs1.set(5)
  let bs2 = BitSet::new(128)
  bs2.set(1)
  bs2.set(3)
  assert_true(bs1.is_superset(bs2))
  assert_true(!bs2.is_superset(bs1))
}

///|
test "bitset_from_indices_empty" {
  let bs = BitSet::from_indices([])
  assert_true(bs.is_empty())
}

///|
test "bitset_from_indices_single" {
  let bs = BitSet::from_indices([0])
  assert_true(bs.contains(0))
  assert_true(bs.count_ones() == 1)
}

///|
test "bitset_set_all_clear_all" {
  let bs = BitSet::new(64)
  bs.set_all()
  assert_true(bs.all_set())
  bs.clear_all()
  assert_true(bs.is_empty())
}

///|
test "bitset_clone_independence" {
  let bs1 = BitSet::new(64)
  bs1.set(5)
  let bs2 = bs1.clone()
  bs2.clear(5)
  assert_true(bs1.contains(5))
  assert_true(!bs2.contains(5))
}

///|
test "bitset_to_bit_string" {
  let bs = BitSet::new(8)
  bs.set(1)
  bs.set(3)
  let s = bs.to_bit_string()
  assert_true(s.length() == 8)
}

///|
test "bitset_fingerprint_cache_invalidation" {
  let bs = BitSet::new(64)
  bs.set(1)
  let fp1 = bs.fingerprint()
  let fp1_cached = bs.fingerprint()
  assert_true(fp1 == fp1_cached)
  bs.set(5)
  let fp2 = bs.fingerprint()
  assert_true(fp1 != fp2)
}

///|
test "bitset_empty" {
  let bs = BitSet::new(64)
  assert_true(bs.len() == 64)
  assert_true(bs.is_empty())
  assert_true(bs.count_ones() == 0)
}

///|
test "bitflags_clear_all_set_all" {
  let bf = BitFlags::from_bits(0xFFUL)
  let cleared = bf.clear_all()
  assert_true(cleared == BitFlags::none())
  let set = bf.set_all()
  assert_true(set == BitFlags::all())
}

///|
test "bitset_block_boundary_first_last_one" {
  // Test block-level skipping across 64-bit boundaries
  let bs = BitSet::new(200)
  bs.set(0)
  bs.set(63)
  bs.set(64)
  bs.set(127)
  bs.set(150)
  assert_true(bs.first_one() == Some(0))
  assert_true(bs.last_one() == Some(150))
  // Clear first and last, re-check
  bs.clear(0)
  assert_true(bs.first_one() == Some(63))
  bs.clear(150)
  assert_true(bs.last_one() == Some(127))
}

///|
test "bitset_empty_mid_block_skip" {
  // Empty block in the middle: block 0 has bits, block 1 empty, block 2 has bits
  let bs = BitSet::new(200)
  bs.set(5)
  bs.set(130)
  assert_true(bs.first_one() == Some(5))
  assert_true(bs.last_one() == Some(130))
  assert_true(bs.next_one(6) == Some(130))
  assert_true(bs.prev_one(129) == Some(5))
  // len not aligned to 64
  bs.clear(5)
  bs.clear(130)
  let bs2 = BitSet::new(70)
  bs2.set(68)
  bs2.set(69)
  assert_true(bs2.first_one() == Some(68))
  assert_true(bs2.last_one() == Some(69))
  assert_true(bs2.next_one(68) == Some(68))
  assert_true(bs2.next_one(69) == Some(69))
  assert_true(bs2.next_one(70) == None)
}

///|
test "bitset_first_zero_last_zero_full_blocks" {
  // Zero search with full blocks
  let bs = BitSet::new(66)
  bs.set_all()
  assert_true(bs.first_zero() == None)
  assert_true(bs.last_zero() == None)
  // Clear one bit in each block
  bs.clear(0)
  assert_true(bs.first_zero() == Some(0))
  bs.clear(64)
  assert_true(bs.last_zero() == Some(64))
}

///|
test "bitset_next_prev_cross_block" {
  // next_one and prev_one crossing block boundaries
  let bs = BitSet::new(200)
  bs.set(10)
  bs.set(70)
  bs.set(130)
  assert_true(bs.next_one(10) == Some(10))
  assert_true(bs.next_one(11) == Some(70))
  assert_true(bs.next_one(71) == Some(130))
  assert_true(bs.next_one(131) == None)
  assert_true(bs.prev_one(130) == Some(130))
  assert_true(bs.prev_one(129) == Some(70))
  assert_true(bs.prev_one(69) == Some(10))
  assert_true(bs.prev_one(9) == None)
  // out-of-bounds handling
  assert_true(bs.next_one(-1) == None)
  assert_true(bs.next_one(200) == None)
  assert_true(bs.prev_one(-1) == None)
}

///|
test "bitset_truncate_preserves_invariants" {
  // Regression: after truncate, bits.length may exceed what len needs.
  // first_zero/last_zero must not compute negative shifts on trailing blocks.
  let bs = BitSet::new(200)
  bs.set(150)
  bs.truncate(64)
  // After truncate, bits.length is still >1 but len=64.
  // first_zero should work: all bits 0-63 are zero
  assert_true(bs.first_zero() == Some(0))
  assert_true(bs.len() == 64)
  // Set all valid bits, then check no zeros
  bs.set_all()
  assert_true(bs.first_zero() == None)
  assert_true(bs.last_zero() == None)
  // Clear bit 0, first_zero should find it
  bs.clear(0)
  assert_true(bs.first_zero() == Some(0))
  // Clear last valid bit
  bs.clear_all()
  bs.set(63)
  bs.clear(63)
  assert_true(bs.last_zero() == Some(63))
}
