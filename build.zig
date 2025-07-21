const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });

    const libelf_dep = b.dependency("libelf", .{
        .target = target,
        .optimize = optimize,
    });

    const libyaml_dep = b.dependency("libyaml", .{
        .target = target,
        .optimize = optimize,
    });

    const libzip_dep = b.dependency("libzip", .{
        .target = target,
        .optimize = optimize,
    });

    const vita_toolchain_dep = b.dependency("vita-toolchain", .{});

    const vita_elf_create = build_vita_elf_create(b, .{
        .target = target,
        .optimize = optimize,
        .libelf_dep = libelf_dep,
        .libyaml_dep = libyaml_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_elf_create);

    const vita_elf_export = build_vita_elf_export(b, .{
        .target = target,
        .optimize = optimize,
        .libelf_dep = libelf_dep,
        .libyaml_dep = libyaml_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_elf_export);

    const vita_libs_gen = build_vita_libs_gen(b, .{
        .target = target,
        .optimize = optimize,
        .libyaml_dep = libyaml_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_libs_gen);

    const vita_libs_gen_2 = build_vita_libs_gen_2(b, .{
        .target = target,
        .optimize = optimize,
        .libyaml_dep = libyaml_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_libs_gen_2);

    const vita_nid_check = build_vita_nid_check(b, .{
        .target = target,
        .optimize = optimize,
        .libyaml_dep = libyaml_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_nid_check);

    const vita_make_fself = build_vita_make_fself(b, .{
        .target = target,
        .optimize = optimize,
        .libelf_dep = libelf_dep,
        .zlib_dep = zlib_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_make_fself);

    const vita_mksfoex = build_vita_mksfoex(b, .{
        .target = target,
        .optimize = optimize,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_mksfoex);

    const vita_pack_vpk = build_vita_pack_vpk(b, .{
        .target = target,
        .optimize = optimize,
        .libzip_dep = libzip_dep,
        .vita_toolchain_dep = vita_toolchain_dep,
    });
    b.installArtifact(vita_pack_vpk);
}

fn build_vita_elf_create(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-elf-create/elf-create-argp.c",
            "vita-elf-create/elf-defs.c",
            "vita-elf-create/elf-utils.c",
            "vita-elf-create/sce-elf.c",
            "vita-elf-create/vita-elf.c",
            "vita-elf-create/vita-elf-create.c",
            "vita-export-parse.c",
            "vita-import.c",
            "utils/yamlemitter.c",
            "utils/yamltree.c",
            "utils/yamltreeutil.c",
            "utils/sha256.c",
            "utils/varray.c",
        },
        .flags = &.{
            "-Wno-pointer-sign",
        },
    });

    if (options.target.result.os.tag == .windows) {
        exe_mod.addCSourceFile(.{ .file = options.vita_toolchain_dep.path("src/utils/strndup.c") });
        exe_mod.linkSystemLibrary("ws2_32", .{});
    }

    exe_mod.linkLibrary(options.libelf_dep.artifact("elf"));
    exe_mod.linkLibrary(options.libyaml_dep.artifact("yaml"));

    const exe = b.addExecutable(.{
        .name = "vita-elf-create",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_elf_export(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-elf-export/vita-elf-export.c",
            "vita-export-parse.c",
            "utils/yamlemitter.c",
            "utils/yamltree.c",
            "utils/yamltreeutil.c",
            "utils/sha256.c",
        },
        .flags = &.{
            "-Wno-pointer-sign",
        },
    });

    if (options.target.result.os.tag == .windows) {
        exe_mod.addCSourceFile(.{ .file = options.vita_toolchain_dep.path("src/utils/strndup.c") });
        exe_mod.linkSystemLibrary("ws2_32", .{});
    }

    exe_mod.linkLibrary(options.libyaml_dep.artifact("yaml"));

    const exe = b.addExecutable(.{
        .name = "vita-elf-export",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_libs_gen(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-libs-gen/vita-libs-gen.c",
            "vita-import.c",
            "vita-import-parse.c",
            "utils/yamlemitter.c",
            "utils/yamltree.c",
            "utils/yamltreeutil.c",
        },
    });
    exe_mod.linkLibrary(options.libyaml_dep.artifact("yaml"));

    const exe = b.addExecutable(.{
        .name = "vita-libs-gen",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_libs_gen_2(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.link_libcpp = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-libs-gen-2/vita-libs-gen-2.cpp",
            "vita-libs-gen-2/vita-nid-db-yml.c",
            "vita-libs-gen-2/vita-nid-db.c",
            "vita-import.c",
            "vita-import-parse.c",
            "utils/fs_list.c",
            "utils/yamlemitter.c",
            "utils/yamltree.c",
            "utils/yamltreeutil.c",
        },
    });
    exe_mod.linkLibrary(options.libyaml_dep.artifact("yaml"));

    const exe = b.addExecutable(.{
        .name = "vita-libs-gen-2",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_nid_check(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-nid-check/vita-nid-bypass.c",
            "vita-nid-check/vita-nid-check.c",
            "vita-libs-gen-2/vita-nid-db-yml.c",
            "vita-libs-gen-2/vita-nid-db.c",
            "utils/fs_list.c",
            "utils/yamlemitter.c",
            "utils/yamltree.c",
            "utils/yamltreeutil.c",
        },
    });
    exe_mod.linkLibrary(options.libyaml_dep.artifact("yaml"));

    const exe = b.addExecutable(.{
        .name = "vita-nid-check",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_make_fself(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-make-fself/vita-make-fself.c",
            "utils/sha256.c",
        },
    });
    exe_mod.linkLibrary(options.zlib_dep.artifact("z"));
    exe_mod.linkLibrary(options.libelf_dep.artifact("elf"));

    const exe = b.addExecutable(.{
        .name = "vita-make-fself",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_mksfoex(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-mksfoex/vita-mksfoex.c",
        },
    });

    const exe = b.addExecutable(.{
        .name = "vita-mksfoex",
        .root_module = exe_mod,
    });

    return exe;
}

fn build_vita_pack_vpk(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe_mod = b.createModule(.{
        .target = options.target,
        .optimize = options.optimize,
    });
    exe_mod.link_libc = true;
    exe_mod.addIncludePath(options.vita_toolchain_dep.path("src"));

    exe_mod.addCSourceFiles(.{
        .root = options.vita_toolchain_dep.path("src"),
        .files = &.{
            "vita-pack-vpk/vita-pack-vpk.c",
        },
    });
    exe_mod.linkLibrary(options.libzip_dep.artifact("zip"));

    const exe = b.addExecutable(.{
        .name = "vita-pack-vpk",
        .root_module = exe_mod,
    });

    return exe;
}
