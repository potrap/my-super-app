defmodule MySuperApp.CasinosAdminsTest do
  use MySuperApp.DataCase

  alias MySuperApp.CasinosAdmins
  alias MySuperApp.Site
  alias MySuperApp.Operator
  alias MySuperApp.Role
  alias MySuperApp.Repo

  setup do
    operator_attrs = %{name: "Test Operator"}

    {:ok, operator} =
      %Operator{}
      |> Operator.changeset(operator_attrs)
      |> Repo.insert()

    {:ok, operator: operator}
  end

  describe "get_all_sites_by_id/1" do
    test "returns all sites matching the filters", %{operator: operator} do
      site1 = %{
        name: "Casino One",
        status: "ACTIVE",
        value: 100,
        operator_id: operator.id,
        key: "cus1"
      }

      site2 = %{
        name: "Casino Two",
        status: "INACTIVE",
        value: 200,
        operator_id: operator.id,
        key: "cus2"
      }

      CasinosAdmins.create_site(site1)
      CasinosAdmins.create_site(site2)

      params = %{"search" => "Casino"}
      sites = CasinosAdmins.get_all_sites_by_id(params)

      assert length(sites) == 2
      assert Enum.any?(sites, fn site -> site.name == "Casino One" end)
      assert Enum.any?(sites, fn site -> site.name == "Casino Two" end)
    end

    test "returns empty list if no site matches" do
      params = %{"search" => "Non Existent"}
      sites = CasinosAdmins.get_all_sites_by_id(params)
      assert Enum.empty?(sites)
    end
  end

  describe "create_site/1" do
    test "successfully creates a new site", %{operator: operator} do
      site_attrs = %{
        name: "New Casino",
        status: "ACTIVE",
        value: 150,
        operator_id: operator.id,
        key: "new_casino"
      }

      assert {:ok, %Site{} = site} = CasinosAdmins.create_site(site_attrs)
      assert site.name == "New Casino"
      assert site.status == "ACTIVE"
      assert site.value == 150
      assert site.operator_id == operator.id
      assert site.key == "new_casino"
    end

    test "fails to create site with missing required fields", %{operator: operator} do
      site_attrs = %{
        status: "ACTIVE",
        value: 150,
        operator_id: operator.id,
        key: "missing_name"
      }

      assert {:error, changeset} = CasinosAdmins.create_site(site_attrs)
      assert changeset.errors[:name] != nil
    end
  end

  describe "get_site/1" do
    test "retrieves an existing site", %{operator: operator} do
      site_attrs = %{
        name: "Existing Casino",
        status: "ACTIVE",
        value: 100,
        operator_id: operator.id,
        key: "existing_casino"
      }

      {:ok, %Site{id: site_id}} = CasinosAdmins.create_site(site_attrs)

      site = CasinosAdmins.get_site(site_id)
      assert site.name == "Existing Casino"
      assert site.status == "ACTIVE"
      assert site.value == 100
      assert site.operator_id == operator.id
      assert site.key == "existing_casino"
    end

    test "returns nil for non-existent site" do
      assert CasinosAdmins.get_site(-1) == nil
    end
  end

  describe "update_site_config/2" do
    test "successfully updates an existing site", %{operator: operator} do
      site_attrs = %{
        name: "Casino to Update",
        status: "ACTIVE",
        value: 100,
        operator_id: operator.id,
        key: "casino_update"
      }

      {:ok, %Site{id: site_id}} = CasinosAdmins.create_site(site_attrs)

      assert {:ok, %Site{name: "Updated Casino"}} =
               CasinosAdmins.update_site_config(site_id, %{name: "Updated Casino"})

      site = CasinosAdmins.get_site(site_id)
      assert site.name == "Updated Casino"
    end

    test "fails to update a non-existent site" do
      assert {:error, _changeset} = CasinosAdmins.update_site_config(-1, %{name: "Non-existent"})
    end
  end

  describe "delete_site/1" do
    test "successfully deletes a site", %{operator: operator} do
      site_attrs = %{
        name: "Casino to Delete",
        status: "ACTIVE",
        value: 100,
        operator_id: operator.id,
        key: "casino_delete"
      }

      {:ok, %Site{id: site_id}} = CasinosAdmins.create_site(site_attrs)

      assert {:ok, %Site{}} = CasinosAdmins.delete_site(site_id)
      assert CasinosAdmins.get_site(site_id) == nil
    end

    test "fails to delete a non-existent site" do
      assert {:error, _changeset} = CasinosAdmins.delete_site(-1)
    end
  end

  describe "Role management" do
    setup do
      role_attrs = %{name: "Admin"}

      {:ok, role} =
        %Role{}
        |> Role.changeset(role_attrs)
        |> Repo.insert()

      {:ok, role: role}
    end

    test "create_role/1 creates a new role" do
      role_attrs = %{name: "Manager"}

      assert {:ok, %Role{} = role} = CasinosAdmins.create_role(role_attrs)
      assert role.name == "Manager"
    end

    test "get_role/1 retrieves a role by id", %{role: role} do
      fetched_role = CasinosAdmins.get_role(role.id)
      assert fetched_role.name == "Admin"
    end

    test "update_role/2 successfully updates a role", %{role: role} do
      updated_attrs = %{name: "SuperAdmin"}

      assert {:ok, %Role{name: "SuperAdmin"}} =
               CasinosAdmins.update_role(role.id, updated_attrs)

      updated_role = CasinosAdmins.get_role(role.id)
      assert updated_role.name == "SuperAdmin"
    end

    test "delete_role/1 successfully deletes a role", %{role: role} do
      assert {:ok, %Role{}} = CasinosAdmins.delete_role(role.id)
      assert CasinosAdmins.get_role(role.id) == nil
    end
  end
end
