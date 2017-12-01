defmodule Statushq.Repo.Migrations.CreateUserStatusPage do
  use Ecto.Migration

  def change do
    create table(:users_status_pages) do
      add :user_id, :integer
      add :status_page_id, :integer
        add :role, :string, size: 1, default: "o"

      timestamps()
    end

  end
end
