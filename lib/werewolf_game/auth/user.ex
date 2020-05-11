defmodule WerewolfGame.Auth.User do
  @moduledoc false

  use WerewolfGame.Schema

  use Pow.Ecto.Schema,
    password_min_length: 8,
    password_max_length: 4096

  import Ecto.Changeset

  schema "auth_users" do
    pow_user_fields()

    field :nickname, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> cast(attrs, [:nickname])
    |> validate_required([:nickname])
    |> unique_constraint(:nickname)
  end
end
