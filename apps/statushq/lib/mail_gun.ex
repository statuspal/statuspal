defmodule StatushqWeb.MailGun do
  use HTTPoison.Base

  def domain, do: Application.get_env(:statushq, :mailgun_domain)
  def api_key, do: Application.get_env(:statushq, :mailgun_api_key)

  def api_host do
    "https://api:#{api_key()}@api.mailgun.net/v3"
  end

  def process_url(url) do
    api_host() <> url
  end

  def process_response_body(body) do
    body
    |> Poison.Parser.parse!(keys: :atoms)
  end

  def create_list(address, name \\ nil) do
    post "/lists", {:form, [address: "#{address}@#{domain()}", name: name]}
  end

  def get_list(address) do
    get "/lists/#{address}@#{domain()}"
  end

  def add_list_member(list_name, member_address) do
    post "/lists/#{list_name}@#{domain()}/members", {:form, [address: member_address]}
  end

  # TODO: test with more than 1000 members
  def list_members(list_name) do
    {:ok, %{body: body}} = get "/lists/#{list_name}@#{domain()}/members/pages?limit=1000"
    list_members(list_name, body[:items], body[:paging][:next])
  end

  def list_members(list_name, members, next_url) when rem(length(members), 1000) == 0 do
    next_path = next_url |> String.split("/v3") |> List.last # use only the path part of the url
    {:ok, %{body: body}} = get next_path
    list_members(list_name, members ++ body[:items], body[:paging][:next])
  end
  def list_members(_list_name, members, _next_url), do: members
end
