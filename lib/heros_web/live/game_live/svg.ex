defmodule HerosWeb.GameLive.Svg do
  import Phoenix.LiveView, only: [sigil_L: 2]

  def gold(assigns) do
    ~L"""
    <svg aria-hidden="true" focusable="false" data-prefix="fad" data-icon="coin" role="img"
         xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="svg-inline--fa fa-coin">
      <g class="fa-group">
        <path fill="currentColor" d="M0 208C0 128.44 114.67 64 256 64s256 64.44 256 144-114.67 144-256 144S0 287.56 0 208z" class="fa-secondary"></path>
        <path fill="currentColor" d="M0 320c0 27.77 18 53.37 48 74.33V330c-18.85-12-35.4-25.36-48-40.38zm80 92.51c27.09 12.89 59.66 22.81 96 28.8V377c-35.39-6-67.81-15.88-96-29zM464 330v64.32c30.05-21 48-46.56 48-74.33v-30.36C499.4 304.65 482.85 318 464 330zM336 441.31c36.34-6 68.91-15.91 96-28.8V348c-28.19 13.12-60.61 23-96 29zM208 381.2v64.09c15.62 1.51 31.49 2.71 48 2.71s32.38-1.2 48-2.71V381.2a477.2 477.2 0 0 1-48 2.8 477.2 477.2 0 0 1-48-2.8z" class="fa-primary"></path>
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
