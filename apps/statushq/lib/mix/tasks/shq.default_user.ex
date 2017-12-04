defmodule Mix.Tasks.Shq.DefaultUser do
  use Mix.Task
  import Mix.Ecto
  alias Statushq.Repo
  alias Statushq.Accounts.User

  @shortdoc "Helps you setup a default user when none has been created"

  @moduledoc """
    If there is already at least one user this task will exit without warning.
  """

  def get_str(field_name) do
    str = IO.gets("#{field_name}: ")
    if String.length(str) > 1 do
      String.replace(str, "\n", "")
    else
      IO.puts "Error, #{field_name} is required!"
      get_str(field_name)
    end
  end

  def run(_args) do
    ensure_started(Repo, [])
    users_count = User |> Repo.all |> length
    if users_count <= 0 do
      Mix.shell.info "Setting up initial user for Statushq:\n"
      name = get_str "User's name"
      email = get_str "User's email"
      password = get_str "User's password"

      Mix.shell.info "Creating user..."

      User.setup_changeset(%User{}, %{name: name, email: email,
        password: password, password_confirmation: password})
      |> Repo.insert!
      |> Coherence.ControllerHelpers.confirm!

      Mix.shell.info "Done"
    else
      Mix.shell.info "Default user already created, aborting..."
    end
  end
end
