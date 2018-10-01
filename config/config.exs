# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :gitexpress, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:gitexpress, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"


# Configure location for blog posts:
# - a `local_source` for a directory where .md files get pulled to
# - a `remote_source` for a git repository where source .md files live
config :gitexpress,
  local_path: "/Users/juhalehtonen/blogposts",
  remote_repository_url: "https://gitlab.com/juhalehtonen/test.git",
  github_webhook_secret: "foo",
  github_webhook_path: "/api/github_webhook",
  github_webhook_action: {GitExPress.Webhook.GitHub, :handle}
