defmodule MySuperAppWeb.SitePage do
  @moduledoc """
  Site Page
  """
  use MySuperAppWeb, :admin_surface_live_view

  require Logger

  alias MySuperApp.CasinosAdmins
  alias Moon.Design.Progress

  on_mount {MySuperAppWeb.UserAuth, :mount_current_user}

  def mount(params, _session, socket) do
    site = CasinosAdmins.get_site(Map.get(params, "id"))

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)
     |> assign(:site, site)
     |> assign(:image_path, nil)}
  end

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <.link navigate={~p"/admin/site-configs"}>
      <button
        id="menu_item_site"
        class="rounded-lg text-white pr-4 pl-4 pt-2 pb-2 text-base bg-popo hover:bg-neutral-700"
      >
        Back to site config page
      </button>
    </.link>

    <div class="container mx-auto pt-6">
      <div class="rounded-lg shadow-xl p-4 border-solid border-2 border-black-500">
        <h1 class="text-3xl font-bold mb-4 text-center text-black">
          Upload image to site: {@site.name}
        </h1>
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <div class="flex justify-around">
            <div class="bg-popo hover:bg-neutral-700 text-white font-bold py-2 px-4 rounded-md shadow-lg">
              <.live_file_input upload={@uploads.avatar} />
            </div>
            <button class="bg-popo hover:bg-neutral-700 text-white font-bold py-2 px-4 rounded-md">
              Upload Image To Site
            </button>
          </div>
        </form>

        {#for entry <- @uploads.avatar.entries}
          <article class="upload-entry mt-8">
            <div class="flex justify-between">
              <figure class="w-1/2">
                <.live_img_preview entry={entry} />
              </figure>
              <div class="w-full px-16">
                <h1 class="text-moon-24 my-4 text-black font-bold text-center">
                  Upload progress bar</h1>
                <Progress value={entry.progress} class="w-full my-auto" />
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                  class="bg-popo hover:bg-neutral-700 text-white font-bold py-2 px-4 rounded-full shadow-md transition duration-300 mt-2"
                >
                  Cancel Upload
                </button>
              </div>
            </div>
          </article>
        {/for}
        <img src={@site.image} width="1000" class="mt-6 mx-auto shadow-lg rounded-lg">
      </div>
    </div>
    """
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    with [%Cloudex.UploadedImage{secure_url: url_path}] <-
           consume_uploaded_entries(socket, :avatar, fn meta, _entry ->
             Cloudex.upload(meta.path)
           end),
         {:ok, _updated_site} <-
           CasinosAdmins.update_site_config(socket.assigns.site.id, %{"image" => url_path}) do
      Process.send_after(self(), :clear_flash, 3000)

      {:noreply,
       socket
       |> put_flash(:info, "Image updated")
       |> assign(:site, CasinosAdmins.get_site(socket.assigns.site.id))}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to upload avatar to Cloudinary")}
    end
  end
end
