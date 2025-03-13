defmodule MySuperApp.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MySuperApp.Blog` context.
  """

  @doc """
  Generate a post.
  """
  def chat_fixture() do
    {:ok, user} =
      MySuperApp.Accounts.register_user(%{
        username: "slots_operator222",
        email: "slotsoperator222@gmail.com",
        password: "123456789"
      })

    {:ok, chat} =
      MySuperApp.Accounts.ChatRooms.create_chatroom(%{
        name: "Communicate room",
        description: "Regular room",
        user_id: user.id
      })

    {user, chat}
  end
end
