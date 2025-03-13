defmodule MySuperAppWeb.UserJSON do
  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      operator_id: user.operator_id,
      role_id: user.role_id,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
