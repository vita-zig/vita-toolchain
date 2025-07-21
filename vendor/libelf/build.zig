const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    lib_mod.link_libc = true;
    lib_mod.addIncludePath(upstream.path("lib"));

    lib_mod.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            "begin.c",
            "cntl.c",
            "end.c",
            "errmsg.c",
            "errno.c",
            "fill.c",
            "flag.c",
            "getarhdr.c",
            "getarsym.c",
            "getbase.c",
            "getdata.c",
            "getident.c",
            "getscn.c",
            "hash.c",
            "kind.c",
            "ndxscn.c",
            "newdata.c",
            "newscn.c",
            "next.c",
            "nextscn.c",
            "rand.c",
            "rawdata.c",
            "rawfile.c",
            "strptr.c",
            "update.c",
            "version.c",
            "checksum.c",
            // 32-bit sources
            "32.fsize.c",
            "32.getehdr.c",
            "32.getphdr.c",
            "32.getshdr.c",
            "32.newehdr.c",
            "32.newphdr.c",
            "32.xlatetof.c",
            // support
            "cook.c",
            "data.c",
            "input.c",
            "assert.c",
            // nlist
            "nlist.c",
            // opt
            "opt.delscn.c",
            "x.remscn.c",
            "x.movscn.c",
            "x.elfext.c",
            // 64-bit sources
            "64.xlatetof.c",
            "gelfehdr.c",
            "gelfphdr.c",
            "gelfshdr.c",
            "gelftrans.c",
            "swap64.c",
            // versioning sources
            "verdef_32_tof.c",
            "verdef_32_tom.c",
            "verdef_64_tof.c",
            "verdef_64_tom.c",
            // missing functions
            "memset.c",
        },
        .flags = &.{
            "-DSTDC_HEADERS",
            "-DHAVE_STDINT_H",
            "-DHAVE_MEMCMP=1",
            "-DHAVE_MEMCPY=1",
            "-DHAVE_MEMMOVE=1",
            "-DHAVE_MEMSET=1",
        },
    });
    const sys_elf_config = b.addConfigHeader(
        .{
            .style = .{
                .autoconf_undef = upstream.path("lib/sys_elf.h.in"),
            },
            .include_path = "libelf/sys_elf.h",
        },
        .{
            .__LIBELF_HEADER_ELF_H = .@"<elf.h>",
            .__LIBELF_NEED_LINK_H = false,
            .__LIBELF_NEED_SYS_LINK_H = false,
            .__LIBELF64 = true,
            .__LIBELF64_LINUX = target.result.os.tag == .linux,
            .__LIBELF_SYMBOL_VERSIONS = true,
            .__LIBELF64_IRIX = false,
            .__libelf_i64_t = .int64_t,
            .__libelf_u64_t = .uint64_t,
            .__libelf_i32_t = .int32_t,
            .__libelf_u32_t = .uint32_t,
            .__libelf_i16_t = .int16_t,
            .__libelf_u16_t = .uint16_t,
        },
    );
    // lib_mod.addConfigHeader(sys_elf_config);
    lib_mod.addIncludePath(sys_elf_config.getOutput().dirname());
    if (target.result.os.tag != .linux)
        lib_mod.addIncludePath(b.path("src"));

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "elf",
        .root_module = lib_mod,
    });
    lib.installHeader(upstream.path("lib/libelf.h"), "libelf.h");
    lib.installHeader(upstream.path("lib/libelf.h"), "libelf/libelf.h");
    lib.installHeader(upstream.path("lib/gelf.h"), "gelf.h");
    if (target.result.os.tag != .linux)
        lib.installHeader(b.path("src/elf.h"), "elf.h");
    lib.installConfigHeader(sys_elf_config);

    b.installArtifact(lib);
}
