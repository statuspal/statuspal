defmodule Statushq.Reporter do
  defmacro report(level, message \\ "Runtime Error")

  defmacro report(:warn, message) do
    quote do
      {function_name, arity} = __ENV__.function

      Rollbax.report_message(:warning, unquote(message), %{
        function: "#{__MODULE__}##{function_name}/#{arity}",
        line: "#{__ENV__.file}:#{__ENV__.line}"
      })
    end
  end

  defmacro report(:error, message) do
    quote do
      {function_name, arity} = __ENV__.function

      Rollbax.report(:error, "#{__MODULE__}##{function_name}/#{arity}", System.stacktrace(), %{
        message: unquote(message)
      })
    end
  end
end
