defmodule Hub.Util do
  # Implementation based on: http://stackoverflow.com/a/31990445/175830
  def map_keys_to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  def map_keys_to_strings(map) do
    for {key, val} <- map, into: %{}, do: {Atom.to_string(key), val}
  end
end

# https://gist.githubusercontent.com/speeddragon/e836b64cff8a39f537078fa507a32e5b/raw/3b730edfef6b243bdfb4360091f1ad5bf68fa45b/image_validation.ex
defmodule ImageValidation do
  @doc """
  JPG magic bytes: 0xffd8
  """
  def is_jpg?(file) do
    with <<head::binary-size(2)>> <> _ = file.binary,
         <<255, 216>> <- head do
      true
    else
      _ -> false
    end
  end

  def is_jpg_by_filepath(file) do
    with {:ok, file_content} <- :file.open(file, [:read, :binary]),
         {:ok, <<255, 216>>} <- :file.read(file_content, 2) do
      true
    else
      _error ->
        false
    end
  end

  @doc """
  PNG magic bytes: 0x89504e470d0a1a0a
  """
  def is_png?(file) do
    with <<head::binary-size(8)>> <> _ = file.binary,
         <<137, 80, 78, 71, 13, 10, 26, 10>> <- head do
      true
    else
      _ -> false
    end
  end

  def is_png_by_filepath(file) do
    with {:ok, file_content} <- :file.open(file, [:read, :binary]),
         {:ok, <<137, 80, 78, 71, 13, 10, 26, 10>>} <- :file.read(file_content, 8) do
      true
    else
      _error ->
        false
    end
	end
end
