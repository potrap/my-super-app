defmodule MySuperAppWeb.SiteController do
  use MySuperAppWeb, :controller

  alias MySuperApp.CasinosAdmins
  alias MySuperApp.Site

  action_fallback MySuperAppWeb.FallbackController

  def index(conn, %{"operator_name" => game_operator}) do
    sites = CasinosAdmins.get_sites_by_operator_name(game_operator)
    render(conn, :index, sites: sites)
  end

  def index(conn, params) do
    sites = CasinosAdmins.get_all_sites_by_id(params)
    render(conn, :index, sites: sites)
  end

  def create(conn, %{"site" => site_params}) do
    case CasinosAdmins.create_site(site_params) do
      {:ok, %Site{} = site} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/sites/#{site.id}")
        |> render(:show, site: site)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    case CasinosAdmins.get_site(id) do
      %{} = site ->
        render(conn, :show, site: site)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Site not found"})
    end
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    case CasinosAdmins.update_site_config(id, site_params) do
      {:ok, %Site{} = site} ->
        render(conn, :show, site: site)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Site not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def delete(conn, %{"id" => id}) do
    case CasinosAdmins.delete_site(id) do
      {:ok, %Site{}} ->
        send_resp(conn, :no_content, "")

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Site not found"})
    end
  end
end
