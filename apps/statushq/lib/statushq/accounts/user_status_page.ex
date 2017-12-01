defmodule Statushq.Accounts.UserStatusPage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Statushq.Accounts.{User}
  alias Statushq.SPM.StatusPage

  schema "users_status_pages" do
    field :role, :string
    field :email, :string

    belongs_to :user, User
    belongs_to :status_page, StatusPage

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def status_page_creation_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :role])
    |> validate_required([:user_id, :role])
  end

  def changeset_for_invitations(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :role])
    |> validate_required([:email, :role])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email,
      name: :users_status_pages_email_status_page_id_index,
      message: "User is already a member or was already invited")
  end
end
