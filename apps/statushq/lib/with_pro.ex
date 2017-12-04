defmodule WithPro do
  def pro?(), do: System.get_env("PRO") && Code.ensure_compiled?(StatushqPro)

  def disabled_for_plan(conn, plan, do: block) do
    if !pro?() || conn.assigns.status_page.plan != plan, do: block
  end

  defmacro with_pro(do: block) do
    if pro? do
      IO.puts "****** PRO ON"
      quote do
        unquote(block)
      end
    end
  end
end
