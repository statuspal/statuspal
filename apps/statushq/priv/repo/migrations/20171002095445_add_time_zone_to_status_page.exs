defmodule Statushq.Repo.Migrations.AddTimeZoneToStatusPage do
  use Ecto.Migration

  def change do
    alter table(:status_pages) do
      add(:time_zone, :string, default: "Etc/UTC")
    end
  end
end
