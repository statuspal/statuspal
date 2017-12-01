defmodule Statushq.SPM.StatusPage do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import WithPro
  import Ecto.Changeset
  with_pro do: use StatushqPro.SPM.StatusPage

  alias Statushq.Accounts.UserStatusPage
  alias Statushq.SPM.{Services.Service}

  @derive {Phoenix.Param, key: :subdomain}

  schema "status_pages" do
    field :name, :string
    field :url, :string
    field :subdomain, :string
    with_pro do: StatushqPro.SPM.StatusPage.schema
    field :logo, StatushqWeb.Logo.Type
    field :time_zone, :string

    # design
    field :header_bg_color1, :string
    field :header_bg_color2, :string
    field :header_fg_color, :string
    field :incident_link_color, :string
    field :incident_header_color, :string

    # twitter oauth
    field :twitter_screen_name, :string
    field :twitter_oauth_token, :string
    field :twitter_oauth_token_secret, :string

    has_many :users_status_pages, UserStatusPage, on_delete: :delete_all
    has_many :services, Service, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :url, :subdomain, :time_zone, :logo, :header_bg_color1,
      :header_bg_color2, :header_fg_color, :incident_link_color, :incident_header_color])
    |> validate_required([:name, :url, :subdomain])
    |> cast_attachments(params, ~w(logo))
    |> cast_remove_logo(params)
    |> validate
  end

  def twitter_oauth_changeset(struct, params) do
    struct
    |> cast(params, [:twitter_screen_name, :twitter_oauth_token, :twitter_oauth_token_secret])
  end

  def creation_changeset(struct, params \\ %{}, user_id) do
    member_cs = UserStatusPage.status_page_creation_changeset(
      %UserStatusPage{user_id: user_id, role: "o"}
    )

    struct
    |> cast(params, [:name, :url, :subdomain, :time_zone])
    |> validate_required([:name, :url, :subdomain, :time_zone])
    |> put_assoc(:users_status_pages, [member_cs])
    |> validate
  end

  def avatar_changeset(page, params) do
    page |> cast_attachments(params, ~w(logo), ~w())
  end

  def validate(page) do
    page
    |> unique_constraint(:subdomain)
    |> unique_constraint(:url)
    |> unique_constraint(:name)
  end

  def cast_remove_logo(struct, params) do
    if params["remove_logo"] == "true", do: put_change(struct, :logo, nil), else: struct
  end
end
