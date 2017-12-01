defmodule Statushq.Repo.Migrations.CreateActivityType do
  use Ecto.Migration

  def change do
    create table(:activity_types) do
      add :name, :string, null: false
      add :key, :string, null: false
      add :active, :boolean, default: false, null: false

      timestamps()
    end

  end
end
