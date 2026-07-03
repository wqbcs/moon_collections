///|
test "ringbuffer_push_pop" {
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  assert_true(rb.len() == 3)
  assert_true(rb.pop_front() == Some(1))
  assert_true(rb.pop_front() == Some(2))
  assert_true(rb.len() == 1)
}

///|
test "ringbuffer_overflow" {
  let rb = @ringbuffer.RingBuffer::new(3)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  let evicted = rb.push_back(4)
  assert_true(evicted == Some(1))
  assert_true(rb.len() == 3)
  assert_true(rb.front() == Some(2))
  assert_true(rb.back() == Some(4))
}

///|
test "ringbuffer_push_front" {
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  ignore(rb.push_front(1))
  assert_true(rb.front() == Some(1))
  assert_true(rb.back() == Some(3))
}

///|
test "ringbuffer_get_set" {
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(10))
  ignore(rb.push_back(20))
  ignore(rb.push_back(30))
  assert_true(rb.get(0) == Some(10))
  assert_true(rb.get(1) == Some(20))
  assert_true(rb.get(2) == Some(30))
  assert_true(rb.get(3) == None)
  assert_true(rb.set(1, 99))
  assert_true(rb.get(1) == Some(99))
}

///|
test "ringbuffer_rotate" {
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  rb.rotate_left(1)
  assert_true(rb.to_array()[0] == 2)
  assert_true(rb.to_array()[1] == 3)
  assert_true(rb.to_array()[2] == 1)
}

///|
test "ringbuffer_contains_count" {
  let rb = @ringbuffer.RingBuffer::new(6)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(1))
  assert_true(rb.contains(1))
  assert_true(rb.contains(2))
  assert_true(!rb.contains(3))
  assert_true(rb.count_item(1) == 2)
}

///|
test "ringbuffer_collection_trait" {
  let rb = @ringbuffer.RingBuffer::new(4)
  assert_true(rb.len() == 0)
  assert_true(rb.is_empty())
  ignore(rb.push_back(1))
  assert_true(rb.len() == 1)
  assert_true(!rb.is_empty())
}

///|
test "ringbuffer_deterministic_trait" {
  let rb1 = @ringbuffer.RingBuffer::new(4)
  ignore(rb1.push_back(1))
  ignore(rb1.push_back(2))
  let rb2 = @ringbuffer.RingBuffer::new(4)
  ignore(rb2.push_back(1))
  ignore(rb2.push_back(2))
  let rb3 = @ringbuffer.RingBuffer::new(4)
  ignore(rb3.push_back(1))
  ignore(rb3.push_back(3))
  assert_true(rb1.fingerprint() == rb2.fingerprint())
  assert_true(rb1.fingerprint() != rb3.fingerprint())
  assert_true(rb1.ordered_eq(rb2))
  assert_true(!rb1.ordered_eq(rb3))
}

///|
test "ringbuffer_remove_first" {
  let rb = @ringbuffer.RingBuffer::new(6)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  assert_true(rb.remove_first(2))
  assert_true(rb.len() == 2)
  assert_true(!rb.contains(2))
}

///|
test "ringbuffer_rotate_negative" {
  let rb = @ringbuffer.RingBuffer::new(6)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  ignore(rb.push_back(4))
  rb.rotate_left(-1)
  assert_true(rb.to_array() == [4, 1, 2, 3])
}

///|
test "ringbuffer_rotate_right_negative" {
  let rb = @ringbuffer.RingBuffer::new(6)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  rb.rotate_right(-1)
  assert_true(rb.to_array() == [2, 3, 1])
}

///|
test "ringbuffer_from_array" {
  let rb = @ringbuffer.RingBuffer::from_array([10, 20, 30])
  assert_true(rb.len() == 3)
  assert_true(rb.capacity() == 3)
  assert_true(rb.to_array() == [10, 20, 30])
}

///|
test "ringbuffer_from_array_empty" {
  let rb : @ringbuffer.RingBuffer[Int] = @ringbuffer.RingBuffer::from_array([])
  assert_true(rb.is_empty())
  assert_true(rb.capacity() == 1)
}

///|
test "ringbuffer_extend" {
  let rb = @ringbuffer.RingBuffer::new(6)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  rb.extend([3, 4, 5])
  assert_true(rb.len() == 5)
  assert_true(rb.to_array() == [1, 2, 3, 4, 5])
}

///|
test "ringbuffer_extend_overflow" {
  let rb = @ringbuffer.RingBuffer::new(3)
  ignore(rb.push_back(1))
  rb.extend([2, 3, 4])
  assert_true(rb.len() == 3)
  assert_true(rb.to_array() == [2, 3, 4])
}

///|
test "ringbuffer_resize_grow" {
  let rb = @ringbuffer.RingBuffer::new(3)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  let rb2 = rb.resize(6)
  assert_true(rb2.capacity() == 6)
  assert_true(rb2.len() == 2)
  assert_true(rb2.to_array() == [1, 2])
}

///|
test "ringbuffer_resize_shrink" {
  let rb = @ringbuffer.RingBuffer::new(6)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  let rb2 = rb.resize(2)
  assert_true(rb2.capacity() == 2)
  assert_true(rb2.len() == 2)
  assert_true(rb2.to_array() == [2, 3])
}

///|
test "ringbuffer_index_of" {
  let rb = @ringbuffer.RingBuffer::from_array([10, 20, 30])
  assert_true(rb.index_of(10) == Some(0))
  assert_true(rb.index_of(20) == Some(1))
  assert_true(rb.index_of(30) == Some(2))
  assert_true(rb.index_of(99) == None)
}

///|
test "ringbuffer_take" {
  let rb = @ringbuffer.RingBuffer::from_array([1, 2, 3, 4, 5])
  assert_true(rb.take(3) == [1, 2, 3])
  assert_true(rb.take(0) == [])
  assert_true(rb.take(10) == [1, 2, 3, 4, 5])
}

///|
test "ringbuffer_skip" {
  let rb = @ringbuffer.RingBuffer::from_array([1, 2, 3, 4, 5])
  assert_true(rb.skip(2) == [3, 4, 5])
  assert_true(rb.skip(0) == [1, 2, 3, 4, 5])
  assert_true(rb.skip(5) == [])
  assert_true(rb.skip(10) == [])
}

///|
test "ringbuffer_skip_negative" {
  let rb = @ringbuffer.RingBuffer::from_array([1, 2, 3])
  assert_true(rb.skip(-1) == [1, 2, 3])
}

///|
test "ringbuffer_reverse" {
  let rb = @ringbuffer.RingBuffer::from_array([1, 2, 3, 4])
  rb.reverse()
  assert_true(rb.to_array() == [4, 3, 2, 1])
}

///|
test "ringbuffer_reverse_single" {
  let rb = @ringbuffer.RingBuffer::from_array([42])
  rb.reverse()
  assert_true(rb.to_array() == [42])
}

///|
test "ringbuffer_reverse_after_wrap" {
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(1))
  ignore(rb.push_back(2))
  ignore(rb.push_back(3))
  ignore(rb.push_back(4))
  ignore(rb.pop_front())
  ignore(rb.push_back(5))
  rb.reverse()
  assert_true(rb.to_array() == [5, 4, 3, 2])
}

///|
test "ringbuffer_fingerprint_cache_invalidation" {
  let rb = @ringbuffer.RingBuffer::new(4)
  ignore(rb.push_back(1))
  let fp1 = rb.fingerprint()
  let fp1_cached = rb.fingerprint()
  assert_true(fp1 == fp1_cached)
  ignore(rb.push_back(2))
  let fp2 = rb.fingerprint()
  assert_true(fp1 != fp2)
}

///|
test "ringbuffer_empty" {
  let rb : @ringbuffer.RingBuffer[Int] = @ringbuffer.RingBuffer::new(4)
  assert_true(rb.len() == 0)
  assert_true(rb.is_empty())
  assert_true(rb.front() == None)
  assert_true(rb.get(0) == None)
}

///|
test "ringbuffer_iter" {
  let rb = @ringbuffer.RingBuffer::from_array([1, 2, 3])
  let items = rb.iter().to_array()
  assert_true(items == [1, 2, 3])
}
