require "securerandom"
require "json"

# =========================
# CONSTANTS
# =========================

ECHO_ARCANA = [:solar, :chthonic, :feral, :unformed, :divine]

BASE_SPEED = {
  player:          10,
  companion_scout: 13,
  companion_bard:   9,
  companion_seer:  10,
  generic_enemy:    9,
  titan_fragment:   7,
  spirit:          12,
  boss:            11
}

FRACTURE_EVENTS = [
  "A column cracks down the middle. Light pours through the gap like blood.",
  "The sky stutters. For a moment there are two suns.",
  "A temple wall writes itself in stone, then erases the words.",
  "You hear a god being born somewhere nearby. It sounds like grief.",
  "The ground hums a note that has no name yet.",
  "Your shadow appears for the first time. Then disappears again.",
  "Marble bleeds. The stone does not seem to notice.",
  "A bird flies through the air and leaves a crack where it passed.",
  "Something beneath the earth exhales and the grass forgets to grow back.",
  "The sun moves slightly. Then corrects itself. Then moves again."
]

SURFACE_ROOM_NAMES = [
  "Sun-Bleached Path",      "Temple of the Unfinished",  "The Agora That Hums",
  "Marble Courtyard",       "Olive Grove at the Edge",   "The Trembling Stoa",
  "Altar Without a God",    "The Bright Collapse",       "Forum of Half-Words",
  "Cracked Amphitheatre",   "The Over-lit Hill",         "Road to Nowhere Yet"
]

SURFACE_ROOM_DESCS = [
  "White stone everywhere. Too bright. Your eyes ache.",
  "Columns that hum at a frequency just below hearing.",
  "The air smells of olive oil and something older.",
  "Unfinished statues line the path. Their faces keep changing.",
  "Grass grows between the cracks and then un-grows.",
  "A market where things are sold that haven't been invented yet.",
  "The temple roof is open. Not broken — just unfinished.",
  "Sunlight presses down like a hand.",
  "Everything here casts the wrong shadow, or no shadow at all.",
  "The road is warm underfoot. The warmth doesn't come from the sun."
]

SURFACE_LORE = [
  "This world is being written while you walk through it.",
  "The gods haven't decided what this place is for yet.",
  "You find a word carved in stone that has no meaning. Yet.",
  "Something about this path feels like a first draft.",
  "The marble remembers being mountain. It isn't sure it approves of the change.",
  "A child draws a picture of a dog on the wall. The dog looks back.",
  "This temple was built before its god was invented. It's waiting.",
  "The sun here isn't hot. It's loud.",
  "You hear your own name spoken ahead of you. No one is there."
]

DESCENT_ROOM_NAMES = [
  "The First Crack",         "Threshold Cave",          "Where the Light Ends",
  "The Breathing Cavern",    "Stone Throat",            "The Drop That Isn't Ready",
  "Half-Dark Passage",       "The World's Underside",   "Fault Line Gallery",
  "The Almost-Dark"
]

DESCENT_ROOM_DESCS = [
  "The light thins here. It looks offended.",
  "The cave walls are warm and damp. They breathe.",
  "Cold air rises from below. The world wasn't supposed to have cold yet.",
  "The stone hums a different note than the surface.",
  "The passage narrows. The dark presses in from both sides.",
  "Roots reach through the ceiling. They look like fingers.",
  "The floor slopes downward at a wrong angle.",
  "You can still see light from above. It looks very far away.",
  "Something drips from the ceiling with mathematical regularity.",
  "The cave smells like the inside of a word that was never spoken."
]

DESCENT_LORE = [
  "The underworld isn't finished. You can feel it being assembled below you.",
  "This crack in the earth wasn't here yesterday. The world made it for you.",
  "You find a spirit trying to become solid. It isn't there yet.",
  "The stone here remembers being softer.",
  "Something beneath you is practicing having a shape.",
  "The dark isn't natural. It's a draft of dark, still being revised."
]

UNDERWORLD_ROOM_NAMES = [
  "The Unfinished Shore",    "River Without a Name",    "Plain of Not-Yet",
  "The Flickering Fields",   "Where Spirits Stutter",   "Hall of Incomplete Forms",
  "The Murmuring Void",      "Draft of Elysium",        "Tartarus Sketch",
  "The First Forgotten Place"
]

UNDERWORLD_ROOM_DESCS = [
  "Spirits drift through the air like half-remembered sentences.",
  "A river runs with something that isn't water yet.",
  "The ground here is soft as if the world hasn't decided what it is.",
  "Forms flicker — half-human, half-animal, half-nothing.",
  "The dark is complete here. Not frightening. Just final.",
  "Something vast breathes in the distance.",
  "The air has weight. Old weight. Weight that predates stone.",
  "Shapes assemble and disassemble. None of them are finished.",
  "There are doors here with no walls around them.",
  "The silence here is the loudest thing you've ever heard."
]

UNDERWORLD_LORE = [
  "The dead here don't know they're dead. The concept hasn't arrived yet.",
  "You find an echo of something that will become a myth in three thousand years.",
  "The underworld is practicing its geography.",
  "Something here has been waiting longer than the surface world has existed.",
  "You feel the Fang hum. It recognizes this place.",
  "This is where stories go when they don't survive being told."
]

COMPANION_LINES = {
  scout: [
    "The path ahead is wrong. I mean that literally.",
    "I've tracked animals across three continents. Nothing moves like these things.",
    "My nose says go back. My legs disagree.",
    "The Fang is glowing again. I'm choosing not to ask."
  ],
  bard: [
    "I'm supposed to be writing this down. My stylus keeps melting.",
    "This will make an excellent song. Assuming anyone survives to hear it.",
    "The gods won't like what you're doing. I know this because I've met them. Briefly.",
    "Every story needs a descent. I didn't expect to be in mine."
  ],
  seer: [
    "I saw this. I didn't tell you because you wouldn't have come.",
    "The cracks are getting wider. The world is losing its argument with itself.",
    "Hades isn't finished yet. That makes him more dangerous, not less.",
    "When this is over, no one will remember it happened. That's the point."
  ]
}

HADES_CHAMBER_LORE = [
  "The walls here are not marble. They are compressed myth.",
  "Hades looks at you with eyes that are still deciding what colour to be.",
  "The Fang vibrates so hard it leaves marks in the air.",
  "This is the deepest point in a world that wasn't ready for depth.",
  "You feel the full weight of being the first creature to come this far.",
  "The concept of 'death' hovers in the room, waiting to be invented."
]

ENEMY_POOL = [
  { name: "Unfinished Spirit",    hp: [12,20], atk: [4,7],  def: [1,3], spd: 12, tags: [:spirit, :unformed] },
  { name: "Flickering Titan Shard", hp: [20,30], atk: [7,10], def: [3,5], spd: 7,  tags: [:titan, :unformed] },
  { name: "Half-Written Gorgon",  hp: [18,26], atk: [6,9],  def: [2,4], spd: 10, tags: [:myth, :stone] },
  { name: "Draft of Cerberus",    hp: [22,30], atk: [8,11], def: [4,6], spd: 9,  tags: [:chthonic, :beast] },
  { name: "Marble Revenant",      hp: [16,24], atk: [5,8],  def: [3,5], spd: 8,  tags: [:stone, :surface] },
  { name: "Nameless God-Shard",   hp: [24,34], atk: [9,13], def: [5,7], spd: 9,  tags: [:divine, :unformed] },
  { name: "Echo of the Not-Yet",  hp: [14,22], atk: [5,8],  def: [2,4], spd: 11, tags: [:spirit, :chthonic] },
  { name: "Myth-Fragment Beast",  hp: [20,28], atk: [7,10], def: [3,5], spd: 10, tags: [:myth, :beast] }
]

# =========================
# STRUCTS
# =========================

class Room
  attr_accessor :id, :name, :desc, :lore, :exits,
                :enemy_group, :npc, :visited,
                :shelves, :flags, :zone

  def initialize(name, desc, lore: nil, id: nil, zone: :surface)
    @id          = id || SecureRandom.uuid
    @name        = name
    @desc        = desc
    @lore        = lore
    @exits       = {}
    @enemy_group = []
    @npc         = nil
    @visited     = false
    @shelves     = []
    @flags       = {}
    @zone        = zone
  end
end

class Enemy
  attr_accessor :name, :hp, :max_hp, :atk, :defense, :speed, :desc, :tags

  def initialize(name:, hp:, atk:, defense:, speed:, desc:, tags: [])
    @name    = name
    @hp      = hp
    @max_hp  = hp
    @atk     = atk
    @defense = defense
    @speed   = speed
    @desc    = desc
    @tags    = tags
  end

  def alive?
    @hp > 0
  end
end

class PartyMember
  attr_accessor :id, :name, :role, :hp, :max_hp,
                :atk, :defense, :speed, :skills,
                :status_effects, :limit_ready,
                :limit_name, :limit_desc,
                :joined_at_zone

  def initialize(id:, name:, role:, hp:, atk:, defense:, speed:,
                 skills:, limit_name:, limit_desc:, joined_at_zone: :surface)
    @id             = id
    @name           = name
    @role           = role
    @hp             = hp
    @max_hp         = hp
    @atk            = atk
    @defense        = defense
    @speed          = speed
    @skills         = skills
    @status_effects = {}
    @limit_ready    = false
    @limit_name     = limit_name
    @limit_desc     = limit_desc
    @joined_at_zone = joined_at_zone
  end

  def alive?
    @hp > 0
  end
end

class Echo
  attr_accessor :name, :arcana, :level, :xp,
                :stats, :skills, :passives, :lore_line

  def initialize(name:, arcana:, stats:, skills:, passives:, lore_line: "")
    @name      = name
    @arcana    = arcana
    @level     = 1
    @xp        = 0
    @stats     = stats
    @skills    = skills
    @passives  = passives
    @lore_line = lore_line
  end
end

class Player
  attr_accessor :name, :room,
                :hp, :max_hp, :atk, :defense, :speed,
                :iron_slivers, :dispellers,
                :inventory, :status_effects,
                :party, :fracture,
                :has_fang, :fang_level,
                :command_count, :depth, :zone,
                :echoes, :equipped_echo,
                :echo_fragments,
                :kills

  def initialize(name)
    @name    = name
    @room    = nil

    @max_hp  = 45
    @hp      = @max_hp
    @atk     = 9
    @defense = 4
    @speed   = BASE_SPEED[:player]

    @iron_slivers = 80
    @dispellers   = 5
    @inventory    = { bandage: 3 }
    @status_effects = {}
    @party        = []

    @fracture     = 0   # replaces dread — world breakdown counter 0-100
    @has_fang     = true
    @fang_level   = 1   # Fang grows as you go deeper

    @command_count = 0
    @depth         = 0
    @zone          = :surface

    @echoes         = {}
    @equipped_echo  = nil
    @echo_fragments = 0
    @kills          = 0
  end

  def alive?
    @hp > 0
  end
end

class NPC
  attr_accessor :name, :lines

  def initialize(name, lines)
    @name  = name
    @lines = lines
  end

  def speak
    @lines.sample
  end
end

# =========================
# GAME
# =========================

class Game
  def initialize
    @rooms   = {}
    @player  = nil
    @running = true

    @depth          = 0
    @hades_room     = nil
    @hades_defeated = false

    @difficulty      = :normal
    @encounter_rate  = 0.65
    @damage_mult     = 1.0

    @companions_met  = { scout: false, bard: false, seer: false }
  end

  def run
    content_warning
    title_screen
  end

  # =========================
  # UTIL
  # =========================

  def clear
    system("clear") || system("cls")
  end

  def opposite_dir(dir)
    { "north" => "south", "south" => "north", "east" => "west", "west" => "east" }[dir]
  end

  # =========================
  # CONTENT WARNING
  # =========================

  def content_warning
    clear
    puts "=" * 60
    puts "  CONTENT WARNING"
    puts "=" * 60
    puts ""
    puts "  Dark Floof III contains themes that some players"
    puts "  may find distressing, including:"
    puts ""
    puts "   - Violence, death, and the invention of mortality"
    puts "   - Nihilism and the dissolution of the self"
    puts "   - A world coming apart at its foundations"
    puts "   - Cosmic horror and existential dread"
    puts "   - A protagonist who does not survive"
    puts ""
    puts "  This game is a tragedy. That is intentional."
    puts ""
    puts "  If you are in a difficult place right now, please"
    puts "  consider reaching out to someone who can help."
    puts "  You don't have to carry this alone."
    puts ""
    puts "  Crisis line (US): 988 Suicide & Crisis Lifeline"
    puts "  Text: HOME to 741741 (Crisis Text Line)"
    puts "  International: findahelpline.com"
    puts ""
    puts "=" * 60
    puts ""
    puts "  Press Enter to continue, or type QUIT to exit."
    print "  > "
    ans = gets&.strip&.downcase
    if ans == "quit"
      puts "\n  Take care of yourself. The world will wait."
      exit
    end
  end

  # =========================
  # TITLE SCREEN
  # =========================

  def title_screen
    clear
    puts <<~ART

    ██████╗ ███████╗    ██████╗
    ██╔══██╗██╔════╝    ╚════██╗
    ██║  ██║█████╗       █████╔╝
    ██║  ██║██╔══╝      ██╔═══╝
    ██████╔╝██║         ███████╗
    ╚═════╝ ╚═╝         ╚══════╝

    D A R K   F L O O F   I I I
    THE PLACE THAT DIDN'T TAKE

    ART

    puts "Before the Library. Before the Hospital."
    puts "Before endings existed."
    puts "A husky picks up a weapon that shouldn't exist yet.\n\n"

    puts "1. Begin"
    puts "2. About"
    puts "3. Load"
    puts "4. Difficulty"
    puts "5. Quit"
    print "> "

    case gets&.strip
    when "1" then start_new_game
    when "2" then show_about; title_screen
    when "3" then load_game
    when "4" then choose_difficulty; title_screen
    else @running = false
    end
  end

  def show_about
    clear
    puts "Long before the Infinite Library was built,"
    puts "long before the Hospital ever breathed,"
    puts "the world was a draft."
    puts ""
    puts "Gods half-formed. Marble still warm from being mountain."
    puts "A sky that never dimmed because night hadn't been invented."
    puts ""
    puts "One husky found the first Fang."
    puts "He probably shouldn't have."
    puts ""
    puts "This is what happened next."
    puts "\n(Press Enter.)"
    gets
  end

  def choose_difficulty
    clear
    puts "Choose difficulty:"
    puts "1. Gentle  — fewer enemies, slower fracture"
    puts "2. Normal"
    puts "3. Cruel   — more enemies, faster fracture, harder hits"
    print "> "

    case gets&.strip
    when "1"
      @difficulty     = :gentle
      @encounter_rate = 0.40
      @damage_mult    = 0.8
    when "3"
      @difficulty     = :cruel
      @encounter_rate = 0.85
      @damage_mult    = 1.25
    else
      @difficulty     = :normal
      @encounter_rate = 0.65
      @damage_mult    = 1.0
    end

    puts "Difficulty: #{@difficulty.to_s.capitalize}. (Press Enter.)"
    gets
  end

  # =========================
  # NEW GAME
  # =========================

  def start_new_game
    clear
    puts "The sun is too loud."
    puts "The marble is too bright."
    puts "Something beneath the earth is breathing.\n\n"
    puts "What is this husky called?"
    print "> "
    name = gets&.strip
    name = "The First" if name.nil? || name.empty?

    @player = Player.new(name)
    seed_initial_echoes
    build_starting_area
    main_loop
  end

  # =========================
  # ECHOES — DF3's version of Soul-Masks
  # =========================

  def seed_initial_echoes
    starter = Echo.new(
      name:      "Fang-Bearer's Echo",
      arcana:    :solar,
      stats:     { hp: 0, atk: 0, def: 0, spd: 0 },
      skills:    [],
      passives:  [],
      lore_line: "The first echo. It formed when you picked up the Fang."
    )
    @player.echoes[starter.name] = starter
    @player.equipped_echo        = starter
  end

  def echo_templates
    [
      Echo.new(
        name:      "Sun-Blinded Warrior",
        arcana:    :solar,
        stats:     { hp: 8, atk: 4, def: 2, spd: 1 },
        skills:    [:echo_solar_strike, :echo_blinding_rush],
        passives:  [:echo_fang_resonance],
        lore_line: "Formed from the memory of fighting in light that was too bright to see."
      ),
      Echo.new(
        name:      "Shade of the Not-Yet",
        arcana:    :chthonic,
        stats:     { hp: -5, atk: 6, def: 1, spd: 4 },
        skills:    [:echo_chthonic_rend, :echo_void_step],
        passives:  [:echo_fracture_resist],
        lore_line: "An echo born in the proto-underworld. It smells like stone that hasn't been named."
      ),
      Echo.new(
        name:      "First Hunter",
        arcana:    :feral,
        stats:     { hp: 5, atk: 5, def: 2, spd: 3 },
        skills:    [:echo_feral_rush, :echo_pack_memory],
        passives:  [:echo_scent_trail],
        lore_line: "Before myths had hunters, there was this."
      ),
      Echo.new(
        name:      "Unformed Divine",
        arcana:    :unformed,
        stats:     { hp: 10, atk: 1, def: 5, spd: 0 },
        skills:    [:echo_divine_ward, :echo_unmake],
        passives:  [:echo_myth_memory],
        lore_line: "A god that never finished becoming one."
      ),
      Echo.new(
        name:      "Marble Voice",
        arcana:    :divine,
        stats:     { hp: 4, atk: 3, def: 3, spd: 2 },
        skills:    [:echo_stone_shout, :echo_column_crush],
        passives:  [:echo_fang_resonance],
        lore_line: "What temples sound like when they're angry."
      ),
      Echo.new(
        name:      "Titan Fragment",
        arcana:    :chthonic,
        stats:     { hp: 12, atk: 7, def: 4, spd: -1 },
        skills:    [:echo_titan_slam, :echo_earth_split],
        passives:  [:echo_stone_skin],
        lore_line: "A piece of something vast that broke before it could be whole."
      ),
      Echo.new(
        name:      "Draft of Orpheus",
        arcana:    :divine,
        stats:     { hp: 2, atk: 2, def: 2, spd: 5 },
        skills:    [:echo_song_stun, :echo_myth_weave],
        passives:  [:echo_fracture_resist],
        lore_line: "He hasn't been written yet. But his echo is already here."
      ),
      Echo.new(
        name:      "The Ink-Scared Pup",
        arcana:    :unformed,
        stats:     { hp: 0, atk: 0, def: 0, spd: 0 },
        skills:    [:echo_survive, :echo_endure],
        passives:  [:echo_myth_memory],
        lore_line: "This echo will outlast everything else. It already knows how."
      )
    ]
  end

  def grant_random_echo(source: nil)
    available = echo_templates.reject { |e| @player.echoes.key?(e.name) }
    return puts("No new echoes to find.") if available.empty?

    echo = available.sample
    @player.echoes[echo.name] = echo
    puts "\nAn echo of another self settles over your fur."
    puts "Echo gained: #{echo.name} (Arcana: #{echo.arcana.to_s.capitalize})"
    puts "(#{echo.lore_line})"
    puts "(Source: #{source})" if source
  end

  def forge_echo_from_fragments
    if @player.echo_fragments < 5
      puts "You need 5 echo fragments to forge a new Echo. (#{@player.echo_fragments}/5)"
      return
    end
    @player.echo_fragments -= 5
    grant_random_echo(source: "forged fragments")
  end

  def fuse_echoes_menu
    if @player.echoes.size < 2
      puts "You need at least two Echoes to fuse."
      return
    end

    puts "\n=== ECHO FUSION ==="
    echoes = @player.echoes.values
    echoes.each_with_index { |e, i| puts "#{i + 1}. #{e.name} (#{e.arcana.to_s.capitalize}, Lv #{e.level})" }

    print "First Echo: "
    a = echoes[gets.to_i - 1]
    print "Second Echo: "
    b = echoes[gets.to_i - 1]

    unless a && b && a != b
      puts "Invalid selection."
      return
    end

    result = fuse_echoes(a, b)
    puts "\nFusion: #{result.name} (#{result.arcana.to_s.capitalize})"
    puts "Accept? (y/n)"
    print "> "
    if gets&.strip&.downcase == "y"
      @player.echoes.delete(a.name)
      @player.echoes.delete(b.name)
      @player.echoes[result.name] = result
      @player.equipped_echo = result
      puts "The two selves merge into one. #{result.name} is born."
    else
      puts "Fusion refused."
    end
  end

  def fuse_echoes(a, b)
    arcana_map = {
      [:solar,   :chthonic] => :unformed,
      [:solar,   :feral]    => :solar,
      [:solar,   :unformed] => :divine,
      [:solar,   :divine]   => :solar,
      [:chthonic,:feral]    => :feral,
      [:chthonic,:unformed] => :chthonic,
      [:chthonic,:divine]   => :unformed,
      [:feral,   :unformed] => :feral,
      [:feral,   :divine]   => :divine,
      [:unformed,:divine]   => :unformed
    }
    pair   = [a.arcana, b.arcana].sort
    arcana = arcana_map[pair] || pair.sample

    stats = {
      hp:  ((a.stats[:hp]  + b.stats[:hp])  / 2.0).round,
      atk: ((a.stats[:atk] + b.stats[:atk]) / 2.0).round,
      def: ((a.stats[:def] + b.stats[:def]) / 2.0).round,
      spd: ((a.stats[:spd] + b.stats[:spd]) / 2.0).round
    }

    Echo.new(
      name:      "#{a.name.split.first}-#{b.name.split.first} Echo",
      arcana:    arcana,
      stats:     stats,
      skills:    (a.skills + b.skills).uniq.sample(3),
      passives:  (a.passives + b.passives).uniq.sample(2),
      lore_line: "Two selves collapsed into one that is neither."
    )
  end

  # =========================
  # STARTING AREA
  # =========================

  def build_starting_area
    path = Room.new(
      "The Sun-Bleached Path",
      "White stone under a sky that has never dimmed. It hums.",
      lore:  "You found the Fang here. It was just lying on the path. Waiting.",
      zone:  :surface
    )

    agora = Room.new(
      "The Humming Agora",
      "A market where half-formed people trade things that haven't been invented.",
      lore:  "The merchants don't look directly at the Fang. They know what it is, even if you don't.",
      zone:  :surface
    )
    agora.npc = NPC.new(
      "Agora Trader",
      [
        "Iron slivers, dispellers — I take both.",
        "The ground shook last night. I'm pretending it didn't.",
        "I had a dream that the sun went out. I didn't know what dark was. Still don't.",
        "That weapon you're carrying — I'd put it down if I were you. I'm not you though."
      ]
    )

    temple = Room.new(
      "Temple of the Unfinished",
      "Columns that hum. Roof open to a sky that presses down.",
      lore:  "The god this temple was built for hasn't been invented yet. The temple is patient.",
      zone:  :surface
    )

    crack = Room.new(
      "The First Crack",
      "A split in the earth that smells cold. Cold is a new concept here.",
      lore:  "This is where you go down. The crack wasn't here yesterday. The world made it for you.",
      zone:  :descent
    )

    path.exits["north"]  = agora
    path.exits["east"]   = temple
    path.exits["south"]  = crack
    agora.exits["south"] = path
    temple.exits["west"] = path
    crack.exits["north"] = path

    @rooms[:path]   = path
    @rooms[:agora]  = agora
    @rooms[:temple] = temple
    @rooms[:crack]  = crack

    @player.room = path

    puts "\nThe sun is too loud."
    puts "The marble hums."
    puts "In your paw: the Fang, warm and wrong."
    puts "\nYour name echoes on the stone: #{@player.name}."
    puts "\n(Type HELP for commands.)\n"
  end

  # =========================
  # COMPANION GENERATION
  # =========================

  def try_spawn_companion(zone)
    case zone
    when :surface
      return if @companions_met[:scout]
      return unless rand < 0.30

      scout = PartyMember.new(
        id:             :scout,
        name:           "Kira the Scout",
        role:           :dps,
        hp:             32,
        atk:            9,
        defense:        3,
        speed:          BASE_SPEED[:companion_scout],
        skills:         [:swift_strike, :track_weakness],
        limit_name:     "Prey-Sight",
        limit_desc:     "Kira strikes every enemy in sequence for escalating damage.",
        joined_at_zone: :surface
      )
      @player.party << scout
      @companions_met[:scout] = true
      @player.room.npc = NPC.new("Kira the Scout", COMPANION_LINES[:scout])
      puts "\nA lean dog steps out from behind a column."
      puts "\"I've been following the Fang's glow for two days,\" she says."
      puts "\"Wherever you're going, I'm better than going alone.\""
      puts "Kira the Scout joins your party."

    when :descent
      return if @companions_met[:bard]
      return unless rand < 0.35

      bard = PartyMember.new(
        id:             :bard,
        name:           "Theo the Bard",
        role:           :support,
        hp:             28,
        atk:            6,
        defense:        4,
        speed:          BASE_SPEED[:companion_bard],
        skills:         [:hymn_of_stone, :discord_shout],
        limit_name:     "The First Song",
        limit_desc:     "A song that has never been heard before. Stuns all enemies.",
        joined_at_zone: :descent
      )
      @player.party << bard
      @companions_met[:bard] = true
      @player.room.npc = NPC.new("Theo the Bard", COMPANION_LINES[:bard])
      puts "\nA dog sits against the cave wall, writing on a wax tablet."
      puts "\"I'm documenting this,\" he says. \"Someone has to.\""
      puts "Theo the Bard joins your party."

    when :underworld
      return if @companions_met[:seer]
      return unless rand < 0.40

      seer = PartyMember.new(
        id:             :seer,
        name:           "Mira the Seer",
        role:           :mage,
        hp:             26,
        atk:            8,
        defense:        3,
        speed:          BASE_SPEED[:companion_seer],
        skills:         [:fate_read, :unwrite_fate],
        limit_name:     "Oracle's Collapse",
        limit_desc:     "Mira sees the enemy's next move and counters it perfectly.",
        joined_at_zone: :underworld
      )
      @player.party << seer
      @companions_met[:seer] = true
      @player.room.npc = NPC.new("Mira the Seer", COMPANION_LINES[:seer])
      puts "\nA dog stands very still in the middle of the path."
      puts "\"I've been waiting here for you,\" she says. \"Since before you were born.\""
      puts "Mira the Seer joins your party."
    end
  end

  # =========================
  # MAIN LOOP
  # =========================

  def main_loop
    while @running && @player.alive?
      show_status
      describe_room
      print "\n> "
      cmd = gets&.strip&.downcase
      handle_command(cmd)
    end

    unless @player.alive?
      puts "\n#{@player.name} falls."
      puts "The first death in a world that wasn't ready for one."
      puts "\nThe Ink-Scared Pup tears itself free from your soul."
      puts "It flees."
      puts "It will find someone else. Centuries from now."
      puts "\nThe world collapses behind it."
    end

    puts "\nThe myth dissolves."
  end

  def show_status(verbose = false)
    puts "\n[#{@player.name} | Zone: #{@player.zone.to_s.capitalize} | Depth: #{@depth}]"
    puts "HP: #{@player.hp}/#{@player.max_hp} | Iron: #{@player.iron_slivers} | Dispellers: #{@player.dispellers}"
    puts "Fracture: #{@player.fracture}/100 | Fang Lv: #{@player.fang_level}"
    puts "Echo Fragments: #{@player.echo_fragments}/5"
    if @player.equipped_echo
      e = @player.equipped_echo
      puts "Echo: #{e.name} (#{e.arcana.to_s.capitalize}, Lv #{e.level})"
    end
    if verbose
      puts "Party: " + (@player.party.empty? ? "None" : @player.party.map { |p| "#{p.name} HP #{p.hp}/#{p.max_hp}" }.join(", "))
      puts "Echoes: #{@player.echoes.size}"
      puts "Kills: #{@player.kills}"
    end
  end

  def describe_room(force_lore = false)
    r = @player.room
    puts "\n#{r.name}  [#{r.zone.to_s.gsub('_',' ').capitalize}]"
    puts r.desc
    puts r.lore if (force_lore || !r.visited) && r.lore
    r.visited = true

    if r.enemy_group.any?(&:alive?)
      names = r.enemy_group.select(&:alive?).map(&:name).join(", ")
      puts "Enemies: #{names}"
      puts "(Type FIGHT to engage.)"
    end

    puts "NPC: #{r.npc.name}" if r.npc
    puts "Exits: #{r.exits.keys.join(', ')}"
    fracture_desc

    # Auto-trigger combat on entry
    if r.enemy_group.any?(&:alive?) && !r.flags[:combat_triggered]
      r.flags[:combat_triggered] = true
      puts "\nSomething moves. It notices you first."
      fight_room_enemies
    end

    # Try to spawn a companion
    try_spawn_companion(@player.zone)
  end

  def fracture_desc
    f = @player.fracture
    case f
    when 0..19   then # quiet
    when 20..39  then puts "(The ground hums a note it shouldn't know.)"
    when 40..59  then puts "(A crack appears in the nearest wall. It wasn't there before.)"
    when 60..79  then puts "(The light flickers. The world is losing its argument with itself.)"
    when 80..99  then puts "(The myth is coming apart. You can hear the seams tearing.)"
    when 100     then
      puts "\nThe world fractures completely."
      puts "The myth collapses around you."
      puts "#{@player.name} is erased by a world that couldn't hold itself together."
      @running = false
    end
  end

  def show_help
    puts "\n=== COMMANDS ==="
    puts "look / l         – Describe the room"
    puts "n/s/e/w          – Move"
    puts "go <dir>         – Move in a direction"
    puts "fight / attack   – Fight enemies in this room"
    puts "talk             – Speak to an NPC"
    puts "search           – Search the area"
    puts "status           – Detailed status"
    puts "echo             – Manage Echoes"
    puts "fuse             – Fuse two Echoes"
    puts "forge            – Forge Echo from 5 fragments"
    puts "fang             – Check Fang status"
    puts "use dispeller    – Use a dispeller (outside combat)"
    puts "save             – Save"
    puts "load             – Load"
    puts "console          – Debug console"
    puts "help             – This list"
    puts "quit             – Leave"
  end

  # =========================
  # COMMAND HANDLER
  # =========================

  def handle_command(cmd)
    return unless cmd
    @player.command_count += 1

    case cmd
    when "look", "l"
      describe_room(true)
    when "n", "north", "s", "south", "e", "east", "w", "west"
      move(normalize_dir(cmd))
    when /^go (.+)$/
      move($1.strip.downcase)
    when "fight", "attack", "battle"
      fight_room_enemies
    when "talk"
      talk
    when "search"
      search_area
    when "status"
      show_status(true)
    when "echo"
      echo_menu
    when "fuse"
      fuse_echoes_menu
    when "forge"
      forge_echo_from_fragments
    when "fang"
      fang_status
    when "use dispeller"
      use_dispeller_outside_combat
    when "save"
      save_game
    when "load"
      load_game
    when "console"
      debug_console
    when "help"
      show_help
    when "quit", "exit"
      @running = false
    else
      puts "The marble doesn't respond to that."
    end
  end

  def normalize_dir(cmd)
    { "n" => "north", "s" => "south", "e" => "east", "w" => "west" }[cmd] || cmd
  end

  # =========================
  # MOVEMENT & ROOM GENERATION
  # =========================

  def move(dir)
    r = @player.room

    if r.enemy_group.any?(&:alive?)
      puts "Something is in the way. Deal with it first."
      return
    end

    if r.exits[dir].is_a?(Room)
      new_room = r.exits[dir]
      puts "\nYou head #{dir}."
    else
      @depth += 1
      @player.depth = @depth

      new_room = if @depth >= 25 && !@hades_defeated
        build_hades_chamber
      else
        generate_room_for_depth
      end

      r.exits[dir]                      = new_room
      new_room.exits[opposite_dir(dir)] = r

      # Stitch loops — 35% chance a new room's nil exit connects to an existing room
      new_room.exits.each do |exit_dir, target|
        next unless target.nil?
        if rand < 0.35
          candidates = @rooms.values.select { |rm| rm != new_room && rm != r }
          if (loop_target = candidates.sample)
            back = opposite_dir(exit_dir)
            if !loop_target.exits[back].is_a?(Room)
              new_room.exits[exit_dir]  = loop_target
              loop_target.exits[back]   = new_room
            end
          end
        end
      end
    end

    @player.room = new_room
    update_zone(new_room.zone)
    tick_fracture_on_move

    describe_room

    if new_room == @hades_room && !@hades_defeated
      start_hades_battle
    end
  end

  def update_zone(new_zone)
    if new_zone != @player.zone
      @player.zone = new_zone
      case new_zone
      when :descent
        puts "\nThe light thins. The cold rises. You are going down."
        @player.fang_level = [@player.fang_level, 2].max
        puts "The Fang brightens as you descend. (Fang Lv #{@player.fang_level})"
      when :underworld
        puts "\nThe surface is gone. The world above is a memory."
        puts "The underworld breathes around you."
        @player.fang_level = [@player.fang_level, 3].max
        puts "The Fang hums with recognition. (Fang Lv #{@player.fang_level})"
      when :hades_domain
        puts "\nThe air is different here. Heavy. Intentional."
        puts "Everything that exists is being decided in this room."
      end
    end
  end

  def tick_fracture_on_move
    return if @player.zone == :surface
    gain = case @player.zone
           when :descent     then rand(1..3)
           when :underworld  then rand(2..5)
           when :hades_domain then rand(3..6)
           else 0
           end

    gain = (gain * 0.6).round if @player.equipped_echo&.passives&.include?(:echo_fracture_resist)
    @player.fracture = [@player.fracture + gain, 100].min
  end

  def generate_room_for_depth
    zone = determine_zone_for_depth(@depth)
    case zone
    when :surface    then generate_surface_room
    when :descent    then generate_descent_room
    when :underworld then generate_underworld_room
    else generate_surface_room
    end
  end

  def determine_zone_for_depth(d)
    case d
    when  0..8  then :surface
    when  9..16 then :descent
    else             :underworld
    end
  end

  def randomize_exits(room)
    dirs = ["north","south","east","west"].shuffle.take(rand(2..3))
    dirs.each { |d| room.exits[d] = nil }
  end

  def maybe_add_enemy(room, rate_modifier = 0)
    return if @linger_only_mode
    if rand < (@encounter_rate + rate_modifier)
      room.enemy_group = [generate_enemy(room.zone)]
    end
  end

  def register_room(room)
    @rooms[:"room_#{room.id[0,6]}"] = room
    room
  end

  def generate_surface_room
    room = Room.new(
      SURFACE_ROOM_NAMES.sample,
      SURFACE_ROOM_DESCS.sample,
      lore: SURFACE_LORE.sample,
      zone: :surface
    )
    randomize_exits(room)
    maybe_add_enemy(room, -0.15)
    room.npc = generate_npc(:surface) if rand < 0.20
    register_room(room)
  end

  def generate_descent_room
    room = Room.new(
      DESCENT_ROOM_NAMES.sample,
      DESCENT_ROOM_DESCS.sample,
      lore: DESCENT_LORE.sample,
      zone: :descent
    )
    randomize_exits(room)
    maybe_add_enemy(room)
    room.npc = generate_npc(:descent) if rand < 0.15
    register_room(room)
  end

  def generate_underworld_room
    room = Room.new(
      UNDERWORLD_ROOM_NAMES.sample,
      UNDERWORLD_ROOM_DESCS.sample,
      lore: UNDERWORLD_LORE.sample,
      zone: :underworld
    )
    randomize_exits(room)
    maybe_add_enemy(room, 0.10)

    # Underworld rooms may drop echo fragments
    room.flags[:has_fragment] = rand < 0.25

    register_room(room)
  end

  def build_hades_chamber
    return @hades_room if @hades_room

    room = Room.new(
      "The Chamber at the Bottom of the World",
      "The walls are not stone. They are compressed myth. Everything that will ever die lives here first.",
      lore: HADES_CHAMBER_LORE.sample,
      zone: :hades_domain
    )
    room.flags[:is_hades_room] = true
    room.shelves     = []
    room.enemy_group = []

    room.npc = NPC.new("The Incomplete God", [
      "You were not meant to find me.",
      "But you came anyway.",
      "The Fang shouldn't exist. Neither should you.",
      "I am still deciding what I am. You have interrupted that process.",
      "What you did to reach this place — the world will remember it as a mistake.",
      "I don't want to fight you. But I am what I am becoming."
    ])

    register_room(room)
    @hades_room = room
    room
  end

  # =========================
  # NPC GENERATION
  # =========================

  def generate_npc(zone)
    case zone
    when :surface
      names = ["Temple Keeper", "Agora Merchant", "Half-Formed Pilgrim",
               "Wandering Shepherd", "Marble Carver"]
      lines_pool = [
        ["The gods are still being written. I'd stay out of the way.",
         "That crack in the ground wasn't there yesterday.",
         "I sold a man a shadow last week. He didn't know what it was."],
        ["Everything here hums. I've stopped noticing.",
         "The sun never moves. I've started to hate it.",
         "Your dog smells like something that doesn't exist yet."],
        ["I built this temple before I knew what god it was for.",
         "The Fang chose you. I don't know why. I'm not asking.",
         "Don't go into the caves. The dark there isn't natural."]
      ]
      NPC.new(names.sample, lines_pool.sample)
    when :descent
      names = ["Cave-Bound Wanderer", "Lost Initiate", "Threshold Guard",
               "Stone-Speaker"]
      lines_pool = [
        ["The cold down here is wrong. Cold shouldn't exist yet.",
         "I came down to find something. I found it. Now I can't leave.",
         "The underworld breathes. I can hear it."],
        ["The spirits down here are still becoming. Don't interrupt them.",
         "The Fang is the only thing that works down here.",
         "I've been here three days. The concept of 'day' doesn't apply."]
      ]
      NPC.new(names.sample, lines_pool.sample)
    else
      NPC.new("Drifting Spirit",
        ["I'm not finished yet.",
         "This place is a draft. I'm one of the rough parts.",
         "The light above is very far away now."])
    end
  end

  # =========================
  # ENEMY GENERATION
  # =========================

  def generate_enemy(zone = :surface)
    pool = case zone
           when :surface   then ENEMY_POOL.select { |e| e[:tags].include?(:surface) || e[:tags].include?(:myth) }
           when :descent   then ENEMY_POOL.select { |e| e[:tags].include?(:stone) || e[:tags].include?(:unformed) }
           when :underworld then ENEMY_POOL.select { |e| e[:tags].include?(:chthonic) || e[:tags].include?(:spirit) }
           else ENEMY_POOL
           end
    pool = ENEMY_POOL if pool.empty?
    e = pool.sample

    Enemy.new(
      name:    e[:name],
      hp:      rand(e[:hp][0]..e[:hp][1]),
      atk:     rand(e[:atk][0]..e[:atk][1]),
      defense: rand(e[:def][0]..e[:def][1]),
      speed:   e[:spd],
      desc:    "It flickers between what it is and what it was going to be.",
      tags:    e[:tags]
    )
  end

  # =========================
  # SEARCH AREA
  # =========================

  def search_area
    room = @player.room
    puts "You search the area…"

    # Fragment pickup
    if room.flags[:has_fragment]
      room.flags[:has_fragment] = false
      @player.echo_fragments += 1
      puts "You find an echo fragment — a shard of someone who almost existed. (#{@player.echo_fragments}/5)"
      forge_echo_from_fragments if @player.echo_fragments >= 5
    end

    # Iron slivers
    if rand < 0.35
      gain = rand(5..18)
      @player.iron_slivers += gain
      puts "You find #{gain} iron slivers in a crack in the stone."
    end

    # Dispellers
    if rand < 0.20
      @player.dispellers += 1
      puts "You find a dispeller — a small jar of condensed myth-light."
    end

    # Lore
    if rand < 0.40
      lore = case @player.zone
             when :surface    then SURFACE_LORE.sample
             when :descent    then DESCENT_LORE.sample
             when :underworld then UNDERWORLD_LORE.sample
             else SURFACE_LORE.sample
             end
      puts lore
    end

    # Fracture event
    if rand < 0.25
      puts FRACTURE_EVENTS.sample
      @player.fracture = [@player.fracture + rand(2..5), 100].min
    end

    # Random echo grant
    grant_random_echo(source: "the ruins") if rand < 0.04
  end

  def use_dispeller_outside_combat
    if @player.dispellers <= 0
      puts "You have no dispellers."
      return
    end
    @player.dispellers -= 1
    heal = rand(12..20)
    @player.hp = [@player.hp + heal, @player.max_hp].min
    @player.fracture = [@player.fracture - 10, 0].max
    puts "You uncork the dispeller. Myth-light floods your fur. +#{heal} HP, -10 Fracture."
  end

  def fang_status
    puts "\n=== THE FANG ==="
    puts "Level: #{@player.fang_level}"
    case @player.fang_level
    when 1 then puts "Warm and wrong. Like it was waiting for you specifically."
    when 2 then puts "Glowing faintly. The underworld recognizes it."
    when 3 then puts "Humming constantly. The proto-dead flinch when you raise it."
    when 4 then puts "Screaming silently. Reality bends slightly near the blade."
    end
  end

  # =========================
  # NPC TALK
  # =========================

  def talk
    npc = @player.room.npc
    unless npc
      puts "No one here to talk to. The stone doesn't answer."
      return
    end

    puts "\n#{npc.name}:"
    puts "\"#{npc.speak}\""

    # Echo-aware reactions
    if @player.equipped_echo
      e = @player.equipped_echo
      case e.arcana
      when :solar    then puts "(#{npc.name} squints at the light coming off your Echo.)"
      when :chthonic then puts "(#{npc.name} takes a step back. \"That smells like the underworld.\")"
      when :feral    then puts "(#{npc.name} watches your Echo with the wariness of prey.)"
      when :divine   then puts "(#{npc.name} bows their head slightly, involuntarily.)"
      when :unformed then puts "(#{npc.name} looks through your Echo like it isn't quite there.)"
      end
    end

    # Merchant check
    merchant_menu(npc) if npc.name.include?("Merchant") || npc.name.include?("Trader")
  end

  def merchant_menu(npc)
    puts "\n#{npc.name} lays out their wares."
    puts "Iron slivers: #{@player.iron_slivers}"
    puts "1. Bandage (+1)        — 20 slivers"
    puts "2. Dispeller (+1)      — 35 slivers"
    puts "3. Echo Fragment (+1)  — 55 slivers"
    puts "4. Leave"
    print "> "

    case gets&.strip
    when "1" then buy_item(:bandage, 20)
    when "2" then buy_dispeller(35)
    when "3" then buy_echo_fragment(55)
    else puts "#{npc.name} wraps the goods back up."
    end
  end

  def buy_item(item, cost)
    if @player.iron_slivers >= cost
      @player.iron_slivers -= cost
      @player.inventory[item] = (@player.inventory[item] || 0) + 1
      puts "Bought #{item}."
    else
      puts "Not enough iron slivers."
    end
  end

  def buy_dispeller(cost)
    if @player.iron_slivers >= cost
      @player.iron_slivers -= cost
      @player.dispellers += 1
      puts "You acquire a dispeller."
    else
      puts "Not enough iron slivers."
    end
  end

  def buy_echo_fragment(cost)
    if @player.iron_slivers >= cost
      @player.iron_slivers -= cost
      @player.echo_fragments += 1
      puts "Echo fragment acquired. (#{@player.echo_fragments}/5)"
      forge_echo_from_fragments if @player.echo_fragments >= 5
    else
      puts "Not enough iron slivers."
    end
  end

  # =========================
  # ECHO MENU
  # =========================

  def echo_menu
    if @player.echoes.empty?
      puts "You carry no Echoes."
      return
    end

    puts "\n=== ECHOES ==="
    @player.echoes.values.each_with_index do |e, i|
      eq = (e == @player.equipped_echo) ? "*" : " "
      puts "#{i + 1}.#{eq} #{e.name} (#{e.arcana.to_s.capitalize}, Lv #{e.level})"
      puts "     #{e.lore_line}"
    end

    puts "\nChoose an Echo to equip (Enter to cancel):"
    print "> "
    line = gets&.strip
    return if line.nil? || line.empty?

    echo = @player.echoes.values[line.to_i - 1]
    unless echo
      puts "No such Echo."
      return
    end
    @player.equipped_echo = echo
    puts "#{echo.name} settles over your fur like a second skin."
  end

  # =========================
  # COMBAT ENGINE
  # =========================

  SKILL_DESCRIPTIONS = {
    swift_strike:      "Fast attack, high priority.",
    track_weakness:    "Reveal and exploit a weakness — lowers enemy DEF.",
    hymn_of_stone:     "Boost party DEF with an ancient song.",
    discord_shout:     "Shout that lowers all enemy ATK.",
    fate_read:         "Predict and reduce next enemy attack to 0.",
    unwrite_fate:      "Remove all enemy buffs.",
    echo_solar_strike: "Fang-empowered strike. Bonus damage from Fang level.",
    echo_blinding_rush:"Hit and blind — enemy loses next turn.",
    echo_chthonic_rend:"Underworld damage — bypasses DEF.",
    echo_void_step:    "Step through reality — avoid next attack.",
    echo_feral_rush:   "Multi-hit physical attack (2-4 hits).",
    echo_pack_memory:  "Heal party slightly.",
    echo_divine_ward:  "Absorb next hit for the party.",
    echo_unmake:       "High damage, high backlash.",
    echo_stone_shout:  "AoE — stuns all enemies one turn.",
    echo_column_crush: "Crush a single enemy for heavy damage.",
    echo_titan_slam:   "Massive single hit.",
    echo_earth_split:  "AoE — damages all enemies.",
    echo_song_stun:    "Stun one enemy for 1 turn.",
    echo_myth_weave:   "Heal self based on Fang level.",
    echo_survive:      "Emergency heal when HP < 20%.",
    echo_endure:       "Reduce next hit by half."
  }

  def build_combat_roster(enemies)
    player_actor = PartyMember.new(
      id:         :player,
      name:       @player.name,
      role:       :leader,
      hp:         @player.hp,
      atk:        @player.atk + (@player.fang_level * 2),
      defense:    @player.defense,
      speed:      @player.speed,
      skills:     [:basic_attack, :guard, :use_dispeller, :use_item],
      limit_name: "Fang Ascendant",
      limit_desc: "The Fang reaches full power — devastating blow to all enemies."
    )
    apply_echo_to_actor(player_actor)
    [player_actor, *@player.party, *enemies]
  end

  def apply_echo_to_actor(actor)
    return unless @player.equipped_echo
    e = @player.equipped_echo
    actor.max_hp  += e.stats[:hp]
    actor.hp       = [actor.hp + e.stats[:hp], actor.max_hp].min
    actor.atk     += e.stats[:atk]
    actor.defense += e.stats[:def]
    actor.speed   += e.stats[:spd]
    actor.skills  += e.skills
  end

  def show_combat_status(roster, enemies)
    puts "\n=== PARTY ==="
    roster.each do |c|
      next unless c.is_a?(PartyMember)
      lim = c.limit_ready ? " [LIMIT]" : ""
      puts "#{c.name}: HP #{c.hp}/#{c.max_hp} | ATK #{c.atk} | DEF #{c.defense}#{lim}"
    end
    puts "\n=== ENEMIES ==="
    enemies.each { |e| puts "#{e.name}: HP #{e.hp}/#{e.max_hp}" }
    puts "\nFracture: #{@player.fracture} | Dispellers: #{@player.dispellers}"
  end

  def check_limit_breaks(roster)
    roster.each do |c|
      next unless c.is_a?(PartyMember) && !c.limit_ready
      threshold = @player.equipped_echo&.passives&.include?(:echo_fang_resonance) ? 0.45 : 0.30
      if c.hp < (c.max_hp * threshold) || @player.fracture > 65
        c.limit_ready = true
        puts "\n#{c.name}'s limit breaks open!"
      end
    end
  end

  def fight_room_enemies
    room    = @player.room
    enemies = room.enemy_group.select(&:alive?)

    if enemies.empty?
      puts "Nothing left to fight here."
      return
    end

    puts "\nYou face: #{enemies.map(&:name).join(', ')}"
    battle(enemies)
    room.enemy_group.reject!(&:alive?)
    room.flags[:combat_triggered] = true
  end

  def battle(enemies)
    clear
    puts "[The Fang hums. Something moves.]\n\n"

    roster = build_combat_roster(enemies)
    atb    = {}
    roster.each { |c| atb[c] = 0 }

    until enemies.none?(&:alive?)
      check_limit_breaks(roster)
      show_combat_status(roster, enemies)

      roster.select(&:alive?).each { |c| atb[c] += c.speed }
      actor = roster.find { |c| c.alive? && atb[c] >= 100 }

      if actor
        atb[actor] = 0
        actor.is_a?(Enemy) ? enemy_turn(actor, roster) : player_combat_turn(actor, enemies, roster)
      end

      if @player.fracture >= 100
        puts "\nThe world fractures. You fracture with it."
        @running = false
        return
      end
    end

    conclude_battle(enemies, roster)
  end

  def enemy_turn(enemy, roster)
    return unless enemy.alive?
    target = roster.select { |c| c.alive? && c.is_a?(PartyMember) }.sample
    return unless target
    dmg = [(enemy.atk - target.defense) * @damage_mult, 1].max.round
    target.hp -= dmg
    puts "#{enemy.name} strikes #{target.name} for #{dmg}."
    puts "#{target.name} collapses." if target.hp <= 0
  end

  def player_combat_turn(actor, enemies, roster)
    puts "\n#{actor.name}'s turn."
    puts "1. Attack  2. Skill  3. Dispeller  4. Item  5. Guard"
    puts "6. Limit Break" if actor.limit_ready
    print "> "

    case gets&.strip
    when "1"
      target = choose_enemy(enemies)
      basic_attack(actor, target)
    when "2"
      use_skill(actor, enemies, roster)
    when "3"
      use_dispeller_in_combat(actor)
    when "4"
      use_item(actor)
    when "5"
      guard(actor)
    when "6"
      if actor.limit_ready
        use_limit_break(actor, enemies, roster)
        actor.limit_ready = false
      else
        puts "Not ready yet."
      end
    else
      puts "You hesitate. The enemy doesn't."
    end
  end

  def basic_attack(actor, target)
    return unless target&.alive?
    dmg = [(actor.atk - target.defense) * @damage_mult, 1].max.round
    target.hp -= dmg
    puts "#{actor.name} strikes #{target.name} for #{dmg}."
    puts "#{target.name} dissolves back into myth." if target.hp <= 0
  end

  def guard(actor)
    actor.defense += 2
    puts "#{actor.name} braces."
  end

  def choose_enemy(enemies)
    alive = enemies.select(&:alive?)
    return nil if alive.empty?
    return alive.first if alive.size == 1
    puts "\nTarget:"
    alive.each_with_index { |e, i| puts "#{i + 1}. #{e.name} (#{e.hp} HP)" }
    print "> "
    alive[gets.to_i - 1] || alive.first
  end

  def use_dispeller_in_combat(actor)
    if @player.dispellers <= 0
      puts "No dispellers left."
      return
    end
    @player.dispellers -= 1
    heal = rand(10..18)
    actor.hp = [actor.hp + heal, actor.max_hp].min
    @player.fracture = [@player.fracture - 8, 0].max
    puts "#{actor.name} uncorks a dispeller. +#{heal} HP, -8 Fracture."
  end

  def use_item(actor)
    puts "\nItems:"
    puts "1. Bandage (#{@player.inventory[:bandage] || 0})"
    print "> "
    if gets&.strip == "1"
      if (@player.inventory[:bandage] || 0) > 0
        @player.inventory[:bandage] -= 1
        heal = rand(8..14)
        actor.hp = [actor.hp + heal, actor.max_hp].min
        puts "#{actor.name} bandages a wound. +#{heal} HP."
      else
        puts "None left."
      end
    end
  end

  def use_skill(actor, enemies, roster)
    puts "\nSkills:"
    actor.skills.each_with_index do |s, i|
      puts "#{i + 1}. #{s.to_s.gsub('_',' ').capitalize} — #{SKILL_DESCRIPTIONS[s] || '?'}"
    end
    print "> "
    skill = actor.skills[gets.to_i - 1]
    return puts("Nothing happens.") unless skill

    case skill
    when :swift_strike        then swift_strike(actor, enemies)
    when :track_weakness      then track_weakness(actor, enemies)
    when :hymn_of_stone       then hymn_of_stone(actor, roster)
    when :discord_shout       then discord_shout(enemies)
    when :fate_read           then fate_read(enemies)
    when :unwrite_fate        then unwrite_fate(enemies)
    when :echo_solar_strike   then echo_solar_strike(actor, enemies)
    when :echo_blinding_rush  then echo_blinding_rush(actor, enemies)
    when :echo_chthonic_rend  then echo_chthonic_rend(actor, enemies)
    when :echo_void_step      then echo_void_step(actor)
    when :echo_feral_rush     then echo_feral_rush(actor, enemies)
    when :echo_pack_memory    then echo_pack_memory(actor, roster)
    when :echo_divine_ward    then echo_divine_ward(actor, roster)
    when :echo_unmake         then echo_unmake(actor, enemies)
    when :echo_stone_shout    then echo_stone_shout(enemies)
    when :echo_column_crush   then echo_column_crush(actor, enemies)
    when :echo_titan_slam     then echo_titan_slam(actor, enemies)
    when :echo_earth_split    then echo_earth_split(actor, enemies)
    when :echo_song_stun      then echo_song_stun(enemies)
    when :echo_myth_weave     then echo_myth_weave(actor)
    when :echo_survive        then echo_survive(actor)
    when :echo_endure         then echo_endure(actor)
    else puts "The myth doesn't respond."
    end
  end

  # Companion skills
  def swift_strike(actor, enemies)
    target = choose_enemy(enemies)
    dmg = (actor.atk * 1.3 * @damage_mult).round
    target.hp -= dmg
    puts "#{actor.name} strikes fast — #{dmg} damage!"
  end

  def track_weakness(actor, enemies)
    target = choose_enemy(enemies)
    target.defense -= 3
    puts "#{actor.name} reads #{target.name}'s movement. DEF -3."
  end

  def hymn_of_stone(actor, roster)
    roster.each { |c| c.defense += 3 if c.is_a?(PartyMember) }
    puts "#{actor.name} sings the hymn of stone. Party DEF +3."
  end

  def discord_shout(enemies)
    enemies.each { |e| e.atk -= 2 }
    puts "A shout of pure discord. All enemies ATK -2."
  end

  def fate_read(enemies)
    target = choose_enemy(enemies)
    target.speed = 0
    puts "Mira reads the fate thread. #{target.name} loses all speed."
  end

  def unwrite_fate(enemies)
    enemies.each do |e|
      e.atk     = [e.atk     - 2, 0].max
      e.defense = [e.defense - 2, 0].max
    end
    puts "Mira unravels the enemy's written advantage."
  end

  # Echo skills
  def echo_solar_strike(actor, enemies)
    target = choose_enemy(enemies)
    bonus  = @player.fang_level * 3
    dmg    = (actor.atk + bonus) * @damage_mult
    target.hp -= dmg.round
    puts "The Fang blazes — #{target.name} takes #{dmg.round} solar damage!"
  end

  def echo_blinding_rush(actor, enemies)
    target = choose_enemy(enemies)
    dmg = (actor.atk * @damage_mult).round
    target.hp    -= dmg
    target.speed  = 0
    puts "#{actor.name} rushes through — #{dmg} damage, #{target.name} blinded."
  end

  def echo_chthonic_rend(actor, enemies)
    target = choose_enemy(enemies)
    dmg = (rand(12..20) * @damage_mult).round
    target.hp -= dmg
    puts "Underworld force tears into #{target.name} for #{dmg} — DEF ignored."
  end

  def echo_void_step(actor)
    actor.status_effects[:dodge_next] = true
    puts "#{actor.name} steps between moments. Next attack misses."
  end

  def echo_feral_rush(actor, enemies)
    target = choose_enemy(enemies)
    hits   = rand(2..4)
    hits.times do
      dmg = [(actor.atk - target.defense) * @damage_mult, 1].max.round
      target.hp -= dmg
    end
    puts "Feral instinct — #{hits} hits!"
  end

  def echo_pack_memory(actor, roster)
    roster.each { |c| c.hp = [c.hp + 6, c.max_hp].min if c.is_a?(PartyMember) }
    puts "The memory of running together — party heals 6 HP."
  end

  def echo_divine_ward(actor, roster)
    roster.each { |c| c.status_effects[:warded] = true if c.is_a?(PartyMember) }
    puts "A divine ward absorbs the next hit for all allies."
  end

  def echo_unmake(actor, enemies)
    target = choose_enemy(enemies)
    dmg = (rand(18..28) * @damage_mult).round
    target.hp -= dmg
    actor.hp  -= 6
    puts "#{actor.name} unmakes part of #{target.name} — #{dmg} damage, 6 backlash."
  end

  def echo_stone_shout(enemies)
    enemies.each { |e| e.speed = 0 }
    puts "The stone shouts. All enemies lose their speed."
  end

  def echo_column_crush(actor, enemies)
    target = choose_enemy(enemies)
    dmg = (rand(20..30) * @damage_mult).round
    target.hp -= dmg
    puts "A column of marble falls — #{dmg} damage!"
  end

  def echo_titan_slam(actor, enemies)
    target = choose_enemy(enemies)
    dmg = (rand(22..34) * @damage_mult).round
    target.hp -= dmg
    puts "The force of a Titan's memory — #{dmg} damage!"
  end

  def echo_earth_split(actor, enemies)
    enemies.each do |e|
      dmg = (rand(7..12) * @damage_mult).round
      e.hp -= dmg
    end
    puts "The earth splits. All enemies take damage."
  end

  def echo_song_stun(enemies)
    target = choose_enemy(enemies)
    target.speed = 0
    puts "A song that has never been heard before. #{target.name} freezes."
  end

  def echo_myth_weave(actor)
    heal = rand(8..14) + (@player.fang_level * 2)
    actor.hp = [actor.hp + heal, actor.max_hp].min
    puts "The myth weaves itself closed. +#{heal} HP."
  end

  def echo_survive(actor)
    if actor.hp < (actor.max_hp * 0.20)
      heal = (actor.max_hp * 0.30).round
      actor.hp = [actor.hp + heal, actor.max_hp].min
      puts "The echo refuses to end. +#{heal} HP."
    else
      puts "Not desperate enough yet."
    end
  end

  def echo_endure(actor)
    actor.status_effects[:endure_next] = true
    puts "#{actor.name} braces. The next hit will be halved."
  end

  # Limit breaks
  def use_limit_break(actor, enemies, roster)
    case actor.limit_name
    when "Fang Ascendant"
      puts "\nThe Fang reaches full brightness. Reality flinches."
      enemies.each do |e|
        dmg = (rand(25..40) * @damage_mult * @player.fang_level).round
        e.hp -= dmg
        puts "#{e.name} takes #{dmg}!"
      end
    when "Prey-Sight"
      puts "\nKira sees every weakness at once."
      enemies.each do |e|
        dmg = (rand(15..22) * @damage_mult).round
        e.hp -= dmg
        e.defense -= 2
        puts "#{e.name} takes #{dmg}, DEF -2."
      end
    when "The First Song"
      puts "\nTheo sings a song that has never existed before."
      puts "The enemies don't know how to react to something that has no precedent."
      enemies.each { |e| e.speed = 0; e.atk = [e.atk - 4, 0].max }
      puts "All enemies stunned and weakened."
    when "Oracle's Collapse"
      target = choose_enemy(enemies)
      dmg = (target.max_hp * 0.50 * @damage_mult).round
      target.hp -= dmg
      puts "\nMira collapses the enemy's future — #{dmg} damage (50% of max HP)."
    else
      puts "The limit surges but finds no form."
    end
  end

  def conclude_battle(enemies, roster)
    puts "\nThe enemies dissolve back into the myth they came from."
    gain = rand(8..18)
    @player.iron_slivers += gain
    puts "You gather #{gain} iron slivers."

    @player.kills += enemies.size

    player_actor = roster.find { |c| c.is_a?(PartyMember) && c.id == :player }
    @player.hp = [player_actor.hp, @player.max_hp].min if player_actor

    # Echo XP
    if @player.equipped_echo
      xp = rand(4..9)
      @player.equipped_echo.xp += xp
      puts "Echo #{@player.equipped_echo.name} gains #{xp} XP."
      level_up_echo(@player.equipped_echo)
    end

    # Fragment drop
    if rand < 0.22
      @player.echo_fragments += 1
      puts "An echo fragment falls from the defeated form. (#{@player.echo_fragments}/5)"
      forge_echo_from_fragments if @player.echo_fragments >= 5
    end

    @player.fracture = [@player.fracture - 10, 0].max
  end

  def level_up_echo(echo)
    needed = echo.level * 10
    while echo.xp >= needed
      echo.xp    -= needed
      echo.level += 1
      puts "Echo #{echo.name} reaches level #{echo.level}!"
      echo.stats[:hp]  += 2
      echo.stats[:atk] += 1
      echo.stats[:def] += 1
      echo.stats[:spd] += 1
      needed = echo.level * 10
    end
  end

  # =========================
  # HADES BATTLE
  # =========================

  def start_hades_battle
    clear
    puts <<~TXT

    The chamber is vast and wrong.
    The walls breathe.
    The air has weight.

    A figure stands at the centre — half-formed, flickering,
    still deciding what shape a god should take.

    He looks at you.
    At the Fang.

    "You were not meant to find me."

    He pauses.

    "But you came anyway."

    THE INCOMPLETE GOD — HADES — FIRST DEATH — UNWRITTEN RULER
    TXT

    # Echo-aware dialogue
    if @player.equipped_echo
      e = @player.equipped_echo
      case e.arcana
      when :chthonic then puts "\"That Echo,\" he says. \"It smells like here. Like me. Interesting.\""
      when :solar    then puts "\"You brought sunlight into a place that hasn't invented dark yet. Bold.\""
      when :feral    then puts "\"A hunter. Good. I was hoping for someone who understood endings.\""
      when :divine   then puts "\"Another unfinished god,\" he says. \"We are a matched set.\""
      when :unformed then puts "\"We are the same,\" he says softly. \"Neither of us is finished.\""
      end
    end

    sleep 1

    hades = Enemy.new(
      name:    "The Incomplete God",
      hp:      400,
      atk:     13,
      defense: 7,
      speed:   BASE_SPEED[:boss],
      desc:    "A being that is still becoming. More dangerous for it.",
      tags:    [:divine, :boss, :chthonic]
    )

    hades_battle_loop([hades])
  end

  def hades_battle_loop(enemies)
    roster = build_combat_roster(enemies)
    atb    = {}
    phase  = 1
    roster.each { |c| atb[c] = 0 }

    until enemies.none?(&:alive?)
      check_limit_breaks(roster)
      show_combat_status(roster, enemies)

      roster.select(&:alive?).each { |c| atb[c] += c.speed }
      actor = roster.find { |c| c.alive? && atb[c] >= 100 }

      if actor
        atb[actor] = 0
        actor.is_a?(Enemy) ? hades_turn(actor, roster, phase) : player_combat_turn(actor, enemies, roster)
      end

      hades = enemies.first
      if hades.hp < 250 && phase == 1
        phase = 2
        puts "\nHades flickers. His form solidifies — then breaks apart again."
        puts "\"This is what I am,\" he says. \"Not finished. Not stopped.\""
        @player.fracture = [@player.fracture + 15, 100].min
      end

      if hades.hp < 100 && phase == 2
        phase = 3
        puts "\nHades falls to one knee. The chamber trembles."
        puts "\"If you do this,\" he says, \"the world will not recover.\""
        puts "\"I know,\" he says. \"I can see it from here.\""
        @player.fang_level = 4
        puts "The Fang reaches its final form. (Fang Lv 4)"
      end
    end

    conclude_hades_battle
  end

  def hades_turn(enemy, roster, phase)
    target = roster.select { |c| c.alive? && c.is_a?(PartyMember) }.sample
    return unless target

    # Check dodge/endure status effects
    if target.status_effects[:dodge_next]
      target.status_effects.delete(:dodge_next)
      puts "#{target.name} steps aside. The attack passes through nothing."
      return
    end

    case phase
    when 1
      dmg = (rand(9..14) * @damage_mult).round
      if target.status_effects[:warded]
        target.status_effects.delete(:warded)
        puts "Hades reaches forward — the ward absorbs it."
      else
        if target.status_effects[:endure_next]
          dmg = (dmg * 0.5).round
          target.status_effects.delete(:endure_next)
        end
        target.hp -= dmg
        puts "Hades reaches forward. #{target.name} takes #{dmg}."
      end
    when 2
      puts "Hades rewrites the battlefield. The party stumbles."
      roster.each { |c| c.speed = [c.speed - 2, 1].max if c.is_a?(PartyMember) }
      @player.fracture = [@player.fracture + 8, 100].min
    when 3
      dmg = (rand(14..20) * @damage_mult).round
      if target.status_effects[:endure_next]
        dmg = (dmg * 0.5).round
        target.status_effects.delete(:endure_next)
      end
      target.hp -= dmg
      puts "\"I'm sorry,\" Hades says. #{target.name} takes #{dmg}."
    end

    puts "#{target.name} collapses." if target.hp <= 0
  end

  def conclude_hades_battle
    @hades_defeated = true
    @player.fracture = [@player.fracture + 20, 100].min

    puts "\nHades falls."
    puts "Not with a crash. With a sigh."
    puts "\"I wasn't finished,\" he says."
    puts "\"Neither was the world.\""
    puts "\nThe chamber begins to collapse."
    sleep 1
    trigger_ending
  end

  # =========================
  # ENDING
  # =========================

  def trigger_ending
    clear
    puts <<~END_TEXT

    You killed a god.

    The first god.
    In a world that hadn't invented death yet.

    The underworld collapses inward.
    The proto-spirits dissolve.
    The half-written myths come apart at the seams.

    You climb.

    The cavern shakes behind you.
    Your party climbs with you.
    None of you speak.

    You reach the surface.

    The sun is still too loud.
    The marble is still too bright.
    But something is different now.

    A crack runs through the sky.

    The world above you is ending.
    Not because you were wrong.
    Because you were first.

    END_TEXT

    sleep 1

    puts "#{@player.name} — first bearer of the Fang."
    puts "First creature to end something that was still becoming."
    puts "First death in a world that didn't know what dying was."
    puts ""
    puts "The ambush comes from below."
    puts "Demons. Drafts of what will later fill the Library."
    puts "The world's immune response to an error it can't correct."
    puts ""
    puts "You fight."
    puts ""

    sleep 1

    puts "You fight for #{@player.kills + rand(20..40)} more."
    puts "Then there are too many."
    puts ""

    sleep 1

    # Companion endings
    unless @player.party.empty?
      puts "Your companions:"
      @player.party.each do |c|
        case c.id
        when :scout
          puts "  Kira runs. She survives. She never speaks of the descent."
        when :bard
          puts "  Theo writes it all down. The tablet survives him by a thousand years."
          puts "  No one will be able to read it. The language dies with the world."
        when :seer
          puts "  Mira sits down. She already saw this."
          puts "  \"It's fine,\" she says. \"This part is supposed to happen.\""
        end
      end
      puts ""
      sleep 1
    end

    puts "#{@player.name} falls in the sunlight."
    puts "The first true death."
    puts "In a world that is already dying around it."
    puts ""
    sleep 1

    puts "Then:"
    puts ""
    sleep 1

    puts "The Ink-Scared Pup tears itself free."
    puts ""
    puts "It doesn't look back."
    puts ""
    puts "It runs."
    puts ""
    sleep 1

    puts "Across the collapsing world."
    puts "Across the centuries."
    puts "Across the gap between a myth and a library."
    puts ""
    puts "Until it finds someone who needs it."
    puts ""
    sleep 1

    puts "=" * 55
    puts ""
    puts "  #{@player.name.upcase}"
    puts "  THE FIRST BEARER"
    puts "  THE FIRST DEATH"
    puts "  THE ONE WHO MADE THE FANG MEAN SOMETHING"
    puts ""
    puts "=" * 55
    puts ""
    sleep 1

    puts "\n=== THANK YOU FOR PLAYING DARK FLOOF III ==="
    puts "The place that didn't take."
    puts ""

    sleep 1

    puts <<~TEASE

    Somewhere in the wreckage of the first world,
    a tablet survives.

    Theo's notes.
    Illegible.
    But real.

    Three thousand years later,
    beneath a hospital,
    beneath a Library,
    something finds it.

    It can't read the words.
    But it recognizes the smell.

    Ink.
    Old ink.
    The oldest ink.

    It picks up the tablet.

    The Fang hums.

    DARK FLOOF: THE COMPLETE TRILOGY
    Coming when it's ready.

    TEASE

    @running = false
  end

  # =========================
  # SAVE / LOAD
  # =========================

  def save_game
    data = {
      player: {
        name:           @player.name,
        hp:             @player.hp,
        max_hp:         @player.max_hp,
        atk:            @player.atk,
        defense:        @player.defense,
        speed:          @player.speed,
        iron_slivers:   @player.iron_slivers,
        dispellers:     @player.dispellers,
        inventory:      @player.inventory,
        fracture:       @player.fracture,
        has_fang:       @player.has_fang,
        fang_level:     @player.fang_level,
        depth:          @player.depth,
        zone:           @player.zone,
        echo_fragments: @player.echo_fragments,
        kills:          @player.kills,
        echoes:         serialize_echoes,
        equipped_echo:  @player.equipped_echo&.name
      },
      rooms:          serialize_rooms,
      player_room:    @player.room.id,
      depth:          @depth,
      hades_defeated: @hades_defeated,
      companions_met: @companions_met,
      difficulty:     @difficulty,
      encounter_rate: @encounter_rate,
      damage_mult:    @damage_mult
    }
    File.write("dark_floof_3_save.json", JSON.pretty_generate(data))
    puts "Saved."
  end

  def load_game
    unless File.exist?("dark_floof_3_save.json")
      puts "No save file found."
      return
    end

    data = JSON.parse(File.read("dark_floof_3_save.json"))
    p    = data["player"]

    @player                = Player.new(p["name"])
    @player.hp             = p["hp"]
    @player.max_hp         = p["max_hp"]
    @player.atk            = p["atk"]
    @player.defense        = p["defense"]
    @player.speed          = p["speed"]
    @player.iron_slivers   = p["iron_slivers"]
    @player.dispellers     = p["dispellers"]
    @player.inventory      = p["inventory"]
    @player.fracture       = p["fracture"]
    @player.has_fang       = p["has_fang"]
    @player.fang_level     = p["fang_level"]
    @player.depth          = p["depth"]
    @player.zone           = p["zone"].to_sym
    @player.echo_fragments = p["echo_fragments"]
    @player.kills          = p["kills"]

    @depth          = data["depth"]
    @hades_defeated = data["hades_defeated"]
    @companions_met = data["companions_met"].transform_keys(&:to_sym)
    @difficulty     = data["difficulty"].to_sym
    @encounter_rate = data["encounter_rate"]
    @damage_mult    = data["damage_mult"]

    load_rooms(data["rooms"])
    @player.room = @rooms.values.find { |r| r.id == data["player_room"] }

    load_echoes(p["echoes"] || {})
    @player.equipped_echo = @player.echoes[p["equipped_echo"]] if p["equipped_echo"]

    # Restore party based on companions_met
    @player.party = []
    @companions_met.each do |id, met|
      next unless met
      case id
      when :scout then restore_companion_scout
      when :bard  then restore_companion_bard
      when :seer  then restore_companion_seer
      end
    end

    puts "Loaded."
    main_loop
  end

  def restore_companion_scout
    @player.party << PartyMember.new(
      id: :scout, name: "Kira the Scout", role: :dps,
      hp: 32, atk: 9, defense: 3, speed: BASE_SPEED[:companion_scout],
      skills: [:swift_strike, :track_weakness],
      limit_name: "Prey-Sight",
      limit_desc: "Kira strikes every enemy in sequence for escalating damage."
    )
  end

  def restore_companion_bard
    @player.party << PartyMember.new(
      id: :bard, name: "Theo the Bard", role: :support,
      hp: 28, atk: 6, defense: 4, speed: BASE_SPEED[:companion_bard],
      skills: [:hymn_of_stone, :discord_shout],
      limit_name: "The First Song",
      limit_desc: "A song that has never been heard before. Stuns all enemies."
    )
  end

  def restore_companion_seer
    @player.party << PartyMember.new(
      id: :seer, name: "Mira the Seer", role: :mage,
      hp: 26, atk: 8, defense: 3, speed: BASE_SPEED[:companion_seer],
      skills: [:fate_read, :unwrite_fate],
      limit_name: "Oracle's Collapse",
      limit_desc: "Mira sees the enemy's next move and counters it perfectly."
    )
  end

  def serialize_echoes
    out = {}
    @player.echoes.each do |name, e|
      out[name] = {
        arcana: e.arcana, level: e.level, xp: e.xp,
        stats: e.stats, skills: e.skills, passives: e.passives,
        lore_line: e.lore_line
      }
    end
    out
  end

  def load_echoes(data)
    @player.echoes = {}
    data.each do |name, e|
      echo = Echo.new(
        name:      name,
        arcana:    e["arcana"].to_sym,
        stats:     e["stats"].transform_keys(&:to_sym),
        skills:    e["skills"].map(&:to_sym),
        passives:  e["passives"].map(&:to_sym),
        lore_line: e["lore_line"] || ""
      )
      echo.level = e["level"]
      echo.xp    = e["xp"]
      @player.echoes[name] = echo
    end
  end

  def serialize_rooms
    out = {}
    @rooms.each do |key, room|
      out[key] = {
        id: room.id, name: room.name, desc: room.desc, lore: room.lore,
        visited: room.visited, zone: room.zone,
        exits: room.exits.transform_values { |r| r&.id },
        flags: room.flags,
        npc: room.npc ? { name: room.npc.name, lines: room.npc.lines } : nil,
        enemies: room.enemy_group.map do |e|
          { name: e.name, hp: e.hp, max_hp: e.max_hp, atk: e.atk,
            defense: e.defense, speed: e.speed, desc: e.desc, tags: e.tags }
        end
      }
    end
    out
  end

  def load_rooms(data)
    @rooms = {}
    data.each do |key, r|
      room = Room.new(r["name"], r["desc"], lore: r["lore"],
                      id: r["id"], zone: r["zone"]&.to_sym || :surface)
      room.visited = r["visited"]
      room.flags   = r["flags"]
      @rooms[key.to_sym] = room
    end
    data.each do |key, r|
      room = @rooms[key.to_sym]
      r["exits"].each do |dir, id|
        next unless id
        room.exits[dir] = @rooms.values.find { |rm| rm.id == id }
      end
    end
    data.each do |key, r|
      room = @rooms[key.to_sym]
      room.npc = NPC.new(r["npc"]["name"], r["npc"]["lines"]) if r["npc"]
      room.enemy_group = r["enemies"].map do |e|
        Enemy.new(name: e["name"], hp: e["hp"], atk: e["atk"],
                  defense: e["defense"], speed: e["speed"],
                  desc: e["desc"], tags: e["tags"])
      end
    end
  end

  # =========================
  # DEBUG CONSOLE
  # =========================

  def debug_console
    puts "\n=== DEBUG CONSOLE ==="
    puts "1. Test battle"
    puts "2. Teleport to Hades' chamber"
    puts "3. Add iron slivers"
    puts "4. Add dispellers"
    puts "5. Set fracture"
    puts "6. Grant random Echo"
    puts "7. Add 5 echo fragments"
    puts "8. Set zone"
    puts "9. Cancel"
    print "> "

    case gets&.strip
    when "1"
      battle([generate_enemy(@player.zone)])
    when "2"
      room = build_hades_chamber
      @player.room = room
      update_zone(:hades_domain)
      puts "Teleported to Hades' chamber."
      describe_room
      start_hades_battle unless @hades_defeated
    when "3"
      @player.iron_slivers += 100
      puts "Iron slivers: #{@player.iron_slivers}"
    when "4"
      @player.dispellers += 5
      puts "Dispellers: #{@player.dispellers}"
    when "5"
      print "Fracture value: "
      @player.fracture = gets.to_i
      puts "Fracture set."
    when "6"
      grant_random_echo(source: "debug")
    when "7"
      @player.echo_fragments += 5
      puts "Fragments: #{@player.echo_fragments}"
      forge_echo_from_fragments if @player.echo_fragments >= 5
    when "8"
      puts "1. surface  2. descent  3. underworld  4. hades_domain"
      print "> "
      z = { "1" => :surface, "2" => :descent, "3" => :underworld, "4" => :hades_domain }
      new_zone = z[gets&.strip]
      if new_zone
        update_zone(new_zone)
        puts "Zone: #{@player.zone}"
      end
    else
      puts "Console closed."
    end
  end

end

# =========================
# ENTRY POINT
# =========================

if __FILE__ == $0
  Game.new.run
end
