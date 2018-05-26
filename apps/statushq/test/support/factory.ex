defmodule StatushqWeb.Factory do
  use ExMachina.Ecto, repo: Statushq.Repo
  alias Statushq.Accounts.User
  alias Statushq.SPM.StatusPage

  def user_factory() do
    %User{
      name: sequence("username"),
      email: sequence(:email, &"email-#{&1}@example.com"),
    }
  end

  def status_page_factory() do
    %StatusPage{
      name: sequence("name"),
      url: sequence(:url, &"http://test#{&1}.com"),
      subdomain: sequence("subdomain"),
      time_zone: "UTC",
    }
  end
end
