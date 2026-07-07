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

name = "python123/moondepsolve"

version = "0.3.1"

readme = "README.md"

repository = "https://github.com/python123-ops/moondepsolve"

license = "Apache-2.0"

keywords = [
  "semver",
  "dependency-resolver",
  "package-manager",
  "solver",
  "contest",
]

description = "A MoonBit semantic version, version range, and dependency resolution library for package ecosystem tooling."

import {
  "moonbitlang/async@0.19.4",
}
