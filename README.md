[![CI](https://github.com/vita-zig/vita-toolchain/actions/workflows/ci.yaml/badge.svg)](https://github.com/vita-zig/vita-toolchain/actions)

# vita-toolchain

This is [vita-toolchain](ttps://github.com/vitasdk/vita-toolchain), packaged for [Zig](https://ziglang.org/).

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/vita-sdk/vita-toolchain.git
```

You can then import `vita-toolchain` in your `build.zig` with:

```zig
const vita_toolchain = b.dependency("vita-toolchain", .{
    .optimize = .ReleaseFast,
});
const vita_elf_create = b.addRunArtifact(vita_toolchain.artifact("vita-elf-create"));
```

