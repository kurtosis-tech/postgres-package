# NOTE: If you're a VSCode user, you might like our VSCode extension: https://marketplace.visualstudio.com/items?itemName=Kurtosis.kurtosis-extension

# For more information on...
#  - the 'run' function:  https://docs.kurtosis.com/concepts-reference/packages#runnable-packages
#  - the 'plan' object:   https://docs.kurtosis.com/starlark-reference/plan
#  - the 'args' object:   https://docs.kurtosis.com/next/concepts-reference/args
def run(plan, args):
    args = override_default_args(args)
    plan.print("Hello, " + args["name"])


def override_default_args(args):
    default_args = {
        "name": "John Snow"
    }

    # See https://github.com/bazelbuild/starlark/blob/master/spec.md for all the cool stuff you can do in Starlark
    return default_args | args
