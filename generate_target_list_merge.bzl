# buildifier: disable=module-docstring
load("//:targets.bzl", "subsets_dict")

_target_list_merge_build_template = '''
load("@bazel_skylib//rules:common_settings.bzl", "string_list_flag")
load("target_list_merge.bzl", "target_list_merge", "targets_selector")

package(default_visibility = ["//visibility:public"])

string_list_flag(
    name = "subsets",
    build_setting_default = ["subset1"],
)

config_setting(
    name = "windows",
    constraint_values = [
        "@platforms//os:windows",
    ],
)

config_setting(
    name = "linux",
    constraint_values = [
        "@platforms//os:linux",
    ],
)

target_list_merge(
    name = "target_list_merge",
%s
)
'''

def _generate_target_list_merge_rule_impl(repository_ctx):
    set_names = subsets_dict.keys()

    print_statements_list = []
    for set_name in set_names:
        print_statements_list.append('    # print("\\ntargets_{set_name} = %s" % ctx.attr.targets_{set_name})'.format(set_name = set_name))
    print_statements = "\n".join(print_statements_list)

    combining_targets_list = []
    for set_name in set_names:
        combining_targets_list.append("    if \"{set_name}\" in subsets: combined_target_set = sets.union(combined_target_set, sets.make(ctx.attr.targets_{set_name}))".format(set_name = set_name))

    combining_targets = "\n".join(combining_targets_list)

    generated_attribute_definitions_list = []
    for set_name in set_names:
        generated_attribute_definitions_list.append('        "targets_%s": attr.label_list(),' % set_name)
    generated_attribute_definitions = "\n".join(generated_attribute_definitions_list)

    template_vars = {
        "%{print_statements}": print_statements,
        "%{combining_targets}": combining_targets,
        "%{generated_attribute_definitions}": generated_attribute_definitions,
    }
    repository_ctx.template(
        "target_list_merge.bzl",
        repository_ctx.path(repository_ctx.attr._target_list_merge_bzl_template),
        template_vars,
    )

    generated_attribute_instances_list = []
    for set_name in set_names:
        generated_attribute_instances_list.append('    targets_%s = targets_selector("%s"),' % (set_name, set_name))
    generated_attribute_instances = "\n".join(generated_attribute_instances_list)

    repository_ctx.file(
        "BUILD.bazel",
        executable = False,
        content = _target_list_merge_build_template % generated_attribute_instances,
    )

generate_target_list_merge_rule = repository_rule(
    implementation = _generate_target_list_merge_rule_impl,
    local = True,
    configure = True,
    attrs = {
        "_target_list_merge_bzl_template": attr.label(default = "target_list_merge_bzl_template.bzl"),
    },
)

def generate_target_list_merge():
    generate_target_list_merge_rule(
        name = "generate_target_list_merge",
    )
