defmodule StatushqWeb.Logo do
  use Arc.Definition
  use Arc.Ecto.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  # To add a thumbnail version:
  @versions [:original, :thumb, :tiny]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250 -gravity center"}
  end

  def transform(:tiny, _) do
    {:convert, "-strip -thumbnail 100x100 -gravity center"}
  end

  # Override the persisted filenames:
  def filename(_version, {file, page}) do
    prefix = if page, do: page.id, else: "tmp"
    filename = Path.basename(file.file_name, Path.extname(file.file_name))
    "#{prefix}-#{filename}"
  end

  # Override the storage directory:
  def storage_dir(version, {_file, _scope}) do
    "uploads/status_pages/logo/#{version}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
