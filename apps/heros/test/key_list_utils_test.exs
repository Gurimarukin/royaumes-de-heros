defmodule Heros.KeyListUtilsTest do
  use ExUnit.Case

  alias Heros.KeyListUtils

  test "fullreplace" do
    list = [{"a", 10}, {"b", 20}]
    assert KeyListUtils.fullreplace(list, "b", {"c", 30}) == [{"a", 10}, {"c", 30}]
    assert KeyListUtils.fullreplace(list, "c", {"d", 30}) == list
  end

  test "update" do
    list = [{"a", 10}, {"b", 20}]
    assert KeyListUtils.update(list, "b", &(&1 + 1)) == [{"a", 10}, {"b", 21}]
    assert KeyListUtils.update(list, "c", &(&1 + 1)) == list
  end

  test "member?" do
    list = [{"a", 10}, {"b", 20}]
    assert KeyListUtils.member?(list, "a")
    assert not KeyListUtils.member?(list, "c")
  end
end
