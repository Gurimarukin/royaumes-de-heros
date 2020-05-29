defmodule Heros.Option do
  def none, do: :error
  def some(a), do: {:ok, a}

  def from_nilable(nil), do: none()
  def from_nilable(a), do: some(a)

  def chain(opt, f) do
    case opt do
      {:ok, a} -> f.(a)
      :error -> :error
    end
  end

  def map(opt, f) do
    case opt do
      {:ok, a} -> {:ok, f.(a)}
      :error -> :error
    end
  end

  def filter(opt, pred) do
    case opt do
      {:ok, a} -> if pred.(a), do: opt, else: :error
      :error -> :error
    end
  end

  @spec alt({:ok, any} | :error, (() -> {:ok, any} | :error)) :: {:ok, any} | :error
  def alt(opt, lazy_other) do
    case opt do
      {:ok, _} -> opt
      :error -> lazy_other.()
    end
  end
end
