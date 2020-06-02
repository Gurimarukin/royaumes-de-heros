defmodule Heros.Utils.KeyListTest do
  use ExUnit.Case

  alias Heros.Utils.KeyList

  test "fullreplace" do
    list = [{"a", 10}, {"b", 20}]
    assert KeyList.fullreplace(list, "b", {"c", 30}) == [{"a", 10}, {"c", 30}]
    assert KeyList.fullreplace(list, "c", {"d", 30}) == list
  end

  test "update" do
    list = [{"a", 10}, {"b", 20}]
    assert KeyList.update(list, "b", &(&1 + 1)) == [{"a", 10}, {"b", 21}]
    assert KeyList.update(list, "c", &(&1 + 1)) == list
  end

  test "member?" do
    list = [{"a", 10}, {"b", 20}]
    assert KeyList.member?(list, "a")
    assert not KeyList.member?(list, "c")
  end

  test "cycle" do
    list = [{"a", 1}, {"b", 2}, {"c", 3}, {"d", 4}]
    assert KeyList.cycle(list, "a") == {1, [{"b", 2}, {"c", 3}, {"d", 4}]}
    assert KeyList.cycle(list, "b") == {2, [{"c", 3}, {"d", 4}, {"a", 1}]}
    assert KeyList.cycle(list, "c") == {3, [{"d", 4}, {"a", 1}, {"b", 2}]}
    assert KeyList.cycle(list, "d") == {4, [{"a", 1}, {"b", 2}, {"c", 3}]}
    assert KeyList.cycle(list, "e") == {nil, list}
  end
end
