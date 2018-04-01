defmodule Statushq.Repo.Migrations.AddUptimeHistoryGraph do
  use Ecto.Migration

  def change do
    alter table(:status_pages) do
      add :display_uptime_graph, :boolean, default: true
    end
  end
end
