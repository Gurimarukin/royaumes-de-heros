defmodule Heros.Utils.KeyList do
  # find(list({A, B}), A, C) :: C | B
  def find(list, key, default \\ nil) do
    case List.keyfind(list, key, 0, default) do
      ^default -> default
      {^key, elt} -> elt
    end
  end

  # find_where(list({A, B}), (B -> boolean), C) :: C | A
  def find_where(list, f, default \\ nil) do
    case Enum.find(list, default, fn {_, b} -> f.(b) end) do
      ^default -> default
      {key, _} -> key
    end
  end

  # find(list({A, B}), A, B) :: list({A, B})
  def replace(list, key, value), do: List.keyreplace(list, key, 0, {key, value})

  # fullreplace(list({A, B}), A, {A, B}) :: list({A, B})
  def fullreplace(list, key, value) do
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

  # update(list({A, B}), A, B -> B) :: list({A, B})
  def update(list, key, f) do
    case find(list, key) do
      nil -> list
      previous -> replace(list, key, f.(previous))
    end
  end

  # map(list({A, B}), B -> C) :: list({A, C})
  def map(list, f) do
    Enum.map(list, fn {key, val} -> {key, f.(val)} end)
  end

  # delete(list({A, B}), A) :: list({A, B})
  def delete(list, key), do: List.keydelete(list, key, 0)

  # delete(list({A, B}), A) :: boolean
  def member?(list, key), do: List.keymember?(list, key, 0)

  # delete(list({A, B}), (B -> boolean)) :: number
  def count(list, pred), do: Enum.count(list, fn {_, val} -> pred.(val) end)

  def cycle(list, key) do
    {left, right} = Enum.split_while(list, fn {k, _} -> k != key end)

    case right do
      [] -> {nil, left}
      [{_, elt} | right] -> {elt, right ++ left}
    end
  end
end
