defmodule Statushq.Repo.Migrations.AddMonitoring do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :monitoring_enabled, :boolean, default: false
      add :auto_incident, :boolean, default: false
    end
  end
end
