defmodule StatushqWeb.Factory do
  use ExMachina.Ecto, repo: Statushq.Repo
  alias Statushq.Accounts.{User}

  def user_factory do
    %User{
      name: "Test user",
      email: sequence(:email, &"email-#{&1}@example.com"),
    }
  end
end
