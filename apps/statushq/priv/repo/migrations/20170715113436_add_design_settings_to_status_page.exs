defmodule Statushq.Repo.Migrations.AddDesignSettingsToStatusPage do
  use Ecto.Migration

  def change do
    alter table(:status_pages) do
      add(:header_bg_color1, :string)
      add(:header_bg_color2, :string)
      add(:header_fg_color, :string)
      add(:incident_link_color, :string)
      add(:incident_header_color, :string)
    end
  end
end
