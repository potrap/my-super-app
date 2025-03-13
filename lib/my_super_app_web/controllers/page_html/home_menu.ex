defmodule MySuperAppWeb.HomeLiveMenu do
  @moduledoc """
  LiveMenu
  """
  use MySuperAppWeb, :surface_live_view

  alias MySuperApp.{Repo, LeftMenu}
  alias MySuperApp.{Repo, RightMenu}
  alias Moon.Design.{MenuItem}

  data(expanded0, :boolean, default: false)
  data(expanded1, :boolean, default: true)
  data(expanded2, :boolean, default: false)
  data(left_menu, :any, default: [])
  data(right_menu, :any, default: [])

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="flex justify-around w-full mt-10">
      <div class="w-56 bg-whis-60 flex flex-col gap-2 rounded-moon-s-lg p-4 w-1/3">
        {#for menu <- @left_menu}
          {#if menu.title == "Tailwind"}
            <MenuItem role="switch" is_selected={@expanded0} title={menu.title} on_click="on_expand" />
          {#else}
            <MenuItem>{menu.title}</MenuItem>
          {/if}
        {/for}
      </div>
      <div class="w-56 bg-whis-60 flex flex-col gap-2 rounded-moon-s-lg p-4 w-1/3">
        {#for menu <- @right_menu}
          <MenuItem>{menu.title}</MenuItem>
        {/for}
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, left_menu: LeftMenu |> Repo.all(), right_menu: RightMenu |> Repo.all())}
  end

  def handle_event("on_expand" <> number, params, socket) do
    {:noreply, assign(socket, :"expanded#{number}", params["is-selected"] |> convert!)}
  end

  defp convert!("true"), do: true
  defp convert!("false"), do: false
end
