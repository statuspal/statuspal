defmodule Statushq.Repo.Migrations.AddDisplayRTimeChart do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :display_response_time_chart, :boolean, default: false
    end
  end
end
