# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Statushq.Repo.insert!(%StatushqWeb.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Statushq.Repo
alias Statushq.SPM.ActivityType

activity_count = ActivityType |> Repo.all |> length

if activity_count < 1 do
  IO.puts "Running seeds"

  Repo.insert! ActivityType.changeset(%ActivityType{key: "investigating", name: "Investigating", active: true})
  Repo.insert! ActivityType.changeset(%ActivityType{key: "issue", name: "Issue", active: true})
  Repo.insert! ActivityType.changeset(%ActivityType{key: "monitoring", name: "Monitoring", active: true})
  Repo.insert! ActivityType.changeset(%ActivityType{key: "resolved", name: "Resolved", active: true})
  Repo.insert! ActivityType.changeset(%ActivityType{key: "scheduled", name: "Scheduled", active: true})
  Repo.insert! ActivityType.changeset(%ActivityType{key: "retroactive", name: "Retroactive", active: true})
end
