defmodule Statushq.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      apps: [:statushq, :statushq_pro],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:distillery, "~> 1.4"},
    ]
  end
end
