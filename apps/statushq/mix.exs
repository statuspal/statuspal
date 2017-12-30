defmodule StatushqWeb.Mixfile do
  use Mix.Project

  def project do
    [app: :statushq,
     version: "1.0.20",
     elixir: "~> 1.5.1",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     build_path: "../../_build",
     lockfile: "../../mix.lock",
     deps_path: "../../deps"]
  end

  def pro(), do: System.get_env("PRO")

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    apps = [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
            :phoenix_ecto, :postgrex, :coherence, :timex, :arc, :arc_ecto,
            :canary, :canada, :mix, :extwitter, :oauther, :elixir_make]
    apps = if pro(), do: apps ++ [:statushq_pro, :edeliver], else: apps

    [mod: {Statushq.Application, []}, applications: apps]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    deps = [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "0.13.0"},
      {:cowboy, "~> 1.0"},
      {:coherence, "~> 0.5"},
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"},
      {:canary, "~> 1.1.0"},
      {:timex, "~> 3.1.24"},
      {:httpoison, "~> 0.11.1"},
      {:ex_machina, "~> 2.0", only: :test},
      {:distillery, "~> 1.4"},
      {:extwitter, "~> 0.8"},
   ]
   if pro(), do: deps ++ [
     {:statushq_pro, in_umbrella: true}, {:edeliver, ">= 1.4.2"}
     ], else: deps
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
