defmodule Statushq.Repo.Migrations.ChangeServicesIsUp do
  use Ecto.Migration

  def up do
    alter table(:services) do
      modify :is_up, :boolean, default: nil, null: true
    end
  end

  def down do
    alter table(:services) do
      modify :is_up, :boolean, default: true, null: false
    end
  end
end
