defmodule StatushqWeb.SharedView do
  use StatushqWeb, :view
  import WithPro
  with_pro do: use StatushqProWeb.SharedView

  def ga_code(), do: Application.get_env(:statushq, :google_analytics_id)
end
