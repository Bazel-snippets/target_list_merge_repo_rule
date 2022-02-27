load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "bazel_skylib",
    commit = "f80bc733d4b9f83d427ce3442be2e07427b2cc8d",
    remote = "git@gitlab.tableausoftware.com:tableaubuild/bazel/mirrors/bazel/bazel-skylib.git",
    shallow_since = "1611945497 -0500",
)

load("@//:generate_target_list_merge.bzl", "generate_target_list_merge")

generate_target_list_merge()
