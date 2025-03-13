alias MySuperApp.{Repo, Phone, Room, Accounts, CasinosAdmins, Blog}
alias Faker.{Internet, Superhero}

create_some_regular_users = fn ->
  for _n <- 1..10 do
    Accounts.register_user(%{
      username: Superhero.name(),
      email: Internet.safe_email(),
      password: "123456789"
    })
  end
end

give_user_admin_role = fn ->
  {:ok, user} =
    Accounts.register_user(%{
      username: "Super_Admin",
      email: "superadmin@gmail.com",
      password: "123456789"
    })

  {:ok, _role} = CasinosAdmins.create_role(%{name: "super_admin"})
  Repo.update(Ecto.Changeset.change(user, role_id: 1))
end

create_some_operators = fn ->
  {:ok, casino} = CasinosAdmins.create_operator(%{name: "casino_operator"})
  {:ok, slots} = CasinosAdmins.create_operator(%{name: "slots_operator"})
  {:ok, bet} = CasinosAdmins.create_operator(%{name: "bet_operator"})
  {:ok, game} = CasinosAdmins.create_operator(%{name: "game_operator"})

  {:ok, user_game} =
    Accounts.register_user(%{
      username: "game_operator",
      email: "gameoperator@gmail.com",
      password: "123456789"
    })

  {:ok, user_bet} =
    Accounts.register_user(%{
      username: "bet_operator",
      email: "betoperator@gmail.com",
      password: "123456789"
    })

  {:ok, user_slots} =
    Accounts.register_user(%{
      username: "slots_operator",
      email: "slotsoperator@gmail.com",
      password: "123456789"
    })

  {:ok, user_casino} =
    Accounts.register_user(%{
      username: "casino_operator",
      email: "casinooperator@gmail.com",
      password: "123456789"
    })

  Repo.update(Ecto.Changeset.change(user_casino, operator_id: casino.id))
  Repo.update(Ecto.Changeset.change(user_slots, operator_id: slots.id))
  Repo.update(Ecto.Changeset.change(user_bet, operator_id: bet.id))
  Repo.update(Ecto.Changeset.change(user_game, operator_id: game.id))
end

create_sites = fn ->
  {:ok, live_casino} =
    CasinosAdmins.create_site(%{name: "Live Casino", key: "lcs", value: 325, status: "ACTIVE"})

  {:ok, sports_bet} =
    CasinosAdmins.create_site(%{
      name: "Sports Betting",
      key: "spb",
      value: 589,
      status: "ACTIVE"
    })

  {:ok, casino_br} =
    CasinosAdmins.create_site(%{name: "Casino BR", key: "cbr", value: 12, status: "ACTIVE"})

  {:ok, casino_ua} =
    CasinosAdmins.create_site(%{name: "Casino UA", key: "cua", value: 222, status: "ACTIVE"})

  {:ok, casino_usa} =
    CasinosAdmins.create_site(%{name: "Casino USA", key: "cus", value: 244, status: "ACTIVE"})

  Repo.update(Ecto.Changeset.change(live_casino, operator_id: 1))
  Repo.update(Ecto.Changeset.change(sports_bet, operator_id: 2))
  Repo.update(Ecto.Changeset.change(casino_br, operator_id: 4))
  Repo.update(Ecto.Changeset.change(casino_ua, operator_id: 3))
  Repo.update(Ecto.Changeset.change(casino_usa, operator_id: 1))
end

create_pages = fn ->
  {:ok, live_casino} =
    CasinosAdmins.create_site(%{name: "Live Casino", key: "lcs", value: 325, status: "ACTIVE"})

  {:ok, sports_bet} =
    CasinosAdmins.create_site(%{
      name: "Sports Betting",
      key: "spb",
      value: 589,
      status: "ACTIVE"
    })

  {:ok, casino_br} =
    CasinosAdmins.create_site(%{name: "Casino BR", key: "cbr", value: 12, status: "ACTIVE"})

  {:ok, casino_ua} =
    CasinosAdmins.create_site(%{name: "Casino UA", key: "cua", value: 222, status: "ACTIVE"})

  {:ok, casino_usa} =
    CasinosAdmins.create_site(%{name: "Casino USA", key: "cus", value: 244, status: "ACTIVE"})

  Repo.update(Ecto.Changeset.change(live_casino, operator_id: 1))
  Repo.update(Ecto.Changeset.change(sports_bet, operator_id: 2))
  Repo.update(Ecto.Changeset.change(casino_br, operator_id: 2))
  Repo.update(Ecto.Changeset.change(casino_ua, operator_id: 3))
  Repo.update(Ecto.Changeset.change(casino_usa, operator_id: 1))
end

create_pages = fn ->
  MySuperApp.CasinosAdmins.create_page(%{name: "Withdraw", site_id: 2})
  MySuperApp.CasinosAdmins.create_page(%{name: "Deposit", site_id: 1})
  MySuperApp.CasinosAdmins.create_page(%{name: "Personal Account", site_id: 3})
  MySuperApp.CasinosAdmins.create_page(%{name: "Slots", site_id: 4})
  MySuperApp.CasinosAdmins.create_page(%{name: "Wallet", site_id: 5})
  MySuperApp.CasinosAdmins.create_page(%{name: "Policy", site_id: 1})
  MySuperApp.CasinosAdmins.create_page(%{name: "Support", site_id: 3})
  MySuperApp.CasinosAdmins.create_page(%{name: "Friends", site_id: 5})
end

create_some_roles = fn ->
  {:ok, role1} = CasinosAdmins.create_role(%{name: "just_admin"})
  Repo.update(Ecto.Changeset.change(role1, operator_id: 1))
  {:ok, role2} = CasinosAdmins.create_role(%{name: "casino_admin"})
  Repo.update(Ecto.Changeset.change(role2, operator_id: 2))
  {:ok, role3} = CasinosAdmins.create_role(%{name: "bet_admin"})
  Repo.update(Ecto.Changeset.change(role3, operator_id: 3))
  {:ok, role4} = CasinosAdmins.create_role(%{name: "deposit_admin"})
  Repo.update(Ecto.Changeset.change(role4, operator_id: 2))
  {:ok, role5} = CasinosAdmins.create_role(%{name: "cards_admin"})
  Repo.update(Ecto.Changeset.change(role5, operator_id: 1))
end

give_user_admin_role.()
create_some_operators.()
create_some_regular_users.()
create_sites.()
create_pages.()
create_some_roles.()

create_tags = fn ->
  Blog.create_tag(%{name: "Betting"})
  Blog.create_tag(%{name: "Sport"})
  Blog.create_tag(%{name: "Casino"})
  Blog.create_tag(%{name: "Slots"})
  Blog.create_tag(%{name: "Gambling"})
  Blog.create_tag(%{name: "Poker"})
  Blog.create_tag(%{name: "CasinoStrategies"})
  Blog.create_tag(%{name: "Cards"})
  Blog.create_tag(%{name: "Roulette"})
end

create_tags.()

create_posts = fn ->
  Blog.create_post(%{
    "title" => "Getting Started with Online Casinos",
    "body" =>
      "Casinos are vibrant venues offering a range of gambling games, from slot machines to poker tables. Successful casino strategies involve more than just luck; they require skillful planning and understanding of the games. One key strategy is managing your bankroll effectively, ensuring you don’t wager more than you can afford to lose. Another important approach is learning the rules and odds of various games, such as blackjack or roulette, to make informed decisions. Many players also employ betting systems, like the Martingale method, to manage risk. Ultimately, while strategies can improve your odds, casino games are designed to favor the house, making responsible play crucial.",
    "user_id" => 7,
    "post_tags" => ["Casino", "CasinoStrategies", "Gambling"]
  })

  Blog.create_post(%{
    "title" => "Top Strategies for Sports Betting",
    "body" =>
      "There are various strategies for sports betting that can help increase your chances of winning.",
    "user_id" => 5,
    "post_tags" => ["Betting", "Sport"]
  })

  Blog.create_post(%{
    "title" => "Mastering Card Games: Key Strategies for Success",
    "body" =>
      "Card games combine skill, strategy, and chance to offer a dynamic and engaging experience. In games like poker, players use strategies such as bluffing, reading opponents, and bankroll management to gain an edge. Counting cards in games like blackjack can shift the odds in favor of the player, though it's often discouraged in casinos. Understanding odds and probabilities is essential for making informed decisions. Positioning and timing also play a crucial role; in games like Texas Hold'em, knowing when to fold or raise can significantly impact outcomes. Mastery of card games involves continuous practice and adaptation to opponents' strategies.",
    "user_id" => 8,
    "post_tags" => ["Cards"]
  })

  Blog.create_post(%{
    "title" => "Poker: Strategies for Winning Big Jackpot",
    "body" =>
      "Poker is a game of skill, strategy, and psychological acumen. To excel, players must understand the nuances of hand rankings, betting patterns, and positional play. One crucial strategy is to play tight-aggressive, focusing on strong hands and betting confidently. Bluffing can also be effective, but it requires a keen sense of timing and opponent behavior. Reading your opponents and adjusting your strategy based on their tendencies is key. Additionally, managing your bankroll wisely ensures longevity in the game. By combining these strategies with practice and discipline, players can significantly increase their chances of success at the poker table.",
    "user_id" => 4,
    "post_tags" => ["Poker"]
  })

  Blog.create_post(%{
    "title" => "Responsible Gambling: Tips and Advice",
    "body" =>
      "Gambling responsibly is key to avoiding problems with gambling and maintaining your finances.",
    "user_id" => 6,
    "post_tags" => ["Gambling"]
  })

  Blog.create_post(%{
    "title" => "Maximizing Your Winnings: Essential Tips for Casino Slots",
    "body" =>
      "Casino slots offer an exciting and dynamic gambling experience with numerous themes and potential jackpots. To enhance your gameplay, consider these strategies: Understand paylines, as they determine your winning combinations. Set a strict budget to avoid overspending and stick to it. Opt for slots with a high Return to Player (RTP) percentage, which can improve your odds of winning. Make the most of casino promotions and bonuses to extend your playtime and maximize your chances. Remember, slots are games of chance, so gamble responsibly and enjoy the thrill of the game while managing your expectations.",
    "user_id" => 6,
    "post_tags" => ["Gambling", "Casino", "Poker", "Betting", "CasinoStrategies"]
  })

  Blog.create_post(%{
    "title" => "The History of Casinos",
    "body" =>
      "Casinos have a rich history, starting from the first gambling houses to the modern online platforms.",
    "user_id" => 9,
    "post_tags" => ["Casino"]
  })

  Blog.create_post(%{
    "title" => "Mastering the Spin: A Guide to Roulette Strategies",
    "body" =>
      "Roulette, one of the most iconic casino games, combines simplicity with excitement. The game features a spinning wheel with numbered slots and a ball that determines the winning number. Players place bets on various outcomes, such as single numbers, colors, or ranges of numbers. To increase your chances of winning.",
    "user_id" => 9,
    "post_tags" => ["Roulette"]
  })
end

create_posts.()

create_room = fn ->
  MySuperApp.Accounts.ChatRooms.create_chatroom(%{
    name: "Communicate room",
    description: "Regular room",
    user_id: 1
  })
end

create_room.()

join_room = fn ->
  room = Repo.get(MySuperApp.ChatRoom, 1)

  users = Repo.all(MySuperApp.User)

  for user <- users do
    MySuperApp.Accounts.ChatRooms.join(user, room)
  end
end

join_room.()

Repo.insert_all(
  "left_menu",
  [
    %{id: 1, title: "Vision"},
    %{id: 2, title: "Getting started"},
    %{id: 3, title: "How to contribute?"},
    %{id: 4, title: "Colours"},
    %{id: 5, title: "Tokens"},
    %{id: 6, title: "Transform SVG"},
    %{id: 7, title: "Manifest"},
    %{id: 8, title: "Tailwind"}
  ]
)

Repo.insert_all(
  "right_menu",
  [
    %{id: 1, title: "Vision"},
    %{id: 2, title: "Getting started"},
    %{id: 3, title: "How to contribute?"},
    %{id: 4, title: "Colours"},
    %{id: 5, title: "Tokens"},
    %{id: 6, title: "Transform SVG"},
    %{id: 7, title: "Manifest"},
    %{id: 8, title: "Tailwind"}
  ]
)

rooms_with_phones = %{
  "301" => ["0991122301", "0993344301"],
  "302" => ["0990000302", "0991111302"],
  "303" => ["0992222303"],
  "304" => ["0993333304", "0994444304"],
  "305" => ["0935555305", "09306666305", "0937777305"]
}

Repo.transaction(fn ->
  rooms_with_phones
  |> Enum.each(fn {room, phones} ->
    %Room{}
    |> Room.changeset(%{room_number: room})
    |> Ecto.Changeset.put_assoc(
      :phones,
      phones
      |> Enum.map(
        &(%Phone{}
          |> Phone.changeset(%{phone_number: &1}))
      )
    )
    |> Repo.insert!()
  end)

  MySuperApp.Repo.insert_all(
    Room,
    [
      %{room_number: 666},
      %{room_number: 1408},
      %{room_number: 237}
    ]
  )

  MySuperApp.Repo.insert_all(
    Phone,
    [
      %{phone_number: "380661112233"},
      %{phone_number: "380669997788"},
      %{phone_number: "380665554466"}
    ]
  )
end)
