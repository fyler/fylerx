defmodule Fyler.UrlHelper do

  def file_name(url) do
    res = prepare_file(url)
    if is_map(res), do: res["filename"]
  end

  def file_ext(url) do
    res = prepare_file(url)
    if is_map(res), do: res["extension"]
  end

  defp prepare_file(url) do
    Regex.named_captures(~r/^(?<filename>\w+)\.(?<extension>\w+)/, List.last(String.split(url, "/")))
  end
end