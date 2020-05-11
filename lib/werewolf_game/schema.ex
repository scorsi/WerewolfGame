defmodule WerewolfGame.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
    end
  end
end
