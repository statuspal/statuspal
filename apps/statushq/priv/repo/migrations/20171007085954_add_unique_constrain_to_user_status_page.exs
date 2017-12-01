defmodule Statushq.Repo.Migrations.AddUniqueConstrainToUserStatusPage do
  use Ecto.Migration

  def change do
    create unique_index(:users_status_pages, [:email, :status_page_id])
  end
end
