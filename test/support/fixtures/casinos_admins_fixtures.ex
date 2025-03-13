defmodule MySuperApp.CasinosAdminsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MySuperApp.CasinosAdmins` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{})
      |> MySuperApp.CasinosAdmins.create_role()

    role
  end

  @doc """
  Generate a site.
  """
  def site_fixture(attrs \\ %{}) do
    {:ok, site} =
      attrs
      |> Enum.into(%{})
      |> MySuperApp.CasinosAdmins.create_site()

    site
  end
end
