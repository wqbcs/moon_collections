///|
pub fn[K : Compare, V] to_sorted_map(
  im : @indexmap.IndexMap[K, V],
) -> @sortedmap.SortedMap[K, V] {
  let sm = @sortedmap.SortedMap::new()
  im.each(fn(k : K, v : V) -> Unit { ignore(sm.insert(k, v)) })
  sm
}

///|
pub fn[K : Hash + Eq, V] to_index_map(
  sm : @sortedmap.SortedMap[K, V],
) -> @indexmap.IndexMap[K, V] {
  let im = @indexmap.IndexMap::new()
  sm.each(fn(k : K, v : V) -> Unit { ignore(im.insert(k, v)) })
  im
}
