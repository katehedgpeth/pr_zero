defmodule Mix.Tasks.CompileFrontend do
  @moduledoc """
  Compiles React assets and moves them to /priv/static/webapp for production.
  """
  require Logger
  use Mix.Task

  @public_path "./priv/static/react_app"

  def run(_) do
    Logger.info("📦 - Installing NPM packages")
    System.cmd("npm", ["install --quiet"], cd: "./frontend")

    Logger.info("⚙️  - Compiling React frontend")
    System.cmd("npm", ["run", "build"], cd: "./frontend")

    Logger.info("🚛 - Moving dist folder to Phoenix at #{@public_path}")
    # clean up stale files from previous builds, if any
    System.cmd("rm", ["-rf", @public_path])
    System.cmd("cp", ["-R", "./frontend/dist", @public_path])

    Logger.info("⚛️  - React frontend ready!")
  end
end
