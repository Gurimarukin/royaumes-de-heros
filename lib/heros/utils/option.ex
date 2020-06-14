defmodule Heros.Utils.Option do
  def none, do: :error
  def some(a), do: {:ok, a}

  def from_nilable(nil), do: none()
  def from_nilable(a), do: some(a)

  def to_nilable({:ok, a}), do: a
  def to_nilable(:error), do: nil

  def get_or_else({:ok, a}, _default), do: a
  def get_or_else(:error, default), do: default

  def chain({:ok, a}, f), do: f.(a)
  def chain(:error, _f), do: :error

  def map({:ok, a}, f), do: {:ok, f.(a)}
  def map(:error, _f), do: :error

  def filter({:ok, a}, pred), do: if(pred.(a), do: {:ok, a}, else: :error)
  def filter(:error, _pred), do: :error

  @spec alt({:ok, any} | :error, (() -> {:ok, any} | :error)) :: {:ok, any} | :error
  def alt({:ok, a}, _lazy_other), do: {:ok, a}
  def alt(:error, lazy_other), do: lazy_other.()
end
