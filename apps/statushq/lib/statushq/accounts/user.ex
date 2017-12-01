defmodule Statushq.Accounts.User do
  use Ecto.Schema
  use Coherence.Schema
  import WithPro
  import Ecto.Changeset
  with_pro do: use StatushqPro.Accounts.User
  alias Statushq.{Accounts, Accounts.User}

  schema "users" do
    field :name, :string
    field :email, :string
    with_pro do: StatushqPro.Accounts.User.schema()
    coherence_schema()

    timestamps()
  end

  def changeset(%User{} = user, params \\ %{}) do
    user
    |> cast(params, [:name, :email] ++ coherence_fields())
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
    |> validate_invited
  end

  def changeset(%User{} = user, params, :password) do
    user
    |> cast(params, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end

  def validate_invited(changeset = %{changes: %{email: email}}) do
    if WithPro.pro? do
      with_pro do
        if !changeset.data.id && !is_invited?(email),
          do: add_error(changeset, :email, "You need an invitation"),
          else: changeset
      end
    else
      changeset
    end
  end
  def validate_invited(changeset), do: changeset

  def is_invited?(email), do: Accounts.get_membership(email: email)
end
