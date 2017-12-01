defmodule StatushqWeb.Admin.LayoutView do
  use StatushqWeb, :view
  import WithPro
  with_pro do: use StatushqProWeb.Admin.LayoutView
end
