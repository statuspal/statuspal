defmodule WithPro do
  def pro?(), do: System.get_env("PRO") && Code.ensure_compiled?(StatushqPro)

  defmacro with_pro(do: block) do
    if pro? do
      IO.puts "****** PRO ON"
      quote do
        unquote(block)
      end
    end
  end
end
