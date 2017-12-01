alias Statushq.Accounts.{User, UserStatusPage}
alias Statushq.SPM.{StatusPage, Services.Service, Incident, IncidentActivity}
alias Statushq.Repo
import Ecto.Query, only: [where: 2]

defimpl Canada.Can, for: User do

  # StatusPage

  def can?(user = %User{}, action, page = %StatusPage{})
    when action in [:delete, :billing, :setup_billing, :update_billing] do
    !!(UserStatusPage |> where(user_id: ^user.id, status_page_id: ^page.id, role: "o") |> Repo.one)
  end

  def can?(user = %User{}, _, page = %StatusPage{}) do
    !!(UserStatusPage |> where(user_id: ^user.id, status_page_id: ^page.id) |> Repo.one)
  end

  def can?(_user = %User{}, _, _page = StatusPage) do
    true
  end

  # Service

  def can?(user = %User{}, _, service = %Service{}) do
    !!(UserStatusPage |> where(user_id: ^user.id, status_page_id: ^service.status_page_id) |> Repo.one)
  end

  def can?(_user = %User{}, _, Service) do
    true
  end

  # Incident

  def can?(user = %User{}, _, incident = %Incident{}) do
    !!(UserStatusPage |> where(user_id: ^user.id, status_page_id: ^incident.status_page_id) |> Repo.one)
  end

  def can?(_user = %User{}, _, Incident) do
    true
  end

  # IncidentActivity

  def can?(_user = %User{}, _, IncidentActivity) do
    true
  end

  def can?(_user = %User{}, _, %IncidentActivity{}) do
    true
  end

  # Members (UserStatusPage)

  def can?(%User{email: email}, :accept_invite, %UserStatusPage{email: email}) do
    true
  end
  def can?(%User{email: email}, :decline_invite, %UserStatusPage{email: email}) do
    true
  end
  def can?(%User{id: _id}, :delete, %UserStatusPage{role: "o"}), do: false
  def can?(%User{id: id}, :delete, %UserStatusPage{user_id: id}) do
    true
  end

  def can?(user = %User{}, _, membership = %UserStatusPage{}) do
    !!(UserStatusPage |> where(user_id: ^user.id, status_page_id: ^membership.status_page_id, role: "o") |> Repo.one) ||
    !!(UserStatusPage |> where(user_id: ^user.id, status_page_id: ^membership.status_page_id, role: "a") |> Repo.one)
  end

  def can?(_user = %User{}, _, UserStatusPage) do
    true
  end

  # Else

  def can?(_, _, nil), do: true
  def can?(_, _, _), do: false

  # def can?(a, b, c) do
  #   IO.puts "*** #{inspect a}\n*** #{inspect b}\n*** #{inspect c}"
  #   true
  # end
end
