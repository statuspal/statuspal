defmodule Statushq.Repo.Migrations.CreateServiceIncident do
  use Ecto.Migration

  def change do
    create table(:services_incidents) do
      add :service_id, :integer
      add :incident_id, :integer

      timestamps()
    end

  end
end
