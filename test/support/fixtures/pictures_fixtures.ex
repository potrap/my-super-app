defmodule MySuperApp.PicturesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MySuperApp.Pictures` context.
  """

  @doc """
  Generate a picture.
  """
  def picture_fixture(attrs \\ %{}) do
    {:ok, picture} =
      attrs
      |> Enum.into(%{
        file_name: "some file_name",
        path: "some path",
        upload_at: ~U[2024-09-11 14:55:00Z]
      })
      |> MySuperApp.Pictures.create_picture()

    picture
  end
end
