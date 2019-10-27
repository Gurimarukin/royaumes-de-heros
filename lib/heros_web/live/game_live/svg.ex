defmodule HerosWeb.GameLive.Svg do
  import Phoenix.LiveView, only: [sigil_L: 2]

  def gold(assigns) do
    ~L"""
    <svg aria-hidden="true" focusable="false" data-prefix="fad" data-icon="coins" role="img"
         xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="svg-inline--fa fa-coins">
      <g class="fa-group">
        <path fill="currentColor" d="M416 311.4c57.3-11.1 96-31.7 96-55.4v-42.7c-23.2 16.4-57.3 27.6-96 34.5zm-4.7-95.1c60-10.8 100.7-32 100.7-56.3v-42.7c-35.5 25.1-96.5 38.6-160.7 41.8 29.5 14.3 51.2 33.5 60 57.2zM512 64c0-35.3-86-64-192-64S128 28.7 128 64s86 64 192 64 192-28.7 192-64z" class="fa-secondary"></path>
        <path fill="currentColor" d="M192 320c106 0 192-35.8 192-80s-86-80-192-80S0 195.8 0 240s86 80 192 80zM0 405.3V448c0 35.3 86 64 192 64s192-28.7 192-64v-42.7C342.7 434.4 267.2 448 192 448S41.3 434.4 0 405.3zm0-104.9V352c0 35.3 86 64 192 64s192-28.7 192-64v-51.6c-41.3 34-116.9 51.6-192 51.6S41.3 334.4 0 300.4z" class="fa-primary"></path>
      </g>
    </svg>
    """
  end

  def attack(assigns) do
    ~L"""
    <svg aria-hidden="true" focusable="false" data-prefix="fad" data-icon="swords" role="img"
         xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="svg-inline--fa fa-swords">
      <g class="fa-group">
        <path fill="currentColor" d="M153.37 278.63L100 332l-24.69-24.69a16 16 0 0 0-22.62 0l-17.54 17.53a16 16 0 0 0-2.79 18.87l31.64 59-59.31 59.35a16 16 0 0 0 0 22.63l22.62 22.62a16 16 0 0 0 22.63 0L109.25 448l59 31.64a16 16 0 0 0 18.87-2.79l17.53-17.54a16 16 0 0 0 0-22.62L180 412l53.37-53.37zM496.79.14l-78.11 13.2-140 140 80 80 140-140 13.2-78.11A13.33 13.33 0 0 0 496.79.14z" class="fa-secondary"></path>
        <path fill="currentColor" d="M389.37 309.38l-296-296L15.22.14A13.32 13.32 0 0 0 .14 15.22l13.2 78.11 296 296.05zm117.94 152.68L448 402.75l31.64-59a16 16 0 0 0-2.79-18.87l-17.54-17.53a16 16 0 0 0-22.63 0L307.31 436.69a16 16 0 0 0 0 22.62l17.53 17.54a16 16 0 0 0 18.87 2.79l59-31.64 59.31 59.31a16 16 0 0 0 22.63 0l22.62-22.62a16 16 0 0 0 .04-22.63z" class="fa-primary"></path>
      </g>
    </svg>
    """
  end
end
