defmodule Statushq.Repo.Migrations.AddUniqueConstrainToPages do
  use Ecto.Migration

  def change do
    create unique_index(:status_pages, [:name])
    create unique_index(:status_pages, [:url])
    create unique_index(:status_pages, [:subdomain])
  end
end
