import 'package:flutter/material.dart';
import 'package:adventure_logger/features/explore/models/adventure_models.dart';

const _unsplash = 'https://images.unsplash.com';

const List<AdventureCategory> ghanaAdventures = [
  // ── HIKING & TREKKING ─────────────────────────────────────────────────────
  AdventureCategory(
    id: 'hiking',
    name: 'Hiking & Trekking',
    tagline: 'Conquer Ghana\'s peaks and trails',
    icon: Icons.terrain_rounded,
    color: Color(0xFF2D6A4F),
    imageUrl: '$_unsplash/photo-1464822759023-fed622ff2c3b?w=800&fit=crop',
    places: [
      AdventurePlace(
        name: 'Mount Afadjato',
        region: 'Volta Region',
        description:
            'Ghana\'s highest peak at 885 metres above sea level. The summit rewards trekkers with sweeping panoramic views over the Volta Region into neighbouring Togo. The trail passes through dense tropical forest and open grassland.',
        imageUrl: '$_unsplash/photo-1506905925346-21bda4d32df4?w=800&fit=crop',
        highlights: [
          'Highest point in Ghana (885 m)',
          'Views into Togo',
          'Tropical forest trail',
          'Local guide services available',
        ],
        bestTime: 'November – March (dry season)',
        difficulty: 'Moderate',
        entryFee: 'GHS 20 – 40',
        tip: 'Start early (before 7 am) to reach the summit before midday heat.',
      ),
      AdventurePlace(
        name: 'Shai Hills Resource Reserve',
        region: 'Greater Accra Region',
        description:
            'Just an hour from Accra, Shai Hills offers dramatic rocky inselbergs, ancient caves, and open savanna. The reserve is home to baboons, antelopes, ostriches, and diverse birdlife — a surprisingly wild escape near the capital.',
        imageUrl: '$_unsplash/photo-1547036967-23d11aacaee0?w=800&fit=crop',
        highlights: [
          'Rocky hillside scrambles',
          'Cave exploration',
          'Baboon & ostrich sightings',
          '1 hour from Accra',
        ],
        bestTime: 'October – April',
        difficulty: 'Easy – Moderate',
        entryFee: 'GHS 30',
        tip: 'Hire a reserve guide — they know where the baboon troops roam.',
      ),
      AdventurePlace(
        name: 'Tafi Atome Monkey Sanctuary',
        region: 'Volta Region',
        description:
            'A community-managed sacred forest near the village of Tafi Atome. Mona monkeys here have been protected for centuries and are remarkably accustomed to humans — they\'ll come right up to you. A short forest walk rounds off the experience.',
        imageUrl: '$_unsplash/photo-1448375240586-882707db888b?w=800&fit=crop',
        highlights: [
          'Wild Mona monkeys at arm\'s length',
          'Sacred community forest',
          'Village cultural tour available',
          'Excellent for families',
        ],
        bestTime: 'Year-round',
        difficulty: 'Easy',
        entryFee: 'GHS 15',
        tip: 'Bring bananas — the monkeys will eat from your hand.',
      ),
      AdventurePlace(
        name: 'Aburi Botanical Gardens',
        region: 'Eastern Region',
        description:
            'Established in 1890 on a cool hillside 450 m above sea level, Aburi Gardens is a serene escape from Accra\'s heat. Tree-lined avenues, exotic plant collections, and rolling hills make it ideal for leisurely walking and picnics.',
        imageUrl: '$_unsplash/photo-1585320806297-9794b3e4aaae?w=800&fit=crop',
        highlights: [
          'Colonial-era botanical heritage',
          'Cool hillside climate',
          '64 hectares of gardens',
          'Picnic-friendly lawns',
        ],
        bestTime: 'Year-round',
        difficulty: 'Easy',
        entryFee: 'GHS 10',
        tip: 'Visit midweek for a quieter, more peaceful experience.',
      ),
    ],
  ),

  // ── BEACHES ───────────────────────────────────────────────────────────────
  AdventureCategory(
    id: 'beaches',
    name: 'Beach Escapes',
    tagline: 'Ghana\'s stunning Gulf of Guinea coastline',
    icon: Icons.beach_access_rounded,
    color: Color(0xFF0077B6),
    imageUrl: '$_unsplash/photo-1507525428034-b723cf961d3e?w=800&fit=crop',
    places: [
      AdventurePlace(
        name: 'Busua Beach',
        region: 'Western Region',
        description:
            'Often voted Ghana\'s most beautiful beach, Busua features a sweeping crescent of golden sand backed by fishing villages. It\'s a hub for surfing with consistent Atlantic swells, and the laid-back atmosphere makes it a favourite for longer stays.',
        imageUrl: '$_unsplash/photo-1519046904884-53103b34b206?w=800&fit=crop',
        highlights: [
          'Surfing & surf lessons',
          'Fishing village atmosphere',
          'Beachside restaurants',
          'Near Fort Metal Cross',
        ],
        bestTime: 'October – April',
        entryFee: 'Free',
        tip: 'Rent a board from local instructors for around GHS 80/hour.',
      ),
      AdventurePlace(
        name: 'Kokrobite Beach',
        region: 'Greater Accra Region',
        description:
            'The most accessible beach escape from Accra, Kokrobite balances a lively social scene with natural beauty. The Academy of African Music and Arts (AAMA) is based here, making weekends particularly vibrant with live drumming and dance.',
        imageUrl: '$_unsplash/photo-1512100356356-de1b84283e18?w=800&fit=crop',
        highlights: [
          'Afro-drumming & dance events',
          '45 minutes from Accra',
          'Various guesthouses on the beach',
          'Bustling Saturday market',
        ],
        bestTime: 'November – February',
        entryFee: 'Free',
        tip: 'Come on a Saturday evening for spontaneous drumming sessions.',
      ),
      AdventurePlace(
        name: 'La Pleasure Beach (Labadi)',
        region: 'Greater Accra Region',
        description:
            'Accra\'s most popular and lively beach, La Pleasure Beach is a full sensory experience — vendors, horseback rides along the shore, live highlife music, and vibrant crowds. It\'s a true snapshot of Ghanaian coastal life.',
        imageUrl: '$_unsplash/photo-1507525428034-b723cf961d3e?w=800&fit=crop',
        highlights: [
          'Horseback riding on the beach',
          'Live highlife & afrobeats music',
          'Food & drink vendors',
          'Busy weekend atmosphere',
        ],
        bestTime: 'Weekends year-round',
        entryFee: 'GHS 10 – 20',
        tip: 'Arrive before noon on weekends to secure a shaded spot.',
      ),
      AdventurePlace(
        name: 'Anomabo Beach',
        region: 'Central Region',
        description:
            'A quiet and historically rich beach town in the Central Region. Anomabo was once a major slave trade port; the ruins of Fort William overlook the shore. Today it offers uncrowded sands and authentic fishing community charm.',
        imageUrl: '$_unsplash/photo-1473116763249-2faaef81ccda?w=800&fit=crop',
        highlights: [
          'Historic Fort William ruins',
          'Traditional canoe fishing',
          'Very uncrowded',
          'Combine with Cape Coast visit',
        ],
        bestTime: 'November – March',
        entryFee: 'Free',
        tip: 'Pair with a day trip to Elmina or Cape Coast Castle nearby.',
      ),
    ],
  ),

  // ── WILDLIFE & SAFARI ──────────────────────────────────────────────────────
  AdventureCategory(
    id: 'wildlife',
    name: 'Wildlife & Safari',
    tagline: 'Encounter Africa\'s big game on Ghanaian soil',
    icon: Icons.pets_rounded,
    color: Color(0xFFB5451B),
    imageUrl: '$_unsplash/photo-1551632436-cbf8dd35adfa?w=800&fit=crop',
    places: [
      AdventurePlace(
        name: 'Mole National Park',
        region: 'Savannah Region',
        description:
            'Ghana\'s largest and most important wildlife refuge, covering over 4,840 km². Mole is home to more than 90 mammal species including African elephants, lions, leopards, buffalo, warthogs, kob antelopes, and over 300 bird species. Walking safaris put you within metres of wild elephants.',
        imageUrl: '$_unsplash/photo-1472791108553-c9405341e398?w=800&fit=crop',
        highlights: [
          'African elephant herds at the waterhole',
          'Walking safaris with armed rangers',
          'Over 300 bird species',
          'Lions & leopards (rare sightings)',
        ],
        bestTime: 'December – April (dry season — wildlife concentrates at water)',
        difficulty: 'Easy (game drives) / Moderate (walking)',
        entryFee: 'GHS 75 (foreigners) / GHS 15 (Ghanaians)',
        tip: 'Book a room at Mole Motel — the veranda overlooks the waterhole where elephants drink at dusk.',
      ),
      AdventurePlace(
        name: 'Kakum National Park',
        region: 'Central Region',
        description:
            'A tropical rainforest haven near Cape Coast protecting forest elephants, bongo antelope, Diana monkeys, and 400+ bird species. The famous Canopy Walkway suspends visitors 30 m above the forest floor across seven rope bridges — a world-class ecotourism experience.',
        imageUrl: '$_unsplash/photo-1448375240586-882707db888b?w=800&fit=crop',
        highlights: [
          'World-famous 333 m canopy walkway',
          'Forest elephants & Diana monkeys',
          '400+ bird species for birders',
          'Night walks available',
        ],
        bestTime: 'November – February',
        entryFee: 'GHS 60 (canopy walkway)',
        tip: 'Book the sunrise canopy walk — mist rolls through the forest canopy at dawn.',
      ),
      AdventurePlace(
        name: 'Bia National Park',
        region: 'Western Region',
        description:
            'One of Ghana\'s most biodiverse and least-visited parks, sharing a border with Côte d\'Ivoire. Bia is critical habitat for chimpanzees, pygmy hippopotamuses, bongo, and the endangered white-breasted guinea fowl. A true wilderness experience for the adventurous.',
        imageUrl: '$_unsplash/photo-1547036967-23d11aacaee0?w=800&fit=crop',
        highlights: [
          'Chimpanzee tracking',
          'Pygmy hippopotamus (rare)',
          'Remote & barely touristed',
          'Rich primate diversity',
        ],
        bestTime: 'November – March',
        difficulty: 'Moderate – Challenging',
        entryFee: 'GHS 40',
        tip: 'Arrange transport and a guide in advance — infrastructure is minimal.',
      ),
      AdventurePlace(
        name: 'Digya National Park',
        region: 'Bono East Region',
        description:
            'Sitting on the shores of Lake Volta, Digya combines a game reserve with water-based exploration. Hippos lounge in the shallows, crocodiles bask on the banks, and manatees (rare) glide through the lake. Boat safaris add a unique dimension rare elsewhere in Ghana.',
        imageUrl: '$_unsplash/photo-1516026672322-bc52d61a55d5?w=800&fit=crop',
        highlights: [
          'Hippo & crocodile boat safaris',
          'West African manatee (rare)',
          'Lake Volta scenery',
          'Fishing communities nearby',
        ],
        bestTime: 'December – March',
        entryFee: 'GHS 30',
        tip: 'Organise a dugout canoe ride at dawn for hippo sightings.',
      ),
    ],
  ),

  // ── WATERFALLS ───────────────────────────────────────────────────────────
  AdventureCategory(
    id: 'waterfalls',
    name: 'Waterfalls & Rivers',
    tagline: 'West Africa\'s most dramatic cascades',
    icon: Icons.water_rounded,
    color: Color(0xFF1565C0),
    imageUrl: '$_unsplash/photo-1518623489648-a173ef7824f3?w=800&fit=crop',
    places: [
      AdventurePlace(
        name: 'Wli Waterfalls',
        region: 'Volta Region',
        description:
            'The highest waterfall in West Africa, plunging 80 metres into a misty pool surrounded by cliff faces. A 45-minute forest hike brings you to the lower falls (accessible year-round), while the upper falls require a more demanding 3-hour climb offering breathtaking views. Thousands of fruit bats roost in the surrounding cliffs.',
        imageUrl: '$_unsplash/photo-1510797215324-95aa89f43c33?w=800&fit=crop',
        highlights: [
          'Highest waterfall in West Africa (80 m)',
          'Thousands of roosting fruit bats',
          'Upper & lower falls trails',
          'Refreshing swimming pool at the base',
        ],
        bestTime: 'July – October (peak flow) / Nov – March (accessible trails)',
        difficulty: 'Easy (lower) / Challenging (upper)',
        entryFee: 'GHS 15',
        tip: 'Visit in September at peak rainy season for the most powerful cascade.',
      ),
      AdventurePlace(
        name: 'Boti Falls',
        region: 'Eastern Region',
        description:
            'A beautiful twin waterfall in the Boti Forest Reserve about 1.5 hours from Accra. During the rainy season both streams merge into one powerful cascade. The area includes the famous "Umbrella Rock" — a giant precariously balanced boulder — and the "Love Vine" (Hippocratea africana) at the base.',
        imageUrl: '$_unsplash/photo-1432405972618-c60b0225b8f9?w=800&fit=crop',
        highlights: [
          'Twin falls merging in rainy season',
          'Umbrella Rock natural formation',
          'The "Love Vine" cultural landmark',
          'Easy day trip from Accra',
        ],
        bestTime: 'June – October (rainy season for best falls)',
        difficulty: 'Easy',
        entryFee: 'GHS 12',
        tip: 'Combine with a visit to the nearby Ananekrom Umbrella Rock formation.',
      ),
      AdventurePlace(
        name: 'Kintampo Waterfalls',
        region: 'Bono East Region',
        description:
            'Three-tiered cascades on the Pumpum River in the geographical centre of Ghana. The falls drop through layered sandstone rocks creating a dramatic multi-level spectacle. A well-maintained trail and viewing platforms make it accessible for all fitness levels.',
        imageUrl: '$_unsplash/photo-1564419320461-6870880221ad?w=800&fit=crop',
        highlights: [
          'Three dramatic tiers of cascades',
          'Located at Ghana\'s geographic centre',
          'Sandstone canyon scenery',
          'Well-maintained visitor facilities',
        ],
        bestTime: 'August – November',
        difficulty: 'Easy',
        entryFee: 'GHS 10',
        tip: 'The falls are most impressive after heavy rains; check conditions locally.',
      ),
      AdventurePlace(
        name: 'Tagbo Falls',
        region: 'Volta Region',
        description:
            'A hidden gem near Liati Wote village, Tagbo Falls requires a rewarding 1.5-hour hike through dense forest. The payoff is a secluded 60-metre waterfall with a crystal-clear swimming pool at its base, often enjoyed in near-solitude. The forest trail is rich with birds and butterflies.',
        imageUrl: '$_unsplash/photo-1501854140801-50d01698950b?w=800&fit=crop',
        highlights: [
          'Secluded & rarely crowded',
          'Crystal-clear swimming pool',
          'Forest rich with birds & butterflies',
          'Near Mount Afadjato — combine both',
        ],
        bestTime: 'September – January',
        difficulty: 'Moderate',
        entryFee: 'GHS 20 (guide included)',
        tip: 'Local guides from Liati Wote village are mandatory — hire through the community office.',
      ),
    ],
  ),

  // ── CULTURAL HERITAGE ────────────────────────────────────────────────────
  AdventureCategory(
    id: 'cultural',
    name: 'Cultural Heritage',
    tagline: 'Walk through centuries of Ghanaian history',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF6A1B4D),
    imageUrl: '$_unsplash/photo-1577717903315-1691ae25ab3f?w=800&fit=crop',
    places: [
      AdventurePlace(
        name: 'Cape Coast Castle',
        region: 'Central Region',
        description:
            'A UNESCO World Heritage Site and the most visited historical monument in Ghana. Built by the Swedes in 1653 and later controlled by the British, Cape Coast Castle was the largest slave-holding site on the West African coast. Its dungeons, the "Door of No Return," and the whitewashed battlements overlooking the sea make for a profoundly moving visit.',
        imageUrl: '$_unsplash/photo-1566438480900-0609be27a4be?w=800&fit=crop',
        highlights: [
          'UNESCO World Heritage Site',
          'Door of No Return',
          'Well-curated museum & guided tours',
          'Stunning ocean views from battlements',
        ],
        bestTime: 'Year-round',
        entryFee: 'GHS 50 (guided tour)',
        tip: 'Book a guided tour (1.5 hrs) — the history is too important to miss without context.',
      ),
      AdventurePlace(
        name: 'Elmina Castle',
        region: 'Central Region',
        description:
            'Built by the Portuguese in 1482, Elmina Castle is the oldest European building in sub-Saharan Africa. It predates Cape Coast Castle and offers a slightly different — and in some ways more intimate — encounter with the transatlantic slave trade. The adjacent St. George\'s Church and the fishing harbour create a vivid historical tableau.',
        imageUrl: '$_unsplash/photo-1564419320461-6870880221ad?w=800&fit=crop',
        highlights: [
          'Oldest European building in sub-Saharan Africa (1482)',
          'Colourful Elmina fishing harbour',
          'Adjacent St. George\'s Church',
          'UNESCO World Heritage Site',
        ],
        bestTime: 'Year-round',
        entryFee: 'GHS 50',
        tip: 'Visit Elmina fish market in the morning before touring the castle.',
      ),
      AdventurePlace(
        name: 'Larabanga Mosque',
        region: 'Savannah Region',
        description:
            'Believed to be the oldest mosque in Ghana and one of the oldest in West Africa, the Larabanga Mosque dates to 1421 AD. Built in the Sudanese-Sahelian architectural style — mud brick with protruding wooden beams — it is a masterpiece of vernacular Islamic architecture. Larabanga village itself exudes a medieval tranquillity.',
        imageUrl: '$_unsplash/photo-1574375927938-d5a98e8ffe85?w=800&fit=crop',
        highlights: [
          'Ghana\'s oldest mosque (est. 1421)',
          'Iconic Sudanese-Sahelian mud architecture',
          'Peaceful historic village atmosphere',
          'Close to Mole National Park',
        ],
        bestTime: 'November – March',
        entryFee: 'Small donation requested',
        tip: 'Combine with a Mole National Park safari — they are just 7 km apart.',
      ),
      AdventurePlace(
        name: 'Manhyia Palace Museum',
        region: 'Ashanti Region',
        description:
            'The official residence of the Asantehene (King of the Ashanti), Manhyia Palace in Kumasi contains a museum tracing Ashanti royal history from the founding of the kingdom in the 17th century. Exhibits include royal regalia, historical photographs, and the story of the famous Golden Stool.',
        imageUrl: '$_unsplash/photo-1580818144970-66f12ad7a15e?w=800&fit=crop',
        highlights: [
          'Official palace of the Asantehene',
          'Royal regalia & Golden Stool history',
          'Guided tours by palace staff',
          'Heart of Ashanti cultural heritage',
        ],
        bestTime: 'Year-round (closed Sundays)',
        entryFee: 'GHS 15',
        tip: 'Visit on a weekday to avoid crowds; photography requires a separate fee.',
      ),
    ],
  ),

  // ── ECO & FOREST ─────────────────────────────────────────────────────────
  AdventureCategory(
    id: 'eco',
    name: 'Eco & Forest',
    tagline: 'Lose yourself in Ghana\'s ancient rainforests',
    icon: Icons.forest_rounded,
    color: Color(0xFF40916C),
    imageUrl: '$_unsplash/photo-1448375240586-882707db888b?w=800&fit=crop',
    places: [
      AdventurePlace(
        name: 'Kakum Canopy Walkway',
        region: 'Central Region',
        description:
            'One of only a handful of canopy walkways in the world, Kakum\'s 333-metre bridge system hangs 30 metres above the forest floor. The rope bridges sway gently as you cross, revealing a bird\'s-eye view of the rainforest canopy that is simply unavailable from the ground. An experience unlike anything else in Ghana.',
        imageUrl: '$_unsplash/photo-1448375240586-882707db888b?w=800&fit=crop',
        highlights: [
          '333 m walkway, 30 m above the forest',
          'One of only a few canopy walks globally',
          'Spectacular bird-watching',
          'Night canopy walks available',
        ],
        bestTime: 'November – March',
        difficulty: 'Easy (vertigo may affect some)',
        entryFee: 'GHS 60',
        tip: 'The 6 am sunrise walk is magical — forest comes alive with birdsong.',
      ),
      AdventurePlace(
        name: 'Bobiri Forest Reserve & Butterfly Sanctuary',
        region: 'Ashanti Region',
        description:
            'A 54 km² forest reserve near Kumasi harbouring over 400 butterfly species — one of the richest concentrations in West Africa. Forest trails wind through tall trees, and the reserve\'s guesthouse lets you experience the forest at dawn and dusk when butterfly activity peaks.',
        imageUrl: '$_unsplash/photo-1585320806297-9794b3e4aaae?w=800&fit=crop',
        highlights: [
          '400+ butterfly species',
          'One of West Africa\'s richest insect sanctuaries',
          'Overnight forest guesthouse',
          'Guided forest walks',
        ],
        bestTime: 'September – November (peak butterfly season)',
        difficulty: 'Easy',
        entryFee: 'GHS 20',
        tip: 'Bring a macro lens or use your phone\'s portrait mode — butterflies are spectacular up close.',
      ),
      AdventurePlace(
        name: 'Ankasa Conservation Area',
        region: 'Western Region',
        description:
            'The largest remaining tract of pristine lowland rainforest in Ghana, Ankasa is critical habitat for forest elephants, chimpanzees, pygmy hippos, and over 800 plant species. With minimal tourist infrastructure, a visit here feels genuinely wild. The birdwatching — over 300 species — is world class.',
        imageUrl: '$_unsplash/photo-1501854140801-50d01698950b?w=800&fit=crop',
        highlights: [
          'Ghana\'s most pristine rainforest',
          'Forest elephants & chimpanzees',
          '800+ plant species',
          'Over 300 bird species',
        ],
        bestTime: 'December – February',
        difficulty: 'Moderate – Challenging',
        entryFee: 'GHS 35',
        tip: 'Stay overnight at the park camp — nocturnal forest sounds are extraordinary.',
      ),
      AdventurePlace(
        name: 'Atewa Range Forest Reserve',
        region: 'Eastern Region',
        description:
            'A critically important upland forest reserve and one of the world\'s top 200 ecoregions. Atewa is the source of three major rivers that supply drinking water to millions of Ghanaians. Home to the Critically Endangered Atewa Range tree toad and rare plant species found nowhere else on Earth.',
        imageUrl: '$_unsplash/photo-1448375240586-882707db888b?w=800&fit=crop',
        highlights: [
          'Headwaters of 3 major rivers',
          'Rare endemic species',
          'Upland forest ecosystem',
          'Ideal for serious naturalists',
        ],
        bestTime: 'November – February',
        difficulty: 'Moderate',
        entryFee: 'Permit required — contact Forestry Commission',
        tip: 'This reserve requires advance planning; contact the Ghana Forestry Commission for access permits.',
      ),
    ],
  ),
];
