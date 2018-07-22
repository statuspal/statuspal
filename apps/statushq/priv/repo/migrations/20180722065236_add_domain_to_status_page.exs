defmodule Statushq.Repo.Migrations.AddDomainToStatusPage do
  use Ecto.Migration

  def change do
    alter table(:status_pages) do
      add :domain, :string
    end
    create unique_index(:status_pages, [:domain])
    create index(:status_pages, [:plan])
  end
end
