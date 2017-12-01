defmodule Statushq.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :name, :string
      add :ping_url, :string
      add :is_up, :boolean, default: true, null: false
      add :response_time_ms, :integer
      add :availability_perc, :float
      add :current_incident_type, :string
      add :status_page_id, :integer

      timestamps()
    end

  end
end
