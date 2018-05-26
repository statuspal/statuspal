defmodule Statushq.Repo.Migrations.AddPageReferences do
  use Ecto.Migration

  def up do
    alter table(:services) do
      modify :status_page_id, references(:status_pages, on_delete: :delete_all)
    end
    alter table(:services_incidents) do
      modify :service_id, references(:services, on_delete: :delete_all)
      modify :incident_id, references(:incidents, on_delete: :delete_all)
    end
    alter table(:users_status_pages) do
      modify :status_page_id, references(:status_pages, on_delete: :delete_all)
    end
    alter table(:incidents) do
      modify :status_page_id, references(:status_pages, on_delete: :delete_all)
    end
    alter table(:incident_activities) do
      modify :incident_id, references(:incidents, on_delete: :delete_all)
    end
  end

  def down do
    alter table(:services) do
      modify :status_page_id, :integer
    end
    alter table(:services_incidents) do
      modify :service_id, :integer
      modify :incident_id, :integer
    end
    alter table(:users_status_pages) do
      modify :status_page_id, :integer
    end
    alter table(:incidents) do
      modify :status_page_id, :integer
    end
    alter table(:incident_activities) do
      modify :incident_id, :integer
    end

    drop constraint(:services, :services_status_page_id_fkey)
    drop constraint(:users_status_pages, :users_status_pages_status_page_id_fkey)
    drop constraint(:incidents, :incidents_status_page_id_fkey)
    drop constraint(:services_incidents, :services_incidents_service_id_fkey)
    drop constraint(:services_incidents, :services_incidents_incident_id_fkey)
    drop constraint(:incident_activities, :incident_activities_incident_id_fkey)
  end
end
