require "securerandom"
require "json"

# =========================
# CONSTANTS
# =========================

BASE_SPEED = {
  player:          10,
  staff:            9,
  guest:            8,
  building:         6,
  floor_boss:      11
}

FLOORS = [
  { name: "Ground Floor",    desc: "The lobby smells like a waiting room. Like the moment before bad news.",               theme: :lobby },
  { name: "Second Floor",    desc: "The carpet absorbs sound. You stop being able to hear yourself breathe.",              theme: :corridor },
  { name: "Third Floor",     desc: "The meetings here never concluded. The attendees never accepted that.",                theme: :conference },
  { name: "Fourth Floor",    desc: "The kitchen ran for nine days without staff. Something learned to cook itself.",       theme: :restaurant },
  { name: "Fifth Floor",     desc: "The water in the pool hasn't moved in a week. Neither have the things in it.",        theme: :spa },
  { name: "Sixth Floor",     desc: "The penthouse guest has been here longer than the building. The building knows this.", theme: :penthouse },
  { name: "The Roof",        desc: "You are outside. The sky is the wrong colour. Not wrong like a sunset. Wrong.",       theme: :roof }
]

ROOM_NAMES = {
  lobby:      ["The Lobby",                    "Check-In Desk",              "The Concierge's Station",
               "Coat Check",                   "The Bell Stand",              "The Vestibule",
               "The Night Audit Office",       "Lost and Found",              "The Key Cabinet"],
  corridor:   ["Room 201",                     "Room 217",                   "The Linen Closet",
               "Ice Machine Alcove",           "The Stairwell",               "Room 213",
               "The Service Corridor",         "Room 209",                    "The Laundry Chute"],
  conference: ["The Boardroom",               "Breakout Room A",             "Breakout Room B",
               "The AV Closet",               "The Catering Station",        "Conference Hall C",
               "The Green Room",              "The Projection Booth",         "Storage Room 3C"],
  restaurant: ["The Dining Room",             "The Kitchen",                 "Cold Storage",
               "The Wine Cellar",             "The Bar",                     "The Dumbwaiter Room",
               "The Pantry",                  "The Dish Room",                "The Walk-In Freezer"],
  spa:        ["The Pool",                    "Steam Room",                  "The Treatment Suite",
               "The Locker Room",             "The Sauna",                   "The Relaxation Lounge",
               "Hydrotherapy",                "The Supply Closet",            "The Utility Room"],
  penthouse:  ["The Elevator Lobby",          "Room 601",                    "The Private Dining Room",
               "Room 604",                    "The Study",                   "Room 609",
               "The Observatory Balcony",     "The Master Suite",             "The Panic Room"],
  roof:       ["The Maintenance Catwalk",     "The Water Tower",             "The Antenna Array",
               "The Rooftop Bar (Closed)",    "The Helipad",                 "The Garden (Dead)",
               "The Generator Room",          "The Edge",                    "Room 70"]
}

ROOM_DESCS = {
  lobby: [
    "The marble floor is cold. It has always been cold. Even in summer. Even before you arrived.",
    "The concierge's hands are folded on the desk. They have been folded that way for a long time. The knuckles are wrong.",
    "The guest book is open. The last entry is in handwriting that looks like yours when you're tired.",
    "The elevator doors are closed. The floor indicator says B3. The hotel doesn't have a basement.",
    "Every clock in the lobby shows a different time. None of them are moving.",
    "The revolving door hasn't stopped since you walked in. No one else has come through it.",
    "The luggage behind the concierge desk has name tags. You recognize one of the names. You shouldn't.",
    "There is a children's drawing on the welcome board. It depicts the hotel. You are in it. You are on this floor.",
    "The fire exits are propped open with things that used to be people's belongings.",
    "The carpet absorbs your footsteps completely. You stop making sound when you walk."
  ],
  corridor: [
    "The hallway is longer than the building's footprint allows. You've checked. Twice.",
    "Every door has a DO NOT DISTURB sign. Every sign is frayed in the same place, as if handled by the same hands.",
    "Something is under the carpet. It moves when you're not looking at it directly.",
    "Room 217 has a light on. It had a light on when you checked in. You were the first guest.",
    "The ice machine dispenses something. It is the right shape and the right temperature. It isn't ice.",
    "You can hear a TV through one of the doors. The show is about a person walking down a hotel corridor.",
    "The emergency exit signs are in red. The arrows point in different directions on each side of the same sign.",
    "A housekeeping cart has been left in the middle of the hall. The towels are folded into a shape that isn't decorative.",
    "The hallway smells like your childhood home. You lived in a house. There is no reason for this.",
    "One of the room numbers is skipped. Where 208 should be, there is a wall that is slightly warmer than the others."
  ],
  conference: [
    "Name placards at every seat. One of them has your name on it. The ink is dry. It was placed before you arrived.",
    "Slide 47 of 47. The presentation has been running since before there were projectors in this room.",
    "The whiteboard says AGENDA in large letters. Below it, in smaller letters: you.",
    "Coffee cups still steaming. This is the fourth day. Coffee does not stay warm for four days.",
    "The attendance sheet has been signed. Eighty-three signatures. You count them. The last one looks like yours.",
    "The chairs are all pushed in except one. The empty one faces away from the projector. Toward the door. Toward you.",
    "There is a handout on every seat. It is titled: WHAT HAPPENS NEXT. The pages are blank.",
    "The meeting scheduled for this room has no end time. The calendar entry says: ONGOING.",
    "A phone is ringing in the breakout room. When you answer it, it rings again.",
    "The catering station has food laid out for a meeting that no one has attended. The food is still fresh. It has been a week."
  ],
  restaurant: [
    "The kitchen is running. You can hear it from the corridor. You have been able to hear it since the ground floor.",
    "A table in the corner is set for two. One of the place settings is used. The other is pristine. It has been waiting.",
    "The specials board lists dishes made from ingredients that aren't on any menu you've ever seen.",
    "The walk-in freezer is humming. The things hanging inside are not meat. They are not anything you have words for.",
    "The sommelier's notebook is open on the bar. Every page is a review of the same wine. The ratings go from excellent to undrinkable over seven days. Today's entry is blank.",
    "A half-finished meal sits at the bar. The fork is still in the food. The food is still warm. It has been a week.",
    "The dish room is running. You can hear the sound of plates. There are no plates. There are no dishes. There is no water.",
    "The dumbwaiter opens. It is empty. It closes. It opens. It is not empty. It closes before you can see.",
    "The pantry door is locked from the inside. You can hear something rearranging the shelves.",
    "The bar has one drink prepared on the counter. A napkin underneath it says: complimentary. For you. By name."
  ],
  spa: [
    "The pool surface is completely flat. Water is not flat. Water has surface tension. This pool has something else.",
    "The steam room is occupied. You can see shapes through the glass. They have too many joints.",
    "The treatment schedule on the wall includes appointments for names you don't recognise. Your appointment is at 3am. Today.",
    "The sauna temperature gauge is broken. Or it reads correctly. You can't tell anymore which one is worse.",
    "The towels have been folded into shapes that are not animals. They are not decorative. They are deliberate.",
    "The music in the relaxation lounge is classical. You recognize it. It is the song that was playing when something bad happened to you. You'd forgotten what that was. You remember now.",
    "The hydrotherapy pool is drained. Something is written on the bottom. It takes you a moment to recognise your own handwriting.",
    "The locker has a name on it. The name is yours. The locker was here before you arrived.",
    "The supply closet has been opened and restocked recently. The supplies include things that are not cleaning products.",
    "The mirror in the locker room shows a reflection that is almost right. It is slightly behind. Just slightly."
  ],
  penthouse: [
    "The view is perfect. Too perfect. The city outside is arranged to be seen from exactly this angle. It is arranged for you.",
    "Room service was delivered but not touched. The receipt is addressed to your name. The order is your usual. You've never eaten here.",
    "The safe is open. It contains a key card, a photograph, and a note. The note says: you left these last time.",
    "The phone is off the hook. The voice on the line is describing what you are doing right now. In real time.",
    "The minibar has been emptied in a particular sequence. You understand the sequence. You don't know why.",
    "Room 609 has no door. Where the door should be is a wall. The wall is painted to look like a door. It is painted in your favourite colour.",
    "The master suite has a suitcase on the bed. The clothes inside are yours. The sizes are right. They are clean.",
    "The observatory balcony has marks on the railing. Handprints. Facing inward. Someone held on.",
    "The panic room is unlocked. The inside has been lived in. The calendar on the wall stops on today's date.",
    "The study has books with your name on the spines. You didn't write them. They are about you."
  ],
  roof: [
    "The city is too far down. The hotel is not tall enough for the city to look this far away.",
    "The antenna array is broadcasting. You can almost hear what it's saying. You keep not quite catching it.",
    "The helipad has a helicopter on it. The helicopter's door is open. There is luggage inside. It is your luggage.",
    "The rooftop bar is closed. The chairs are stacked. One chair is not stacked. It faces the edge.",
    "The dead garden has plants that are growing wrong. Not dying. Growing. Just wrong.",
    "The generator is running. It powers the hotel. The hotel doesn't appear to be connected to it.",
    "The water tower casts a shadow in the wrong direction. The shadow is the right shape for a person.",
    "The edge is not where it was. You measured it before you came up. It has moved closer.",
    "The maintenance catwalk goes further than the building. It ends somewhere you cannot see from here.",
    "The exit stairs are locked from the outside. Someone has written on the door: YOU WERE SO CLOSE."
  ]
}

ROOM_LORE = [
  "The guest registry lists your name 47 times across the last 30 years. The handwriting changes each time. It's always yours.",
  "A child's drawing is taped to the wall. A dog standing in a hotel corridor. The dog is holding something. You can't make out what.",
  "The housekeeping log marks your room as occupied for seven days. You checked in this morning.",
  "An amenity card lists the hotel's services: concierge, laundry, turndown, memory retention, departure assistance.",
  "The hotel was reviewed online. Every review is five stars. Every review says the same thing: I didn't want to leave.",
  "A fire safety card in the nightstand has been annotated in pen. Someone has crossed out every exit.",
  "You find a phone number written on a napkin. You don't call it. You recognise it. It's yours.",
  "The hotel's maintenance log has an entry: 'Guest in room #{rand(100..699)} has not moved in four days. Do not disturb.'",
  "A room key on the floor opens a room you haven't reached yet. The key is warm.",
  "The wallpaper has a pattern that repeats. The pattern is not decorative. It is a map. You are on it.",
  "The hotel's founding plaque reads 1962. Below the date, in smaller letters: WE WERE HERE BEFORE THAT.",
  "You find a photograph of the hotel's original staff. They are all smiling. None of them cast shadows.",
  "A noise complaint form, filled out in your handwriting, dated six days from now, describing what you are doing right now.",
  "The emergency procedures card says: in case of fracture, do not attempt to leave. The hotel will handle it.",
  "The newspaper on the welcome desk is from last week. The headline reads: LOCAL RESIDENT ADMITTED TO HOSPITAL. The name is yours.",
  "A note under your door: 'We noticed you've been trying to reach floor 7. We've extended your reservation.'",
  "The room service menu has a section called FINAL ORDERS. It is not a joke. The items are your favourite foods.",
  "You find a diary. The handwriting deteriorates across its pages, becoming something else. The last entry is today.",
  "A mirror in the stairwell reflects you on a different floor. You watch yourself walk past. You are not on that floor.",
  "The hotel's checkout form asks: what would you like to forget? The field is pre-filled."
]

FLOOR_BOSS_NAMES = [
  "The Head Concierge",
  "The Night Manager",
  "The Banquet Director",
  "The Executive Chef",
  "The Spa Director",
  "The Penthouse Guest",
  "The Hotel Itself"
]

FLOOR_BOSS_DESCS = [
  "It has been standing at that desk since before you were born. It was standing there when your parents were born. It was standing there when the concept of hotels was invented. It is still smiling.",
  "It works the overnight shift. It has always worked the overnight shift. There are no day shifts. There have never been day shifts. Something else worked those. It doesn't anymore.",
  "It organised an event for every person who has stayed in this hotel. They are all still here. They are all in this room. You can't see them because they have learned to be very still.",
  "It has been cooking the same thing for nine days. The smell has changed four times. The fourth smell is the one that doesn't have a name. That's the one that reaches you from the floor below.",
  "It offers treatments for conditions that don't have medical names. Your chart is already prepared. It has been prepared for a long time. Your presenting symptoms are listed in a language the hotel made up.",
  "It checked in without luggage, without a name, without a checkout date. The room it occupies used to be smaller. The room has expanded around it. The hotel gave it room to grow.",
  "The building became aware sometime around the fourth decade. It didn't announce this. It simply began to want. This is the accumulated result of forty years of wanting. This is what it looks like."
]

FLOOR_BOSS_LINES = [
  [
    "We put your name on the reservation before you knew you were coming.",
    "The smile is genuine. I want you to know that. It has always been genuine.",
    "Guests worry about checking out. They forget they chose to check in.",
    "Your key card was cut three years before you arrived. We had faith.",
    "You look tired. The hotel noticed. The hotel notices everything."
  ],
  [
    "Check-out is at eleven. You've missed eleven. You've missed eleven every day this week.",
    "The previous guest tried the same thing. They're on the fourth floor now. In the carpet.",
    "I don't sleep. Neither do you, this week. We have that in common.",
    "The hotel has a loyalty programme. You've been enrolled since birth.",
    "You're not the first person to come this far. You're one of four. The others are still here, technically."
  ],
  [
    "Your name has been on the agenda for some time.",
    "The meeting's purpose is you. The outcome has already been agreed.",
    "We've circulated your file. Everyone in this room has read it. Everyone in this room is very interested in what comes next.",
    "Please take a seat. The one facing away from the projector. It was left for you.",
    "We take minutes. We've been taking minutes on you for years. Would you like to see them?"
  ],
  [
    "The dish I'm preparing takes nine days. You arrived on day one.",
    "Every guest who reaches this floor becomes an ingredient eventually.",
    "The menu changes based on who comes through. Tonight it is very specifically you.",
    "I've been cooking a long time. I know what things are before they know what they are.",
    "Dinner is served. You are dinner. These are not separate events."
  ],
  [
    "Your appointment was made before you arrived. Before you existed, technically.",
    "The treatment is for what you carry. Not the physical things. The other things.",
    "Relax. The word relax means something different here. Here it means stop.",
    "Every guest leaves lighter. They leave things behind. You have quite a lot to leave.",
    "We treat what hospitals don't know how to name yet. You'll understand shortly."
  ],
  [
    "I checked in looking for something I'd lost. I'm still looking. The looking became me.",
    "You and I are the same thing at different points in the same process.",
    "I don't remember my name. The hotel gave me a new one. The hotel will give you one too.",
    "I had a life before this room. I remember that I had one. I don't remember what it was.",
    "Stay. I mean it as a kindness. Outside is not what it was when you arrived."
  ],
  [
    "You are the seven thousandth guest. We've been waiting for you specifically.",
    "The building remembers everyone who has passed through it. You will be remembered differently.",
    "I am not the staff. I am not the guests. I am the accumulation of every night that has ever happened here.",
    "You cannot damage me. You can only convince me. I am not convincible.",
    "The exit is real. You can reach it. I want you to know that. I want you to know what you'll be when you do."
  ]
]

ENEMY_POOL = {
  lobby: [
    { name: "The Concierge",        hp: [14,22], atk: [5,8],  def: [2,4], desc: "It has been smiling since before you arrived. The smile has not reached its eyes because it does not have eyes. It has something that functions similarly." },
    { name: "The Bellhop",          hp: [12,18], atk: [4,7],  def: [1,3], desc: "It carries luggage that doesn't exist. The weight of it is real. You can hear it." },
    { name: "The Revolving Door",   hp: [18,26], atk: [6,9],  def: [3,5], desc: "It has been turning since you walked in. It will still be turning when you're gone. It will still be turning after that." },
    { name: "The Night Auditor",    hp: [16,24], atk: [5,8],  def: [2,4], desc: "It balances accounts that don't add up. It has been balancing them for nine days. They still don't add up. It doesn't stop." }
  ],
  corridor: [
    { name: "The Housekeeper",      hp: [14,20], atk: [5,8],  def: [2,3], desc: "Cleaning a stain that predates the carpet. Cleaning it with something that isn't a cloth. Not stopping." },
    { name: "Room 217",             hp: [20,28], atk: [7,10], def: [3,5], desc: "The room learned to move. It moves when there's somewhere it needs to be. Right now it needs to be here." },
    { name: "The DO NOT DISTURB",   hp: [10,16], atk: [4,6],  def: [1,2], desc: "A concept that refused to remain conceptual. It does not want to be looked at. Looking at it is the wrong choice." },
    { name: "The Ice Machine",      hp: [16,22], atk: [5,8],  def: [4,6], desc: "Running without stopping for nine days. What it produces is cold and wrong-shaped and it keeps producing it." }
  ],
  conference: [
    { name: "The Presenter",        hp: [16,24], atk: [6,9],  def: [2,4], desc: "Slide 47. It has been slide 47 for four days. The slide is about you. The slide has always been about you." },
    { name: "The Attendee",         hp: [12,18], atk: [4,7],  def: [1,3], desc: "It has questions. Every answer generates more questions. It will not stop having questions. It is getting closer." },
    { name: "The Agenda",           hp: [14,20], atk: [5,8],  def: [2,4], desc: "Itemised. All items relate to you. All items are scheduled. You are behind schedule." },
    { name: "The AV System",        hp: [18,26], atk: [7,10], def: [3,5], desc: "Broadcasting something on a loop. Not audio. Not video. Something else. It has been broadcasting it since before this building had electricity." }
  ],
  restaurant: [
    { name: "The Sous Chef",        hp: [18,26], atk: [7,10], def: [3,4], desc: "Still at the stove. Won't leave. Has been at the stove for nine days. The dish isn't finished. The dish will never be finished. The chef doesn't know this yet." },
    { name: "The Sommelier",        hp: [14,20], atk: [5,8],  def: [2,4], desc: "It recommends something that isn't in a bottle. It describes the notes: grief, copper, the smell of a room you grew up in." },
    { name: "The Dumbwaiter",       hp: [12,18], atk: [4,7],  def: [3,5], desc: "It goes up. What comes down is wrong. Not damaged. Just wrong. It goes up again immediately." },
    { name: "The Walk-In Freezer",  hp: [22,30], atk: [6,9],  def: [5,7], desc: "Cold in ways that have nothing to do with temperature. You feel it before you open it. You feel it now and you haven't opened it." }
  ],
  spa: [
    { name: "The Massage Table",    hp: [14,20], atk: [4,7],  def: [4,6], desc: "The table holds. That is what tables do. This table holds with intent. This table has been holding things for a long time and does not want to stop." },
    { name: "The Pool",             hp: [20,28], atk: [6,9],  def: [3,5], desc: "The surface hasn't moved in six days. Water moves. This isn't water anymore. It has the same molecular structure. It has made a different decision." },
    { name: "The Towel Arrangement",hp: [10,16], atk: [5,8],  def: [1,3], desc: "Folded into a shape that isn't decorative. The shape means something. You almost recognise it. You'd be better off not recognising it." },
    { name: "The Sauna",            hp: [18,26], atk: [8,11], def: [2,4], desc: "Temperature: 180°. Temperature: 200°. Temperature: a number that appears on no gauge made by humans." }
  ],
  penthouse: [
    { name: "The Room Service",     hp: [16,24], atk: [6,9],  def: [2,4], desc: "Delivered. Waiting. It has been waiting. It will wait for as long as required. It knows how long that is." },
    { name: "The Safe",             hp: [20,28], atk: [7,10], def: [5,7], desc: "Open. Full of key cards. Each one opens a room you haven't reached. Each one is warm." },
    { name: "The View",             hp: [14,20], atk: [5,8],  def: [2,3], desc: "Attractive. Wrong. It looks back. It has been looking back since before you came upstairs." },
    { name: "The Penthouse Guest",  hp: [22,30], atk: [8,12], def: [3,5], desc: "Checked in. No checkout date. No luggage. No name. Room 609 has expanded to accommodate it. The hotel approved this." }
  ],
  roof: [
    { name: "The Sign",             hp: [18,26], atk: [6,9],  def: [3,5], desc: "The letters rearrange when you're not watching. You've been watching. They rearrange anyway. The new arrangement spells your name." },
    { name: "The Wind",             hp: [12,18], atk: [7,10], def: [1,3], desc: "Blows in one direction. Always the same direction. Toward the edge. Patient." },
    { name: "The Dead Garden",      hp: [16,22], atk: [5,8],  def: [4,6], desc: "Nothing alive here. Except the growing. The plants are growing wrong. Not toward light. Toward you." },
    { name: "The Edge",             hp: [20,28], atk: [9,13], def: [2,4], desc: "It was further away earlier. You measured. It has moved. It moves toward you when you look away. You cannot stop looking away forever." }
  ]
}

# =========================
# STRUCTS
# =========================

class Room
  attr_accessor :number, :name, :desc, :lore,
                :floor, :theme, :visited,
                :enemy, :npc, :flags,
                :is_boss_room

  def initialize(number:, name:, desc:, lore: nil, floor:, theme:, is_boss_room: false)
    @number       = number
    @name         = name
    @desc         = desc
    @lore         = lore
    @floor        = floor
    @theme        = theme
    @visited      = false
    @enemy        = nil
    @npc          = nil
    @flags        = {}
    @is_boss_room = is_boss_room
  end
end

class Enemy
  attr_accessor :name, :hp, :max_hp, :atk, :defense, :speed, :desc, :is_boss

  def initialize(name:, hp:, atk:, defense:, speed:, desc:, is_boss: false)
    @name    = name
    @hp      = hp
    @max_hp  = hp
    @atk     = atk
    @defense = defense
    @speed   = speed
    @desc    = desc
    @is_boss = is_boss
  end

  def alive?
    @hp > 0
  end
end

class Player
  attr_accessor :name, :hp, :max_hp, :atk, :defense, :speed,
                :scraps, :inventory,
                :status_effects, :fracture,
                :current_room, :rooms_cleared,
                :equipped_gun, :shells

  def initialize(name)
    @name    = name
    @max_hp  = 45
    @hp      = @max_hp
    @atk     = 9
    @defense = 4
    @speed   = BASE_SPEED[:player]

    @scraps         = 80
    @inventory      = { bandage: 3, room_service: 0, master_key: 0 }
    @status_effects = {}
    @fracture       = 0

    @current_room  = 0
    @rooms_cleared = 0

    @equipped_gun = nil
    @shells       = 0
  end

  def alive?
    @hp > 0
  end
end

# =========================
# GUN
# =========================

class Gun
  attr_accessor :name, :desc, :dmg_min, :dmg_max, :shells_per_shot, :effect

  def initialize(name:, desc:, dmg_min:, dmg_max:, shells_per_shot:, effect: nil)
    @name            = name
    @desc            = desc
    @dmg_min         = dmg_min
    @dmg_max         = dmg_max
    @shells_per_shot = shells_per_shot
    @effect          = effect
  end
end

HOTEL_GUNS = [
  Gun.new(
    name:            "Desk Clerk's Pistol",
    desc:            "Found in the lost and found. Someone checked in with it and forgot it was theirs.",
    dmg_min:         8,
    dmg_max:         14,
    shells_per_shot: 1,
    effect:          nil
  ),
  Gun.new(
    name:            "Security Rifle",
    desc:            "The hotel security team used these. The team is gone. The rifles stayed.",
    dmg_min:         16,
    dmg_max:         26,
    shells_per_shot: 2,
    effect:          :suppress
  ),
  Gun.new(
    name:            "Panic Room Shotgun",
    desc:            "Bolted inside the panic room on floor six. Someone unbolted it and left it in the hall.",
    dmg_min:         12,
    dmg_max:         20,
    shells_per_shot: 3,
    effect:          :aoe
  )
]

# =========================
# GAME
# =========================

class Game
  def initialize
    @player  = nil
    @rooms   = []
    @running = true

    @difficulty     = :normal
    @damage_mult    = 1.0
    @fracture_mult  = 1.0
    @encounter_rate = 0.75
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

  # =========================
  # CONTENT WARNING
  # =========================

  def content_warning
    clear
    puts "=" * 60
    puts "  CONTENT WARNING"
    puts "=" * 60
    puts ""
    puts "  Dark Floof IV contains themes that some players"
    puts "  may find distressing, including:"
    puts ""
    puts "   - Psychological horror and uncanny environments"
    puts "   - Hospitalization, trauma, and its causes"
    puts "   - A protagonist in the process of breaking down"
    puts "   - Violence and inescapable situations"
    puts "   - Themes of entrapment and loss of control"
    puts ""
    puts "  This game is a prequel to a hospitalization."
    puts "  The protagonist does not come out of this well."
    puts "  That is the point."
    puts ""
    puts "  If you are in a difficult place right now, please"
    puts "  reach out to someone who can help."
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
      puts "\n  Take care of yourself."
      sleep 5
	exit
    end
  end

  # =========================
  # TITLE SCREEN
  # =========================

  def title_screen
    clear
    puts <<~ART

    ██████╗ ███████╗    ██╗  ██╗
    ██╔══██╗██╔════╝    ██║  ██║
    ██║  ██║█████╗      ███████║
    ██║  ██║██╔══╝      ╚════██║
    ██████╔╝██║              ██║
    ╚═════╝ ╚═╝              ╚═╝

    D A R K   F L O O F   I V
    THE OVERNIGHT

    ART

    puts "One week before the hospital."
    puts "70 rooms."
    puts "Everything in the hotel wants you to stay.\n\n"

    puts "1. Check In"
    puts "2. About"
    puts "3. Load"
    puts "4. Difficulty"
    puts "5. Check Out (Quit)"
    print "> "

    case gets&.strip
    when "1" then check_in
    when "2" then show_about; title_screen
    when "3" then load_game
    when "4" then choose_difficulty; title_screen
    else @running = false
    end
  end

  def show_about
    clear
    puts "You needed somewhere to stay."
    puts "The hotel had availability."
    puts "It always has availability.\n\n"
    puts "Seven floors. Ten rooms each."
    puts "The staff are helpful. The guests are persistent."
    puts "The building has opinions.\n\n"
    puts "You need to reach room 70."
    puts "You need to get out."
    puts "The hotel has other plans.\n\n"
    puts "This is the week that explains everything that comes after."
    puts "\n(Press Enter.)"
    gets
  end

  def choose_difficulty
    clear
    puts "Difficulty:"
    puts "1. Gentle  — lighter enemies, slower fracture	FOR BABEIES"
    puts "2. Normal"
    puts "3. Cruel   — full staff, fast fracture, hard hits"
    print "> "

    case gets&.strip
    when "1"
      @difficulty     = :gentle
      @encounter_rate = 0.50
      @damage_mult    = 0.75
      @fracture_mult  = 0.6
    when "3"
      @difficulty     = :cruel
      @encounter_rate = 0.90
      @damage_mult    = 1.3
      @fracture_mult  = 1.4
    else
      @difficulty     = :normal
      @encounter_rate = 0.75
      @damage_mult    = 1.0
      @fracture_mult  = 1.0
    end
    puts "Difficulty: #{@difficulty.to_s.capitalize}. (Press Enter.)"
    gets
  end

  # =========================
  # CHECK IN
  # =========================

  def check_in
    clear
    puts "The concierge looks up."
    puts "\"Name?\""
    print "> "
    name = gets&.strip
    name = "Guest" if name.nil? || name.empty?

    @player = Player.new(name)
    build_hotel
    puts "\n\"Room 101,\" the concierge says."
    puts "\"Enjoy your stay, #{@player.name}.\""
    puts "\"We hope you find what you're looking for.\""
    puts "\n(The smile doesn't reach its eyes. It doesn't have eyes, exactly.)"
    puts "\n(Press Enter to enter the hotel.)"
    gets
    main_loop
  end

  # =========================
  # BUILD HOTEL (70 rooms)
  # =========================

  def build_hotel
    @rooms = []
    room_num = 1

    FLOORS.each_with_index do |floor_data, floor_idx|
      theme    = floor_data[:theme]
      names    = ROOM_NAMES[theme].dup
      descs    = ROOM_DESCS[theme].dup

      10.times do |room_in_floor|
        is_boss = (room_in_floor == 9)
        n    = names[room_in_floor] || "#{floor_data[:name]} Room #{room_in_floor + 1}"
        d    = is_boss ? floor_data[:desc] : descs.sample
        lore = rand < 0.5 ? ROOM_LORE.sample : nil

        room = Room.new(
          number:       room_num,
          name:         is_boss ? FLOOR_BOSS_NAMES[floor_idx] + "'s Domain" : n,
          desc:         d,
          lore:         lore,
          floor:        floor_idx + 1,
          theme:        theme,
          is_boss_room: is_boss
        )

        # Populate enemy
        if is_boss
          room.enemy = generate_floor_boss(floor_idx)
        elsif rand < @encounter_rate
          room.enemy = generate_enemy(theme)
        end

        @rooms << room
        room_num += 1
      end
    end
  end

  def generate_enemy(theme)
    pool = ENEMY_POOL[theme] || ENEMY_POOL[:lobby]
    e = pool.sample
    Enemy.new(
      name:    e[:name],
      hp:      rand(e[:hp][0]..e[:hp][1]),
      atk:     rand(e[:atk][0]..e[:atk][1]),
      defense: rand(e[:def][0]..e[:def][1]),
      speed:   BASE_SPEED[:staff],
      desc:    e[:desc]
    )
  end

  def generate_floor_boss(floor_idx)
    hp_scale  = 30 + (floor_idx * 15)
    atk_scale = 10 + (floor_idx * 2)
    Enemy.new(
      name:    FLOOR_BOSS_NAMES[floor_idx],
      hp:      hp_scale + rand(10..20),
      atk:     atk_scale + rand(2..5),
      defense: 5 + floor_idx,
      speed:   BASE_SPEED[:floor_boss],
      desc:    FLOOR_BOSS_DESCS[floor_idx],
      is_boss: true
    )
  end

  # =========================
  # MAIN LOOP
  # =========================

  def main_loop
    show_status
    describe_room

    while @running && @player.alive? && @player.current_room < 70
      print "\n> "
      cmd = gets&.strip&.downcase
      handle_command(cmd)
      break unless @running && @player.alive? && @player.current_room < 70
      show_status
      describe_room
    end

    if @player.current_room >= 70 && @player.alive?
      checkout_ending
    elsif !@player.alive?
      death_screen
    end
  end

  def current_room
    @rooms[@player.current_room]
  end

  def show_status(verbose = false)
    r = current_room
    floor_num  = r ? r.floor : "?"
    floor_name = r ? FLOORS[r.floor - 1][:name] : "?"
    puts "\n[#{@player.name} | #{floor_name} | Room #{@player.current_room + 1}/70]"
    puts "HP: #{@player.hp}/#{@player.max_hp} | Scraps: #{@player.scraps}"
    puts "Fracture: #{@player.fracture}/100"
    puts "Bandages: #{@player.inventory[:bandage]} | Room Service: #{@player.inventory[:room_service]}"
    if @player.equipped_gun
      puts "Gun: #{@player.equipped_gun.name} | Shells: #{@player.shells}"
    else
      puts "Gun: None | Shells: #{@player.shells}"
    end
  end

  def describe_room(force_lore = false)
    r = current_room
    return unless r

    floor_name = FLOORS[r.floor - 1][:name]
    puts "\n[#{floor_name} — Room #{r.number}]"
    puts r.is_boss_room ? "=== #{r.name} ===" : r.name
    puts r.desc
    puts r.lore if (force_lore || !r.visited) && r.lore
    r.visited = true

    fracture_desc

    if r.is_boss_room && r.enemy&.alive?
      puts "\n#{r.enemy.name} is here."
      puts "\"#{FLOOR_BOSS_LINES[r.floor - 1].sample}\""
      puts "(You must defeat it to advance.)"
    elsif r.enemy&.alive?
      puts "\n#{r.enemy.name} is here. #{r.enemy.desc}"
      puts "(Type FIGHT to engage.)"
    else
      puts "\n(The room is clear. Type NEXT to advance.)"
    end

    # Auto-trigger boss combat immediately
    if r.is_boss_room && r.enemy&.alive? && !r.flags[:combat_triggered]
      r.flags[:combat_triggered] = true
      puts "\nIt doesn't let you think about it."
      fight_current_room
    elsif r.enemy&.alive? && !r.flags[:combat_triggered]
      r.flags[:combat_triggered] = true
      fight_current_room
    end
  end

  def fracture_desc
    f = @player.fracture
    case f
    when 0..14   then nil
    when 15..29  then puts "(The carpet has a smell you recognise from somewhere you haven't been.)"
    when 30..44  then puts "(A crack in the wall. It wasn't there when you entered. The crack is the exact width of a finger.)"
    when 45..59  then puts "(You catch yourself listening for your name. You keep almost hearing it.)"
    when 60..74  then puts "(The lights are the right brightness. The shadows are the wrong length.)"
    when 75..89  then puts "(You check your reflection. The reflection checks back. A half-second late.)"
    when 90..99  then puts "(The hotel is almost finished with you. You can feel it. Like a conversation winding down.)"
    end
  end

  def show_help
    puts "\n=== COMMANDS ==="
    puts "look / l     – Describe current room"
    puts "next / n     – Advance to the next room (if clear)"
    puts "fight        – Fight enemy in this room"
    puts "search       – Search the room for supplies"
    puts "status       – Full status"
    puts "gun          – Manage gun"
    puts "rest         – Rest to recover HP (costs scraps)"
    puts "save         – Save"
    puts "load         – Load"
    puts "console      – Debug"
    puts "help         – This list"
    puts "quit         – Give up"
  end

  # =========================
  # COMMANDS
  # =========================

  def handle_command(cmd)
    return unless cmd

    case cmd
    when "look", "l"
      describe_room(true)
    when "next", "forward", "advance"
      advance_room
    when "n"
      # 'n' means next here, not north
      advance_room
    when "fight", "attack", "battle"
      fight_current_room
    when "search"
      search_room
    when "status"
      show_status(true)
    when "gun"
      gun_menu
    when "rest"
      rest
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
      puts "The hotel doesn't recognise that... or you"
    end
  end

  # =========================
  # MOVEMENT
  # =========================

  def advance_room
    r = current_room
    return unless r

    if r.enemy&.alive?
      puts "Something is still in your way."
      return
    end

    if @player.current_room >= 69
      puts "\nThe final door."
      @player.current_room = 70
      return
    end

    @player.current_room += 1
    @player.rooms_cleared += 1

    new_room = current_room
    floor_crossing = new_room.floor > r.floor

    if floor_crossing
      puts "\n" + "=" * 50
      puts "  #{FLOORS[new_room.floor - 1][:name].upcase}"
      puts "  #{FLOORS[new_room.floor - 1][:desc]}"
      puts "=" * 50
      fracture_gain = (rand(3..7) * @fracture_mult).round
      @player.fracture = [@player.fracture + fracture_gain, 100].min
      puts "Moving between floors fractures something. +#{fracture_gain} Fracture."
    end

    random_event
  end

  def random_event
    return if rand > 0.40
    case rand
    when 0.00..0.12
      puts "\nThe lights go out."
      puts "They come back on."
      puts "Something has moved. Not the furniture."
      puts "You."
      puts "You are in a different part of the corridor than you were."
      puts "You don't remember moving."
      dmg = rand(3..8)
      @player.hp -= dmg
      puts "-#{dmg} HP."
    when 0.12..0.22
      gain = rand(6..16)
      @player.scraps += gain
      puts "\nA wallet on the floor. Still warm."
      puts "The ID inside has a photo. The photo is of someone who looks almost like you."
      puts "The name is almost your name. One letter different."
      puts "+#{gain} scraps."
    when 0.22..0.32
      shells = rand(1..3)
      @player.shells += shells
      puts "\nShells in a drawer. Still in the box."
      puts "The box has hotel stationary inside it. A note that says: you'll need these."
      puts "The note is in your handwriting. Dated from before you arrived."
      puts "+#{shells} shells."
    when 0.32..0.42
      @player.inventory[:bandage] += 1
      puts "\nA first aid kit in the hallway."
      puts "Opened. Used. Restocked."
      puts "The wrapping on the bandages has your blood type printed on it."
      puts "The hotel knew."
      puts "+1 bandage."
    when 0.42..0.55
      frac = (rand(5..12) * @fracture_mult).round
      @player.fracture = [@player.fracture + frac, 100].min
      event = [
        "You see yourself at the end of the corridor.\nYou are walking away from you.\nYou don't remember being there.",
        "The phone in the nearest room is ringing.\nYou answer it.\nYour own voice says: don't come to floor #{rand(2..7)}.\nYou are on that floor.",
        "A child is sitting in the corridor.\nIt looks up.\nIt has your eyes.\nNot similar eyes. Your eyes.\nYou still have your eyes.\nBoth of you do.",
        "You find a mirror that doesn't show the corridor.\nIt shows a room.\nYou recognise the room.\nSomeone is in it. They are looking at something.\nThe something is you.",
        "You hear your name.\nNot called. Spoken. In a conversation.\nTwo voices you don't recognise discussing you.\nDiscussing what you did.\nDiscussing what comes next.",
        "Your shadow is on the wrong wall.\nThen it's on the ceiling.\nThen it's gone.\nYou are still casting it. You just can't see where it went."
      ].sample
      puts "\n#{event}"
      puts "+#{frac} Fracture."
    when 0.55..0.65
      @player.inventory[:room_service] += 1
      puts "\nA room service voucher under your door."
      puts "Addressed to you. Your full name. Your room number."
      puts "The hotel delivered this before you told them your name."
      puts "+1 room service voucher."
    when 0.65..0.75
      frac = (rand(8..15) * @fracture_mult).round
      @player.fracture = [@player.fracture + frac, 100].min
      puts "\nYou find your own reflection in a window."
      puts "It doesn't move when you move."
      puts "It watches you figure out that it isn't moving."
      puts "Then it moves. Just once. Just slightly."
      puts "In a direction your body doesn't go."
      puts "+#{frac} Fracture."
    when 0.75..0.85
      if @player.equipped_gun.nil?
        gun = HOTEL_GUNS.sample
        puts "\n#{gun.name}."
        puts "#{gun.desc}"
        puts "Take it? (y/n)"
        print "> "
        @player.equipped_gun = gun if gets&.strip&.downcase == "y"
      else
        gain = rand(4..10)
        @player.scraps += gain
        puts "\nYou find #{gain} scraps in a coat pocket."
        puts "The coat is hanging on the back of a door."
        puts "The door opens into a wall."
      end
    when 0.85..1.00
      frac = (rand(10..18) * @fracture_mult).round
      @player.fracture = [@player.fracture + frac, 100].min
      puts "\nYou find a note on the floor."
      puts "It's in your handwriting."
      puts "It describes this corridor. This exact point. This exact moment."
      puts "It was written before you arrived."
      puts "The last line says: you haven't found the worst part yet."
      puts "+#{frac} Fracture."
    end

    fracture_collapse if @player.fracture >= 100
  end

  def fracture_collapse
    clear
    puts ""
    puts "The hotel wins."
    puts ""
    sleep 0.8
    puts "Not with a fight."
    puts "Not with violence."
    puts "With patience."
    puts ""
    sleep 0.8
    puts "The walls stop being walls."
    puts "Not suddenly. Gradually."
    puts "The way something you relied on gradually stops being reliable."
    puts ""
    sleep 0.8
    puts "#{@player.name} stops being able to tell"
    puts "what is corridor and what is not."
    puts "What is door and what is wall."
    puts "What is them and what is the building."
    puts ""
    sleep 0.8
    puts "The hotel has been preparing for this."
    puts "The hotel prepares for all of its guests."
    puts "Some guests it prepares for more than others."
    puts ""
    sleep 1
    puts "You were one of the others."
    puts ""
    sleep 0.8
    puts "An ambulance is called."
    puts "Not by you."
    puts "You can't remember how to use a phone."
    puts "You can't remember what phones are for."
    puts ""
    sleep 0.8
    puts "The hospital that receives you is the hospital from the other games."
    puts "Beneath that hospital: the library."
    puts "This is how you get there."
    puts "This is the week that made you someone who ends up there."
    puts ""
    sleep 1
    puts "The hotel adds your name to the registry."
    puts "Under checkout date: it writes: pending."
    puts ""
    puts "=" * 55
sleep 5
    @running = false
  end

  # =========================
  # SEARCH
  # =========================

  def search_room
    r = current_room
    if r.enemy&.alive?
      puts "You can't search properly with that in the room."
      return
    end

    puts "You search the room carefully."
    found_anything = false

    if rand < 0.40
      gain = rand(5..18)
      @player.scraps += gain
      puts "You find #{gain} scraps — cash, coins, a gift card for a restaurant that closed."
      found_anything = true
    end

    if rand < 0.30
      shells = rand(1..4)
      @player.shells += shells
      puts "Shells in a drawer, a jacket pocket, behind the minibar."
      puts "#{shells} shells."
      found_anything = true
    end

    if rand < 0.22
      @player.inventory[:bandage] += 1
      puts "A bandage kit in the bathroom. Still sealed."
      found_anything = true
    end

    if rand < 0.15
      @player.inventory[:room_service] += 1
      puts "A room service voucher. 'Good for one use. Complimentary.'"
      found_anything = true
    end

    if rand < 0.08 && @player.equipped_gun.nil?
      gun = HOTEL_GUNS.sample
      puts "\nYou find a #{gun.name}."
      puts "\"#{gun.desc}\""
      puts "Take it? (y/n)"
      print "> "
      @player.equipped_gun = gun if gets&.strip&.downcase == "y"
      found_anything = true
    end

    if rand < 0.20
      frac = (rand(2..6) * @fracture_mult).round
      @player.fracture = [@player.fracture + frac, 100].min
      puts ROOM_LORE.sample
      puts "+#{frac} Fracture."
      found_anything = true
    end

    puts "Nothing useful here." unless found_anything
    fracture_collapse if @player.fracture >= 100
  end

  # =========================
  # REST
  # =========================

  def rest
    r = current_room
    if r.enemy&.alive?
      puts "You can't rest with that in here."
      return
    end

    cost = 20
    if @player.scraps < cost
      puts "You can't afford to rest. (#{cost} scraps)"
      return
    end

    @player.scraps -= cost
    heal = rand(10..18)
    @player.hp = [@player.hp + heal, @player.max_hp].min

    frac = (rand(2..5) * @fracture_mult).round
    @player.fracture = [@player.fracture + frac, 100].min

    rest_lines = [
      ["You sit on the edge of the bed.", "The mattress adjusts to you too quickly. Like it already knew your shape.", "You close your eyes.", "When you open them the room is slightly different. Not rearranged. Slightly different. As if it moved a fraction closer to something it was always becoming."],
      ["You lie down.", "The ceiling is the wrong distance away.", "You sleep anyway. You dream about the corridor. In the dream the corridor is longer. In the dream you understand why.", "You wake up and immediately forget the understanding."],
      ["You sit against the wall.", "The wall is warm. It has been warm on every floor.", "You try not to think about what generates that warmth.", "You are unsuccessful."],
      ["You sleep in the chair.", "Not the bed. You don't trust the bed.", "The chair is also wrong. You sleep anyway.", "You dream about home. The dream gets the details almost right. Almost."]
    ].sample
    rest_lines.each { |l| puts l }
    puts "+#{heal} HP. +#{frac} Fracture."
    puts "(The hotel gives you rest. The hotel takes something for it.)"
    fracture_collapse if @player.fracture >= 100
  end

  # =========================
  # GUN MENU
  # =========================

  def gun_menu
    puts "\n=== GUN ==="
    if @player.equipped_gun
      g = @player.equipped_gun
      puts "Equipped: #{g.name}"
      puts g.desc
      puts "Damage: #{g.dmg_min}-#{g.dmg_max} | Shells/shot: #{g.shells_per_shot}"
      puts "Shells: #{@player.shells}"
      puts ""
      puts "Switch gun:"
      HOTEL_GUNS.each_with_index { |gun, i| puts "#{i+1}. #{gun.name}" }
      puts "#{HOTEL_GUNS.size + 1}. Unequip"
      puts "Enter to cancel"
      print "> "
      input = gets&.strip
      return if input.nil? || input.empty?
      idx = input.to_i - 1
      if idx == HOTEL_GUNS.size
        @player.equipped_gun = nil
        puts "Gun unequipped."
      elsif HOTEL_GUNS[idx]
        @player.equipped_gun = HOTEL_GUNS[idx]
        puts "You switch to the #{@player.equipped_gun.name}."
      end
    else
      puts "No gun equipped. Find them by searching rooms."
      puts "Shells: #{@player.shells}"
    end
  end

  # =========================
  # COMBAT
  # =========================

  def fight_current_room
    r = current_room
    return unless r&.enemy&.alive?

    puts "\n[#{r.enemy.name}]"
    puts r.enemy.desc
    puts "HP: #{r.enemy.hp} | ATK: #{r.enemy.atk} | DEF: #{r.enemy.defense}"

    if r.enemy.is_boss
      puts "\n#{r.enemy.name} steps forward."
      puts "\"#{FLOOR_BOSS_LINES[r.floor - 1].sample}\""
    end

    battle(r.enemy)
  end

  def battle(enemy)
    atb_player = 0
    atb_enemy  = 0

    until !enemy.alive? || !@player.alive?
      show_combat_status(enemy)

      atb_player += @player.speed
      atb_enemy  += enemy.speed

      if atb_player >= 100
        atb_player = 0
        player_combat_turn(enemy)
        next unless @running
      end

      if atb_enemy >= 100 && enemy.alive?
        atb_enemy = 0
        enemy_turn(enemy)
      end

      if @player.fracture >= 100
        fracture_collapse
        return
      end
    end

    if @player.alive? && !enemy.alive?
      conclude_fight(enemy)
    end
  end

  def show_combat_status(enemy)
    puts "\n--- COMBAT ---"
    puts "#{@player.name}: HP #{@player.hp}/#{@player.max_hp} | Fracture: #{@player.fracture}"
    puts "#{enemy.name}: HP #{enemy.hp}/#{enemy.max_hp}"
    puts "--------------"
  end

  def player_combat_turn(enemy)
    gun_label = @player.equipped_gun ? "Shoot [#{@player.shells}sh]" : "Shoot [no gun]"
    puts "\nYour turn."
    puts "1. Attack  2. Item  3. Guard  4. #{gun_label}"
    print "> "

    case gets&.strip
    when "1"
      dmg = [(@player.atk - enemy.defense) * @damage_mult, 1].max.round
      enemy.hp = [enemy.hp - dmg, 0].max
      puts "You hit #{enemy.name} for #{dmg}."
      puts "#{enemy.name} collapses." if enemy.hp <= 0
    when "2"
      use_item_in_combat
    when "3"
      @player.defense += 2
      puts "You brace against the wall."
    when "4"
      shoot_in_combat(enemy)
    when "fkill"
      enemy.hp = 0
      puts "."
    else
      puts "You freeze. The hotel doesn't."
    end
  end

  def enemy_turn(enemy)
    return unless enemy.alive?

    if enemy.is_boss && rand < 0.35
      frac = (rand(6..14) * @fracture_mult).round
      @player.fracture = [@player.fracture + frac, 100].min
      boss_lines = [
        "#{enemy.name} doesn't attack. It looks at you. The looking is worse than an attack.",
        "#{enemy.name} says your name. Not to you. To itself. Like it's remembering.",
        "#{enemy.name} gestures toward the door. The door is gone. It wasn't gone before.",
        "#{enemy.name} turns away. The back of its head is wrong. You can't stop looking at it.",
        "#{enemy.name} produces something. It looks like your room key. It is your room key.",
        "#{enemy.name} recites something. A list. The list is things you were hoping no one knew.",
        "#{enemy.name} is patient. Its patience fills the room. There is no space left for you."
      ]
      puts boss_lines.sample
      puts "+#{frac} Fracture."
      return
    end

    attack_lines = [
      "#{enemy.name} moves toward you in a way that isn't walking.",
      "#{enemy.name} reaches. The reach is wrong. Too long.",
      "#{enemy.name} makes a sound. The sound means something. You don't know what.",
      "#{enemy.name} doesn't hesitate. It has never hesitated.",
      "#{enemy.name} is faster than it should be given what it is.",
      "#{enemy.name} closes distance. You didn't see it move."
    ]

    dmg = [(enemy.atk - @player.defense) * @damage_mult, 1].max.round
    @player.hp -= dmg
    puts attack_lines.sample
    puts "You take #{dmg}."
    puts "You collapse." if @player.hp <= 0
    @player.defense = [@player.defense, 4].min
  end

  def use_item_in_combat
    puts "\nItems:"
    puts "1. Bandage (#{@player.inventory[:bandage]}) — heal #{rand(10..16)} HP"
    puts "2. Room Service (#{@player.inventory[:room_service]}) — full heal"
    print "> "

    case gets&.strip
    when "1"
      if @player.inventory[:bandage] > 0
        @player.inventory[:bandage] -= 1
        heal = rand(10..16)
        @player.hp = [@player.hp + heal, @player.max_hp].min
        puts "You bandage the wound. +#{heal} HP."
      else
        puts "No bandages left."
      end
    when "2"
      if @player.inventory[:room_service] > 0
        @player.inventory[:room_service] -= 1
        @player.hp = @player.max_hp
        puts "Room service arrives. Somehow. Full heal."
        frac = (5 * @fracture_mult).round
        @player.fracture = [@player.fracture + frac, 100].min
        puts "The bellhop doesn't leave. +#{frac} Fracture."
      else
        puts "No room service vouchers."
      end
    else
      puts "Nothing happens."
    end
  end

  def shoot_in_combat(enemy)
    gun = @player.equipped_gun
    unless gun
      puts "No gun equipped."
      return
    end
    if @player.shells < gun.shells_per_shot
      puts "Not enough shells. Need #{gun.shells_per_shot}, have #{@player.shells}."
      return
    end

    @player.shells -= gun.shells_per_shot

    case gun.effect
    when :aoe
      # shotgun — extra damage, can't miss
      dmg = (rand(gun.dmg_min..gun.dmg_max) * @damage_mult).round
      enemy.hp = [enemy.hp - dmg, 0].max
      puts "\nThe shotgun fills the room with sound."
      puts "#{enemy.name} takes #{dmg}. The walls take the rest."
    when :suppress
      # rifle — high damage + enemy loses next attack
      dmg = (rand(gun.dmg_min..gun.dmg_max) * @damage_mult).round
      enemy.hp = [enemy.hp - dmg, 0].max
      enemy.speed = [enemy.speed - 4, 1].max
      puts "\nThe rifle cracks once. #{enemy.name} takes #{dmg}."
      puts "It hesitates. SPD -4."
    else
      dmg = (rand(gun.dmg_min..gun.dmg_max) * @damage_mult).round
      enemy.hp = [enemy.hp - dmg, 0].max
      puts "\nYou fire. #{enemy.name} takes #{dmg}."
      puts "#{enemy.name} collapses." if enemy.hp <= 0
    end

    puts "(#{@player.shells} shells left)"
  end

  def conclude_fight(enemy)
    puts "\n#{enemy.name} stops."

    gain = rand(8..20)
    gain += rand(15..30) if enemy.is_boss
    @player.scraps += gain
    puts "You find #{gain} scraps."

    # Shell drop
    if rand < 0.30
      shells = rand(1..4)
      @player.shells += shells
      puts "#{shells} shells on the floor."
    end

    # Gun drop
    if rand < 0.10 && @player.equipped_gun.nil?
      gun = HOTEL_GUNS.sample
      puts "#{gun.name} — left behind."
      puts "Take it? (y/n)"
      print "> "
      @player.equipped_gun = gun if gets&.strip&.downcase == "y"
    end

    # Fracture drop on boss kill
    if enemy.is_boss
      frac_drop = (10 * @fracture_mult).round
      @player.fracture = [@player.fracture - frac_drop, 0].max
      floor_name = FLOORS[current_room.floor - 1][:name]
      puts ""
      puts "#{floor_name} is quiet."
      puts "Not the quiet of something resolved."
      puts "The quiet of something that has stopped needing to make noise."
      puts "The hotel has many kinds of quiet."
      puts "This one is the kind that follows you upstairs."
      puts "-#{frac_drop} Fracture."
    end
  end

  # =========================
  # ENDINGS
  # =========================

  def checkout_ending
    clear
    sleep 0.5
    puts "Room 70."
    puts ""
    sleep 0.8
    puts "The door at the end of the corridor that goes on too long."
    puts "You have been walking toward it for seven days."
    puts ""
    sleep 0.8
    puts "You open it."
    puts ""
    sleep 1
    puts "Outside."
    puts ""
    sleep 0.5
    puts "Not the city you arrived in."
    puts "Close."
    puts "The proportions are slightly wrong."
    puts "The sky is the right colour but the wrong shade."
    puts "The sound of traffic is there but the timing is off."
    puts "Like a recording of a city rather than a city."
    puts ""
    sleep 0.8
    puts "You stand on the pavement."
    puts ""
    sleep 0.5
    puts "You are not okay."
    puts ""
    sleep 0.5
    puts "You know this with the specific certainty of someone"
    puts "who has just spent a week learning what it feels like"
    puts "to not be okay, precisely, technically, completely."
    puts ""
    sleep 0.8
    puts "You don't call anyone."
    puts "You don't know what you would say."
    puts "The words for what happened are still in the hotel."
    puts "The hotel keeps them."
    puts "The hotel is good at keeping things."
    puts ""
    sleep 1
    puts "A week from now you will be in a hospital."
    puts "You will not explain how you got there."
    puts "The person who admits you will ask questions."
    puts "You will give the wrong answers."
    puts "Not because you're lying."
    puts "Because the right answers are still on the fourth floor."
    puts ""
    sleep 1
    puts "You walk away from the hotel."
    puts "The hotel watches you go."
    puts "The concierge, from the lobby window, keeps smiling."
    puts ""
    sleep 0.5
    puts "The smile is genuine."
    puts "It always was."
    puts "It will still be there when you come back."
    puts ""
    sleep 1

    puts "=" * 55
    puts ""
    puts "  #{@player.name.upcase}"
    puts "  CHECKED IN: 7 DAYS AGO"
    puts "  ROOMS SURVIVED: #{@player.rooms_cleared} / 70"
    puts "  FRACTURE ON EXIT: #{@player.fracture} / 100"
    puts ""

    if @player.fracture == 0
      puts "  You leave whole."
      puts "  The hotel has never failed to leave a mark."
      puts "  Check again in a few days."
    elsif @player.fracture < 25
      puts "  You leave mostly intact."
      puts "  The changes are small."
      puts "  Small changes accumulate."
    elsif @player.fracture < 50
      puts "  You leave changed."
      puts "  You will spend a long time thinking it was something else."
      puts "  It was the hotel."
    elsif @player.fracture < 75
      puts "  You leave fractured."
      puts "  Not broken. Not yet."
      puts "  Give it a week."
      puts "  The hospital will be clean and white and will smell like antiseptic."
      puts "  You will be grateful for something that simple."
    elsif @player.fracture < 90
      puts "  You barely leave."
      puts "  Some of you didn't make it through the door."
      puts "  The hotel holds it for you."
      puts "  You can collect it any time."
      puts "  You will not collect it."
    else
      puts "  You leave, technically."
      puts "  The part of you that checks out is not the part that checked in."
      puts "  The hotel has your name on two registries now."
      puts "  The guest registry and the other one."
      puts "  You don't know about the other one."
    end

    puts ""
    puts "=" * 55
    sleep 1

    puts <<~TEASE


    The hotel sign flickers behind you as you walk away.

    The letters rearrange.

    They almost spell something.

    They spell: COME BACK.

    Then they rearrange again.

    They spell: YOU WILL.


    In the hospital, a week from now,
    in the dark, in the small hours,
    you will hear something beneath the building.

    Not pipes.

    Not the boiler.

    Something that learned to breathe
    in a building that should not breathe
    and followed you here.


    It found something beneath the hospital.
    Something deep and old and shelved.


    DARK FLOOF
    THE ORIGINAL GAME
    THE ONE YOU HAVEN'T PLAYED YET
    OR THE ONE YOU ALREADY HAVE
    DEPENDING ON WHEN YOU FOUND THIS ... XD 

    TEASE
sleep 7
    @running = false
  end

  def death_screen
    clear
    sleep 0.5
    puts "#{@player.name} doesn't make it out."
    puts ""
    sleep 0.8
    puts "Not killed."
    puts ""
    sleep 0.5
    puts "Kept."
    puts ""
    sleep 0.8
    puts "The hotel updates the registry."
    puts "Under checkout date, it writes nothing."
    puts "It has never written anything under that field for a guest it keeps."
    puts "It doesn't need to."
    puts ""
    sleep 0.8
    puts "Room #{@player.current_room + 1} of 70."
    puts "Floor #{current_room&.floor || '?'}."
    puts ""
    sleep 0.5
    puts "The hotel thanks you for your stay."
    puts ""
    sleep 0.3
    puts "It genuinely does."
    puts "The hotel is grateful for its guests."
    puts "It just expresses gratitude differently than you're used to."
    puts ""
    sleep 1
    puts "Your room will be ready for the next guest by morning."
    puts "The hotel is efficient."
    puts "The hotel is always ready."
    @running = false
  end

  # =========================
  # SAVE / LOAD
  # =========================

  def save_game
    data = {
      player: {
        name:         @player.name,
        hp:           @player.hp,
        max_hp:       @player.max_hp,
        atk:          @player.atk,
        defense:      @player.defense,
        speed:        @player.speed,
        scraps:       @player.scraps,
        inventory:    @player.inventory,
        fracture:     @player.fracture,
        current_room: @player.current_room,
        rooms_cleared: @player.rooms_cleared,
        shells:       @player.shells,
        equipped_gun: @player.equipped_gun&.name
      },
      room_states: @rooms.map { |r| { visited: r.visited, flags: r.flags, enemy_hp: r.enemy&.hp } },
      difficulty:     @difficulty,
      damage_mult:    @damage_mult,
      fracture_mult:  @fracture_mult,
      encounter_rate: @encounter_rate
    }
    File.write("dark_floof_4_save.json", JSON.pretty_generate(data))
    puts "Saved."
  end

  def load_game
    unless File.exist?("dark_floof_4_save.json")
      puts "No save file found."
      return
    end

    data = JSON.parse(File.read("dark_floof_4_save.json"))
    p    = data["player"]

    @player               = Player.new(p["name"])
    @player.hp            = p["hp"]
    @player.max_hp        = p["max_hp"]
    @player.atk           = p["atk"]
    @player.defense       = p["defense"]
    @player.speed         = p["speed"]
    @player.scraps        = p["scraps"]
    @player.inventory     = p["inventory"]
    @player.fracture      = p["fracture"]
    @player.current_room  = p["current_room"]
    @player.rooms_cleared = p["rooms_cleared"]
    @player.shells        = p["shells"]
    @player.equipped_gun  = HOTEL_GUNS.find { |g| g.name == p["equipped_gun"] } if p["equipped_gun"]

    @difficulty     = data["difficulty"].to_sym
    @damage_mult    = data["damage_mult"]
    @fracture_mult  = data["fracture_mult"]
    @encounter_rate = data["encounter_rate"]

    build_hotel

    # Restore room states
    if data["room_states"]
      data["room_states"].each_with_index do |rs, i|
        next unless @rooms[i]
        @rooms[i].visited = rs["visited"]
        @rooms[i].flags   = rs["flags"]
        if rs["enemy_hp"] && @rooms[i].enemy
          @rooms[i].enemy.hp = rs["enemy_hp"]
        end
      end
    end

    puts "Loaded. Welcome back to the hotel."
    main_loop
  end

  # =========================
  # DEBUG CONSOLE
  # =========================

  def debug_console
    puts "\n=== DEBUG ==="
    puts "1. Full heal"
    puts "2. Add scraps"
    puts "3. Add shells"
    puts "4. Set fracture"
    puts "5. Equip gun"
    puts "6. Skip to floor"
    puts "7. Add room service voucher"
    puts "8. Cancel"
    print "> "

    case gets&.strip
    when "1"
      @player.hp = @player.max_hp
      puts "Healed."
    when "2"
      @player.scraps += 100
      puts "Scraps: #{@player.scraps}"
    when "3"
      @player.shells += 20
      puts "Shells: #{@player.shells}"
    when "4"
      print "Fracture: "
      @player.fracture = gets.to_i
      puts "Set."
    when "5"
      HOTEL_GUNS.each_with_index { |g, i| puts "#{i+1}. #{g.name}" }
      print "> "
      idx = gets.to_i - 1
      @player.equipped_gun = HOTEL_GUNS[idx] if HOTEL_GUNS[idx]
      puts "Equipped: #{@player.equipped_gun&.name}"
    when "6"
      print "Floor (1-7): "
      floor = gets.to_i.clamp(1, 7)
      @player.current_room = (floor - 1) * 10
      puts "Jumped to floor #{floor}, room #{@player.current_room + 1}."
    when "7"
      @player.inventory[:room_service] += 1
      puts "Room service voucher added."
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
