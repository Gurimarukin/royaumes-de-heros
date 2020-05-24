defmodule Heros.Utils do
  def keyfind(list, key, default \\ nil) do
    case List.keyfind(list, key, 0, default) do
      ^default -> nil
      {^key, elt} -> elt
    end
  end

  def keyreplace(list, key, value), do: List.keyreplace(list, key, 0, {key, value})

  def keyfullereplace(list, key, value) do
    case Enum.find_index(list, matches_key(key)) do
      nil -> list
      index -> List.replace_at(list, index, value)
    end
  end

  defp matches_key(key) do
    fn elt ->
      case elt do
        {^key, _} -> true
        _ -> false
      end
    end
  end

  def keyupdate(list, key, f, default \\ nil) do
    case keyfind(list, key) do
      ^default -> list
      previous -> keyreplace(list, key, {key, f.(previous)})
    end
  end

  def keydelete(list, key), do: List.keydelete(list, key, 0)

  def keymember?(list, key), do: List.keymember?(list, key, 0)
end
