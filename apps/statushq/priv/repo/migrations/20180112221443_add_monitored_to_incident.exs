defmodule Statushq.Repo.Migrations.AddMonitoredToIncident do
  use Ecto.Migration

  def change do
    alter table(:incidents) do
      add :monitored, :boolean, default: false
    end
  end
end
