defmodule Statushq.Repo.Migrations.CreateIncidentActivity do
  use Ecto.Migration

  def change do
    create table(:incident_activities) do
      add :description, :text
      add :activity_type_id, :integer
      add :incident_id, :integer

      timestamps()
    end

  end
end
