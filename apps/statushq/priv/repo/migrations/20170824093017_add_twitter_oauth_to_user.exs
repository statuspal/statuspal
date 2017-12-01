defmodule Statushq.Repo.Migrations.AddTwitterOauthToUser do
  use Ecto.Migration

  def change do
    alter table(:status_pages) do
      add(:twitter_screen_name, :string)
      add(:twitter_oauth_token, :string)
      add(:twitter_oauth_token_secret, :string)
    end
  end
end
