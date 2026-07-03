///|
fn main {
  println(
    "=== moon_collections: Deterministic Data Processing for MoonBit/WASM ===",
  )
  println("")

  println("--- PROOF: Same input => same fingerprint ---")
  let m1 = @indexmap.IndexMap::new()
  ignore(m1.insert("a", 1))
  ignore(m1.insert("b", 2))
  ignore(m1.insert("c", 3))
  let m2 = @indexmap.IndexMap::new()
  ignore(m2.insert("a", 1))
  ignore(m2.insert("b", 2))
  ignore(m2.insert("c", 3))
  println(
    "m1.fingerprint() == m2.fingerprint(): " +
    repr(m1.fingerprint() == m2.fingerprint()),
  )

  println("")
  println("--- PROOF: Different order => different fingerprint ---")
  let m3 = @indexmap.IndexMap::new()
  ignore(m3.insert("c", 3))
  ignore(m3.insert("a", 1))
  ignore(m3.insert("b", 2))
  println(
    "m1.fingerprint() != m3.fingerprint(): " +
    repr(m1.fingerprint() != m3.fingerprint()),
  )

  println("")
  println("--- PROOF: Remove preserves order (shift_remove) ---")
  let m4 = @indexmap.IndexMap::new()
  ignore(m4.insert("a", 1))
  ignore(m4.insert("b", 2))
  ignore(m4.insert("c", 3))
  ignore(m4.remove("b"))
  println("After remove('b'): " + repr(m4.keys_array()))

  println("")
  println("--- Counter: Deterministic frequency counting ---")
  let c = @counter.Counter::from_array(["a", "b", "a", "c", "a", "b"])
  println("Counter: " + repr(c.most_common(3)))

  println("")
  println("--- RingBuffer: WASM streaming ---")
  let rb = @ringbuffer.RingBuffer::new(3)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  let evicted = rb.push_back(4)
  println(
    "RingBuffer[3] push 4: " +
    repr(rb.to_array()) +
    ", evicted=" +
    repr(evicted),
  )

  println("")
  println("--- SparseSet: ECS O(1) operations ---")
  let ss = @sparseset.SparseSet::new(100)
  ignore(ss.insert(42, "player1"))
  ignore(ss.insert(99, "player2"))
  println(
    "SparseSet contains 42: " +
    repr(ss.contains(42)) +
    ", get 99: " +
    repr(ss.get(99)),
  )

  println("")
  println("All 11 data structures implement Collection + Deterministic traits.")
  println("Fingerprint lazy caching: O(n) first call, O(1) cached.")
  println("Same input => same output => same fingerprint. Always.")
}
