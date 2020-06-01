defmodule HerosWeb.Session do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user =
      get_session(conn, :user) ||
        %{
          id: UUID.uuid1(:hex),
          name: random_name()
        }

    conn
    |> assign(:user, user)
    |> put_session(:user, user)
  end

  defp random_name do
    champion =
      Enum.random([
        "Arkus",
        "Borg",
        "Broelyn",
        "Cristov",
        "Cron",
        "Darian",
        "Grak",
        "Kraka",
        "Krythos",
        "Lys",
        "Myros",
        "Parov",
        "Rake",
        "Rasmus",
        "Rayla",
        "Torgen",
        "Tyrannor",
        "Varrick",
        "Weyan"
      ])

    n =
      Enum.random([
        "I",
        "II",
        "III",
        "IV",
        "V",
        "VI",
        "VII",
        "VIII",
        "IX",
        "X"
      ])

    ~s"#{champion} #{n}"
  end
end
