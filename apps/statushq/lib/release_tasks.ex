defmodule Statushq.ReleaseTasks do
  alias Statushq.Repo
  alias Statushq.Accounts.User

  @start_apps [:statushq]

  def myapp, do: :statushq

  def repos, do: Application.get_env(myapp(), :ecto_repos, [])

  def seed do
    # Run migrations
    migrate()

    # Run seed script
    Enum.each(repos(), &run_seeds_for/1)

    # Signal shutdown
    IO.puts "Success!"
    :init.stop()
  end

  defp prepare do
    me = myapp()

    IO.puts "Loading #{me}.."
    # Load the code for myapp, but don't start it
    :ok = Application.load(me)

    IO.puts "Starting dependencies.."
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for myapp
    IO.puts "Starting repos.."
    Enum.each(repos(), &(&1.start_link(pool_size: 1)))
  end

  def setup do
    prepare()
    migrate()
    setupDefaultUser()
  end

  def migrate do
    Enum.each(repos(), &run_migrations_for/1)
  end

  def setupDefaultUser do
    users_count = User |> Repo.all |> length
    if users_count <= 0 do
      name = "Admin"
      email = "admin@statuspal.io"
      password = "status12345"
      IO.puts "Setting up default Admin user (Update it ASAP!!!):" <>
        "\n*****\nEmail: #{email}\nPassword: #{password}\n*****\n\n"

      User.setup_changeset(%User{}, %{name: name, email: email,
        password: password, password_confirmation: password})
      |> Repo.insert!

      IO.puts "Done"
    end
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts "Running migrations for #{app}"
    Ecto.Migrator.run(repo, migrations_path(repo), :up, all: true)
  end

  def run_seeds_for(repo) do
    # Run the seed script if it exists
    seed_script = seeds_path(repo)
    if File.exists?(seed_script) do
      IO.puts "Running seed script.."
      Code.eval_file(seed_script)
    end
  end

  def migrations_path(repo), do: priv_path_for(repo, "migrations")

  def seeds_path(repo), do: priv_path_for(repo, "seeds.exs")

  def priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)
    repo_underscore = repo |> Module.split |> List.last |> Macro.underscore
    Path.join([priv_dir(app), repo_underscore, filename])
  end
end
