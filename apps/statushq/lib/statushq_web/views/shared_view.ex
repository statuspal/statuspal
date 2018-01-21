defmodule StatushqWeb.SharedView do
  use StatushqWeb, :view
  import WithPro
  with_pro do: use StatushqProWeb.SharedView
end
