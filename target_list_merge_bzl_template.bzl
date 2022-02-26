# buildifier: disable=module-docstring
load("@//:targets.bzl", "subsets_dict", "additional_targets")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

CombinedTargetSetInfo = provider("", fields = {
    "target_set": "set of targets",
})

def _target_list_merge_rule_impl(ctx):
    subsets = ctx.attr._subsets[BuildSettingInfo].value
    print("subsets = %s" % subsets)

%{print_statements}
    combined_target_set = sets.make([])
%{combining_targets}
    print("combined_target_set = %s" % sets.to_list(combined_target_set))
    return CombinedTargetSetInfo(target_set = combined_target_set)

target_list_merge_rule = rule(
    implementation = _target_list_merge_rule_impl,
    attrs = {
%{generated_attribute_definitions}
        "additional_targets": attr.label_list(),
        "_subsets": attr.label(default = "subsets"),
    },
)

def target_list_merge(**attrs):
    target_list_merge_rule(
        additional_targets = additional_targets,
        # The target(s) instantiated by this rule are NOT only for building tests, but they MUST be
        # marked as "testonly" so Bazel will permit them to depend upon other test-only targets.
        testonly = True,
        tags = ["manual"],
        **attrs,
    )

# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def targets_selector(set_name):
    set_name = set_name.lower()
    build_types = subsets_dict[set_name].keys()
    select_dict = {}
    for build_type in build_types:
        build_type = build_type.lower()
        condition = build_type # "@tab_toolchains//conditions:" +
        selected_targets = list(subsets_dict[set_name][build_type])
        select_dict[condition] = selected_targets

    select_dict["//conditions:default"] = []
    # print("select_dict = %s" % select_dict)
    return select(select_dict)
