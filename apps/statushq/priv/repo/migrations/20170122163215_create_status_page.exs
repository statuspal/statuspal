defmodule Statushq.Repo.Migrations.CreateStatusPage do
  use Ecto.Migration

  def change do
    create table(:status_pages) do
      add :name, :string
      add :url, :string
      add :subdomain, :string
      add :logo, :string

      timestamps()
    end

  end
end
