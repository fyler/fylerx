defmodule Fyler.TasksView do
  use Fyler.Web, :view

  import Fyler.JsonView

  @attributes ~w(id worker_id upload_time process_time total_time status category type download_time data project_id queue_time source result)a
  
  def render("index.json", page) do
    %{ 
      tasks: (for item <- page.entries, do: item |> Map.take(@attributes)),
      pagination: %{
        page_number: page.page_number,
        page_size: page.page_size,
        total_entries: page.total_entries,
        total_pages: page.total_pages
      }
    }
  end
end
