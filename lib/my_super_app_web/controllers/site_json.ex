defmodule MySuperAppWeb.SiteJSON do
  @doc """
  Renders a list of sites.
  """
  def index(%{sites: sites}) do
    %{data: for(site <- sites, do: data(site))}
  end

  @doc """
  Renders a single site.
  """
  def show(%{site: site}) do
    %{data: data(site)}
  end

  defp data(%{} = site) do
    %{
      id: site.id,
      name: site.name,
      key: site.key,
      value: site.value,
      status: site.status,
      image: site.image,
      operator_id: site.operator_id,
      inserted_at: site.inserted_at
    }
  end
end
