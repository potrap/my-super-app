defmodule MySuperAppWeb.HomeLive do
  use MySuperAppWeb, :surface_live_view

  alias Moon.Design.Button

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <main class="text-gray-900">
      <section class="">
        <div class="container mx-auto px-8">
          <div class="text-center" style="text-align: center">
            <h1 class="text-4xl lg:text-5xl xl:text-6xl font-bold leading-none text-center">This is Potrap's Project
            </h1>
          </div>
        </div>
      </section>

      <section id="features" class="py-20 lg:pb-40 lg:pt-24">
        <div class="container mx-auto text-center">
          <h2 class="text-3xl lg:text-5xl font-semibold">Main Features</h2>
          <div class="flex flex-col sm:flex-row sm:-mx-3 mt-12">
            <div class="flex-1 px-3">
              <div
                class="p-12 rounded-lg border border-solid border-gray-200 mb-8"
                style="box-shadow:0 10px 28px rgba(0,0,0,.08)"
              >
                <p class="font-semibold text-xl">Chat Room
                </p>
                <p class="mt-4">Engage in real-time conversations with our dynamic Chat Room feature. Connect with friends, family, and colleagues effortlessly. Our Chat Room offers a seamless and interactive experience with instant messaging, allowing you to share thoughts, ideas, and updates instantly. Enjoy a secure and user-friendly interface that keeps you connected and engaged in meaningful discussions.
                </p>
                <div class="flex align-center justify-center pt-8">
                  <Button class="bg-popo hover:bg-neutral-700" as="a" href="/chatroom">Chat Room Page</Button>
                </div>
              </div>
            </div>
            <div class="flex-1 px-3">
              <div
                class="p-12 rounded-lg border border-solid border-gray-200 mb-8"
                style="box-shadow:0 10px 28px rgba(0,0,0,.08)"
              >
                <p class="font-semibold text-xl">Admin Page
                </p>
                <p class="mt-4">Manage your site efficiently with our comprehensive Admin Page. Designed for administrators, this feature provides robust tools and controls to oversee all aspects of the site. From user management to content moderation, the Admin Page empowers you with the ability to customize settings, monitor activities, and ensure the smooth operation of your platform. Keep your site organized and up-to-date with ease.
                </p>
                <div class="flex align-center justify-center pt-8">
                  <Button class="bg-popo hover:bg-neutral-700" as="a" href="/admin">Admin Page</Button>
                </div>
              </div>
            </div>
            <div class="flex-1 px-3">
              <div
                class="p-12 rounded-lg border border-solid border-gray-200 mb-8"
                style="box-shadow:0 10px 28px rgba(0,0,0,.08)"
              >
                <p class="font-semibold text-xl">Blog Page
                </p>
                <p class="mt-4">Share your stories, insights, and updates with the world through our engaging Blog Page. Whether you’re a seasoned writer or just starting, our Blog Page offers an intuitive platform to publish and manage your content. With a clean and customizable layout, you can create captivating posts, embed multimedia, and connect with your audience. Stay relevant and inspire your readers with our versatile blogging feature.
                </p>
                <div class="flex align-center justify-center pt-8">
                  <Button class="bg-popo hover:bg-neutral-700" as="a" href="/posts">Blog Page</Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
    """
  end

  def mount(_, _, socket) do
    Process.send_after(self(), :clear_flash, 2000)
    {:ok, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
