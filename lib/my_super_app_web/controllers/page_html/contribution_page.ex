defmodule MySuperAppWeb.ContributionPage do
  @moduledoc """
  Accordion
  """
  use MySuperAppWeb, :surface_live_view

  def render(assigns) do
    ~F"""
    <div class="container mx-auto mb-10 p-6 bg-white">
      <h1 class="text-3xl font-bold text-center mb-8 text-gray-800">Project Contributions</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h2 class="text-2xl font-semibold mb-4 text-gray-700">Max's Contributions</h2>
          <div class="overflow-x-auto">
            <table class="min-w-full bg-white">
              <thead class="bg-blue-800 text-white">
                <tr>
                  <th class="text-left py-3 px-4 uppercase font-semibold text-sm">Task</th>
                  <th class="text-left py-3 px-4 uppercase font-semibold text-sm">Details</th>
                </tr>
              </thead>
              <tbody class="text-gray-700">
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Context Development</td>
                  <td class="text-left py-3 px-4">Defined and implemented contexts for Blog and Tag functionalities.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">Database Schema</td>
                  <td class="text-left py-3 px-4">Designed and created schemas for `Tag` and `Post` models.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Database Migrations</td>
                  <td class="text-left py-3 px-4">Developed and executed migrations for schema updates and data structure.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">Query Optimization</td>
                  <td class="text-left py-3 px-4">Optimized queries and indexes for better database performance.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">API Development</td>
                  <td class="text-left py-3 px-4">Developed API for CRUD operations related to posts.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">API Testing</td>
                  <td class="text-left py-3 px-4">Developed and ran tests for verifying CRUD operations functionality.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Business Logic Testing</td>
                  <td class="text-left py-3 px-4">Created tests to validate business logic in Blog and Tag contexts.</td>
                </tr>

                <tr>
                  <td class="text-left py-3 px-4 font-medium">Search Functionality</td>
                  <td class="text-left py-3 px-4">Developed search functionality and synchronized with dropdowns.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Search System Development</td>
                  <td class="text-left py-3 px-4">Implemented search functionality for posts and tags.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div>
          <h2 class="text-2xl font-semibold mb-4 text-gray-700">Kris's Contributions</h2>
          <div class="overflow-x-auto">
            <table class="min-w-full bg-white">
              <thead class="bg-green-800 text-white">
                <tr>
                  <th class="text-left py-3 px-4 uppercase font-semibold text-sm">Task</th>
                  <th class="text-left py-3 px-4 uppercase font-semibold text-sm">Details</th>
                </tr>
              </thead>
              <tbody class="text-gray-700">
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Chat Feature</td>
                  <td class="text-left py-3 px-4">Created a chat system for private communication.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">Admin Blog Page</td>
                  <td class="text-left py-3 px-4">Developed a blog page for admin management.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">User Blog Page</td>
                  <td class="text-left py-3 px-4">Built a blog page where users can create posts with desired tags and view posts created by others.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">Frontend Testing</td>
                  <td class="text-left py-3 px-4">Tested pagination, search, modals, dropdowns, drawers, creating/deleting/updating info from db, flash messages, redirects, buttons etc.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Error Pages</td>
                  <td class="text-left py-3 px-4">Designed and created 404/503 error pages.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">Site Design</td>
                  <td class="text-left py-3 px-4">Renewed the site design.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Permission Management</td>
                  <td class="text-left py-3 px-4">Refined permission settings for roles and operators.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">User Page Enhancements</td>
                  <td class="text-left py-3 px-4">Added dropdowns for operator and role selection.</td>
                </tr>
                <tr class="bg-gray-100">
                  <td class="text-left py-3 px-4 font-medium">Routing & Plugs</td>
                  <td class="text-left py-3 px-4">Rewrote the route page and refined the plugs for better code organization and efficiency.</td>
                </tr>
                <tr>
                  <td class="text-left py-3 px-4 font-medium">Contribution page</td>
                  <td class="text-left py-3 px-4">Created this contribution page😁</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div>
          <h2 class="text-2xl font-semibold mb-4 text-gray-700">Ossas's Contribution</h2>
          <div class="overflow-x-auto">
            <table class="min-w-full bg-white">
              <thead class="bg-green-800 text-white">
                <tr>
                  <th class="text-left py-3 px-4 uppercase font-semibold text-sm">Task</th>
                  <th class="text-left py-3 px-4 uppercase font-semibold text-sm">Details</th>
                </tr>
              </thead>
              <tbody class="text-gray-700">
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
