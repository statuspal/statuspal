defmodule Mix.Tasks.Version do
  use Mix.Task

  @shortdoc "Gets current version"

  def run(_args) do
    IO.puts StatushqWeb.Mixfile.project[:version]
  end
end
