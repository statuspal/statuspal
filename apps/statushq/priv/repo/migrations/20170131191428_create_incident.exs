defmodule Statushq.Repo.Migrations.CreateIncident do
  use Ecto.Migration

  def change do
    create table(:incidents) do
      add :title, :string
      add :type, :string, size: 1
      add :starts_at, :utc_datetime
      add :ends_at, :utc_datetime
      add :status_page_id, :integer

      timestamps()
    end

  end
end
