// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "wqbcs/moon_collections"

version = "0.1.0"

readme = "README.mbt.md"

repository = "https://github.com/wqbcs/moon_collections"

license = "Apache-2.0"

keywords = [
  "collections",
  "indexmap",
  "bitset",
  "bitflags",
  "counter",
  "default-map",
  "deterministic",
  "data-structure",
  "moonbit",
  "wasm",
  "wasm-gc",
  "fingerprint",
  "ringbuffer",
  "sparse-set",
  "sorted-map",
  "disjoint-set",
  "ordered-map",
  "verifiable",
  "composable",
  "ecs",
]

description = "DETERMINISTIC × VERIFIABLE × COMPOSABLE collections for MoonBit/WASM — 12 ordered structures, FNV-1a fingerprints with lazy caching (all 11 Deterministic structs), 286 tests. Same input → same output → same fingerprint, always."
