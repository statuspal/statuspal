defmodule Statushq.Repo.Migrations.AddEmailToMembers do
  use Ecto.Migration

  def change do
    alter table(:users_status_pages) do
      add :email, :string
    end
  end
end
