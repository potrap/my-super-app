defmodule MySuperApp.CasinosAdmins do
  @moduledoc """
  The `MySuperApp.CasinosAdmins` module provides functions for managing operators, roles, sites, and users within the casino administrator context.
  """

  alias MySuperApp.{Operator, Repo, Role, Site, Page, User}
  import Ecto.Query

  @doc """
  Returns a list of operators for use in a dropdown.
  Each element is represented as a key-value pair: `[key: operator_name, value: operator_id]`.
  """
  def operators_for_select() do
    Repo.all(Operator)
    |> Enum.map(fn role ->
      [key: role.name, value: role.id]
    end)
  end

  @doc """
  Retrieves all operators, ordered by their ID.
  Each operator is represented as a map containing the fields `id`, `name`, `inserted_at`, and `updated_at`.
  """
  def get_operators() do
    Repo.all(
      from operator in Operator,
        order_by: operator.id,
        select: map(operator, [:id, :name, :inserted_at, :updated_at])
    )
  end

  @doc """
  Counts the number of users associated with a given operator ID.
  """
  def count_users_with_operator(operator_id) do
    users = Repo.all(User)
    Enum.count(users, fn user -> user.operator_id == operator_id end)
  end

  @doc """
  Creates a new operator with the given attributes.
  """
  def create_operator(attrs \\ %{}) do
    %Operator{}
    |> Operator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves an operator by ID. Returns a map with the operator's fields or an empty map if the ID is nil.
  """
  def get_operator(nil), do: %{name: ""}

  def get_operator(id) do
    case Repo.get(Operator, id) do
      nil -> nil
      operator -> Map.from_struct(operator)
    end
  end

  @doc """
  Deletes an operator by ID.
  """
  def delete_operator(id) do
    Operator
    |> Repo.get(id)
    |> Repo.delete()
  end

  @doc """
  Updates an operator with the given ID and attributes.
  Returns `{:error, :not_found}` if the operator does not exist.
  """
  def update_operator(operator_id, attrs) do
    case Repo.get(Operator, operator_id) do
      nil ->
        {:error, :not_found}

      operator ->
        operator
        |> Operator.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Retrieves an operator by name.
  """
  def get_operator_by_name(name) do
    Repo.get_by(Operator, name: name)
  end

  @doc """
  Retrieves all operator names.
  """
  def operators_name() do
    Repo.all(from u in Operator, select: u.name)
  end

  @doc """
  Creates an operator changeset with the given attributes.
  """
  def operator_changeset(attrs \\ %{}) do
    Operator.changeset(%Operator{}, attrs)
  end

  def roles_name() do
    Repo.all(from u in Role, select: u.name)
    |> Enum.reject(fn role -> role == "super_admin" end)
  end

  def get_roles_by_name(name) do
    Repo.get_by(Role, name: name)
  end

  def get_role_by_name(name) do
    case Repo.get_by(Role, name: name) do
      %Role{} = role ->
        {:ok, role}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns a list of roles for a given operator, excluding the role "super_admin".
  Each element is represented as a key-value pair: `[key: role_name, value: role_id]`.
  """
  def roles_for_select(operator) do
    Repo.all(Role)
    |> Enum.reject(fn role -> role.name == "super_admin" end)
    |> Enum.filter(fn role -> role.operator_id == operator end)
    |> Enum.map(fn role ->
      [key: role.name, value: role.id]
    end)
  end

  @doc """
  Counts the number of users associated with a given role ID.
  """
  def count_users_with_role(role_id) do
    users = Repo.all(User)
    Enum.count(users, fn user -> user.role_id == role_id end)
  end

  @doc """
  Retrieves a role name by ID. Returns a map with the role's name or an empty map if the ID is nil.
  """
  def get_role_name(nil), do: %{name: ""}

  def get_role_name(id) do
    case Repo.get(Role, id) do
      nil -> nil
      role -> Map.from_struct(role)
    end
  end

  @doc """
  Retrieves a role by ID.
  """
  def get_role(id) do
    Repo.get(Role, id)
  end

  @doc """
  Retrieves all roles, sorted by their ID.
  """
  def get_all_roles_by_id() do
    Role
    |> Repo.all()
    |> Enum.map(&Map.from_struct(&1))
    |> Enum.sort_by(& &1.id, :asc)
  end

  @doc """
  Retrieves all roles for a given operator ID, sorted by their ID.
  """
  def get_all_roles_by_operator(id) do
    Role
    |> Repo.all()
    |> Enum.map(&Map.from_struct(&1))
    |> Enum.filter(fn x -> x.operator_id == id end)
    |> Enum.sort_by(& &1.id, :asc)
  end

  @doc """
  Creates a new role with the given attributes.
  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role with the given ID and attributes.
  Returns `{:error, :not_found}` if the role does not exist.
  """
  def update_role(role_id, attrs) do
    case Repo.get(Role, role_id) do
      nil ->
        {:error, :not_found}

      role ->
        role
        |> Role.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_role(id) do
    case get_role(id) do
      nil -> {:error, :not_found}
      role -> Repo.delete(role)
    end
  end

  @doc """
  Creates a role changeset with the given attributes.
  """
  def role_changeset(attrs \\ %{}) do
    Role.changeset(%Role{}, attrs)
  end

  @doc """
  Retrieves all sites, sorted by their ID.
  """
  def get_all_sites_by_id(params \\ %{}) do
    base_query()
    |> apply_search_filter(params)
    |> apply_date_filters(params)
    |> apply_sorting(params)
    |> apply_operator_filter(params)
    |> Repo.all()
    |> Enum.map(&Map.from_struct(&1))
  end

  defp apply_operator_filter(query, %{"operator_id" => operator_id}) when operator_id != nil do
    from s in query, where: s.operator_id == ^operator_id
  end

  defp apply_operator_filter(query, _params), do: query

  defp apply_sorting(query, %{"sort" => %{} = sort}) do
    {sort_key, sort_dir} =
      sort
      |> Map.to_list()
      |> Enum.at(0)

    order_by =
      case sort_dir do
        "ASC" -> [asc: sort_key]
        "DESC" -> [desc: sort_key]
        _ -> []
      end

    from s in query, order_by: ^order_by
  end

  defp apply_sorting(query, _params), do: query

  defp base_query() do
    from s in Site,
      order_by: [desc: s.inserted_at]
  end

  defp apply_search_filter(query, %{"search" => search_term}) do
    is_number = String.match?(search_term, ~r/^\d+$/)

    if is_number do
      from s in query,
        where: s.id == ^String.to_integer(search_term)
    else
      from s in query,
        join: o in assoc(s, :operator),
        where:
          ilike(s.name, ^"%#{String.downcase(search_term)}%") or
            ilike(o.name, ^"%#{String.downcase(search_term)}%")
    end
  end

  defp apply_search_filter(query, _params), do: query

  defp apply_date_filters(query, %{"from" => from_date, "to" => to_date}) do
    query
    |> apply_from_filter(from_date)
    |> apply_to_filter(to_date)
  end

  defp apply_date_filters(query, %{"from" => from_date}) do
    query
    |> apply_from_filter(from_date)
  end

  defp apply_date_filters(query, %{"to" => to_date}) do
    query
    |> apply_to_filter(to_date)
  end

  defp apply_date_filters(query, _params), do: query

  defp apply_from_filter(query, from_date) when from_date != "" do
    from_date = NaiveDateTime.from_iso8601!(from_date <> "T00:00:00")
    from s in query, where: s.inserted_at >= ^from_date
  end

  defp apply_from_filter(query, _), do: query

  defp apply_to_filter(query, to_date) when to_date != "" do
    to_date = NaiveDateTime.from_iso8601!(to_date <> "T23:59:59")
    from s in query, where: s.inserted_at <= ^to_date
  end

  defp apply_to_filter(query, _), do: query

  def get_sites_by_operator_name(operator_name) do
    from(s in Site,
      join: o in assoc(s, :operator),
      where: o.name == ^operator_name,
      select: s
    )
    |> Repo.all()
  end

  @doc """
  Creates a new site with the given attributes.
  """
  def create_site(attrs \\ %{}) do
    %Site{}
    |> Site.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves a site by ID.
  """
  def get_site(id) do
    Repo.get(Site, id)
  end

  @doc """
  Updates the configuration of a site with the given ID and attributes.
  """
  def update_site_config(id, attrs) do
    case Repo.get(Site, id) do
      %Site{} = site ->
        site
        |> Site.changeset(attrs)
        |> Repo.update()

      nil ->
        {:error, :not_found}
    end
  end

  def delete_site(id) do
    case Repo.get(Site, id) do
      %Site{} = site ->
        Repo.delete(site)

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Retrieves all sites for a given operator ID. If the ID is nil, returns all sites.
  """
  def get_all_sites_by_operator(nil), do: get_all_sites_by_id()

  def get_all_sites_by_operator(id) do
    Site
    |> Repo.all()
    |> Enum.map(&Map.from_struct(&1))
    |> Enum.filter(fn x -> x.operator_id == id end)
    |> Enum.sort_by(& &1.id, :asc)
  end

  @doc """
  Creates a site changeset with the given attributes.
  """
  def site_changeset(attrs \\ %{}) do
    Site.changeset(%Site{}, attrs)
  end

  @doc """
  Creates a new page with the given attributes.
  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves a user by ID.
  """
  def get_user(id) do
    Repo.get!(User, id)
  end

  @doc """
  Updates the repository with the given attributes.
  """
  def update_repo(attrs) do
    Repo.update(attrs)
  end

  @doc """
  Deletes the repository with the given attributes.
  """
  def repo_delete(user) do
    Repo.transaction(fn ->
      from(pt in "posts_tags",
        join: p in "posts",
        on: pt.post_id == p.id,
        where: p.user_id == ^user.id
      )
      |> Repo.delete_all()

      from(p in "posts", where: p.user_id == ^user.id)
      |> Repo.delete_all()

      Repo.delete!(user)
    end)
  end
end
