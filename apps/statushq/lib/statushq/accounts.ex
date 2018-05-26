defmodule Statushq.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  import WithPro
  alias Statushq.Repo
  alias Statushq.Accounts.{User, UserStatusPage}
  alias Statushq.SPM.StatusPage
  with_pro do: use StatushqPro.Accounts

  @roles %{"o" => "Owner", "a" => "Admin", "c" => "Collaborator"}
  @roles_options [{"Collaborator", "c"}, {"Owner", "o"}, {"Admin", "a"}]

  def roles, do: @roles
  def roles_options, do: @roles_options

  # UserStatusPage

  def list_membershipts(status_page) do
    UserStatusPage
    |> where(status_page_id: ^status_page.id)
    |> Repo.all
    |> Repo.preload(:user)
  end

  def get_membership!(id, preload_user: true) do
    get_membership!(id) |> Repo.preload(:user)
  end

  def get_membership(email: email) do
    UserStatusPage |> Repo.get_by(email: email)
  end

  def get_membership!(id), do: UserStatusPage |> Repo.get!(id)

  def change_membership(%UserStatusPage{} = m, attrs \\ %{}) do
    UserStatusPage.changeset_for_invitations(m, attrs)
  end

  def create_invite(%StatusPage{} = status_page, attrs) do
    %UserStatusPage{status_page_id: status_page.id}
    |> UserStatusPage.changeset_for_invitations(attrs)
    |> Repo.insert
  end

  def update_membership(id, attrs) do
    get_membership!(id) |> change_membership(attrs) |> Repo.update
  end

  def accept_invite(%User{} = user) do
    get_membership(email: user.email) |> accept_invite(user)
  end

  def accept_invite(%UserStatusPage{} = membership, user) do
    membership |> change(%{user_id: user.id}) |> Repo.update
  end

  def delete_membership!(id) do
    get_membership!(id) |> Repo.delete!
  end
end
