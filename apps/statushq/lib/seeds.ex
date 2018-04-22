defmodule Statushq.Seeds do
  alias Statushq.Repo
  alias Statushq.SPM.ActivityType

  def run do
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
  end
end
