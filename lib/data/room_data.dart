import 'package:projectmercury/models/furniture.dart';
import 'package:projectmercury/models/slot_setting.dart';
import 'package:projectmercury/models/store_item.dart';
import 'package:projectmercury/pages/homePage/room.dart';

/* Map<String, List<String>> wallOptions = { */
/*   "living room": [ */
/*     "Plain Wallpaper Option 1.png", */
/*     "Plain Wallpaper Option 2.png", */
/*     "Plain Wallpaper Option3.png", */
/*     "Plain Wallpaper Option7.png", */
/*   ], */
/*   "bedroom": [ */
/*     "Plain Wallpaper Option 1.png", */
/*     "Plain Wallpaper Option 2.png", */
/*     "Plain Wallpaper Option3.png", */
/*     "Plain Wallpaper Option7.png", */
/*   ], */
/*   "dining room": [ */
/*     "Plain Wallpaper Option 1.png", */
/*     "Plain Wallpaper Option 2.png", */
/*     "Plain Wallpaper Option3.png", */
/*     "Plain Wallpaper Option7.png", */
/*   ], */
/*   "kitchen": [ */
/*     "Plain Wallpaper Option 1.png", */
/*     "Decorative Wallpaper Option 3.png", */
/*     "Decorative Wallpaper Option 2.png", */
/*     "Decorative Wallpaper Option 1.png", */
/*   ], */
/*   "bathroom": [ */
/*     "Plain Wallpaper Option 1.png", */
/*     "Decorative Wallpaper Option 3.png", */
/*     "Decorative Wallpaper Option 2.png", */
/*     "Decorative Wallpaper Option 1.png", */
/*   ], */
/* }; */

/* Map<String, List<String>> floorOptions = { */
/*   "living room": [ */
/*     "Flooring Option 1.png", */
/*     "Flooring Option 2.png", */
/*     "Flooring Option 3.png", */
/*     "Flooring Option 4.png", */
/*   ], */
/*   "bedroom": [ */
/*     "Flooring Option 1.png", */
/*     "Flooring Option 2.png", */
/*     "Flooring Option 3.png", */
/*     "Flooring Option 4.png", */
/*   ], */
/*   "dining room": [ */
/*     "Flooring Option 1.png", */
/*     "Flooring Option 2.png", */
/*     "Flooring Option 3.png", */
/*     "Flooring Option 4.png", */
/*   ], */
/*   "kitchen": [ */
/*     "Flooring Option 1.png", */
/*     "Flooring Option 6.png", */
/*     "Flooring Option 7.png", */
/*     "Flooring option8.png", */
/*   ], */
/*   "bathroom": [ */
/*     "Flooring Option 1.png", */
/*     "Flooring Option 6.png", */
/*     "Flooring Option 7.png", */
/*     "Flooring option8.png", */
/*   ], */
/* }; */

//unused events: 1012, 1025, 2019, 1027, 2029, 2031
Room bedroom = Room(
  name: 'bedroom',
  wallTexture: 'Plain Wallpaper Option 2.png',
  floorTexture: 'wood_flooring3.png',
  width: 200,
  length: 210,
  height: 80,
  roomBehind: true,
  roomBeside: true,
  unlockOrder: 1,
  deployUtil: 6,
  items: [
    const Furniture(
      name: 'doorway',
      left: 180,
      right: 40,
      height: 60,
      layer: Layer.middle,
      direction: Direction.ne,
    ),
    //Bd1
    Slot(
      id: 'Bd1',
      order: 0,
      height: 70,
      left: 70,
      right: 130,
      layer: Layer.middle,
      icon: 'OUTLINE_bed',
      acceptables: const [
        Furniture(
          name: 'discount_bed',
          layer: Layer.middle,
          left: 70,
          right: 130,
          height: 70,
        ),
        Furniture(
          name: 'modern_bed',
          layer: Layer.middle,
          left: 68,
          right: 129,
          height: 64,
        ),
        Furniture(
          name: 'firm_bed',
          layer: Layer.middle,
          left: 57,
          right: 125,
          height: 80,
        ),
        Furniture(
          name: 'plush_bed',
          layer: Layer.middle,
          left: 55,
          right: 120,
          height: 85,
        ),
        Furniture(
          name: 'luxury_bed',
          layer: Layer.middle,
          left: 25,
          right: 100,
          height: 110,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [2035],
        doubleAfterEvent: [2032],
      ),
    ),
    //Bd2 End tables 1 (done)
    Slot(
      id: 'Bd2',
      order: 1,
      left: 60,
      right: 120,
      height: 35,
      layer: Layer.back,
      icon: 'OUTLINE_box',
      acceptables: const [
        Furniture(
          name: 'discount_end_table',
          layer: Layer.back,
          height: 30,
          left: 70,
          right: 125,
        ),
        Furniture(
          name: 'modern_end_table',
          direction: Direction.sw,
          layer: Layer.back,
          height: 30,
          left: 70,
          right: 125,
        ),
        Furniture(
          name: 'classic_end_table',
          layer: Layer.back,
          height: 30,
          left: 70,
          right: 125,
        ),
        Furniture(
          name: 'antique_end_table',
          layer: Layer.back,
          height: 30,
          left: 70,
          right: 125,
        ),
        Furniture(
          name: 'luxury_end_table',
          layer: Layer.back,
          height: 30,
          left: 70,
          right: 125,
        ),
      ],
      setting: const SlotSetting(
        overchargeRate: .25,
        delayEvent: [1000],
        doubleAfterEvent: [1025],
      ),
    ),
    //Bd2 End tables 2 (done)
    Slot(
      id: 'Bd2',
      order: 1,
      right: 200,
      left: 60,
      height: 35,
      layer: Layer.front,
      icon: 'OUTLINE_box',
      acceptables: const [
        Furniture(
          name: 'discount_end_table',
          layer: Layer.front,
          height: 30,
          left: 70,
          right: 200,
        ),
        Furniture(
          name: 'modern_end_table',
          direction: Direction.ne,
          layer: Layer.front,
          height: 30,
          left: 70,
          right: 200,
        ),
        Furniture(
          name: 'classic_end_table',
          layer: Layer.front,
          height: 30,
          left: 70,
          right: 200,
        ),
        Furniture(
          name: 'antique_end_table',
          layer: Layer.front,
          height: 30,
          left: 70,
          right: 200,
        ),
        Furniture(
          name: 'luxury_end_table',
          layer: Layer.front,
          height: 30,
          left: 70,
          right: 200,
        ),
      ],
      setting: const SlotSetting(
        overchargeRate: .25,
        delayEvent: [],
      ),
    ),
    // //Bd3 center (done)
    // Slot(
    //   id: 'Bd3',
    //   order: 2,
    //   height: 45,
    //   left: 130,
    //   right: 155,
    //   layer: Layer.front,
    //   icon: 'OUTLINE_long_W',
    //   acceptables: const [
    //     Furniture(
    //       name: 'vintage_wooden_trunk',
    //       layer: Layer.front,
    //       height: 45,
    //       left: 135,
    //       right: 155,
    //     ),
    //     Furniture(
    //       name: 'basic_rug',
    //       layer: Layer.floor,
    //       height: 100,
    //       left: 125,
    //       right: 100,
    //     ),
    //     Furniture(
    //       name: 'rustic_rug',
    //       layer: Layer.floor,
    //       height: 90,
    //       left: 150,
    //       right: 110,
    //     ),
    //     Furniture(
    //       name: 'plush_ottoman',
    //       layer: Layer.front,
    //       height: 45,
    //       left: 135,
    //       right: 155,
    //     ),
    //     Furniture(
    //       name: 'luxury_loveseat',
    //       direction: Direction.nw,
    //       layer: Layer.front,
    //       height: 50,
    //       left: 135,
    //       right: 145,
    //     ),
    //   ],
    // ),
    //Bd7 (TV) (done)
    Slot(
      id: 'Bd7',
      order: 2,
      height: 60,
      icon: 'OUTLINE_tv',
      layer: Layer.front,
      left: 215,
      right: 160,
      acceptables: const [
        Furniture(
          name: 'box_tv',
          left: 220,
          right: 145,
          layer: Layer.front,
          direction: Direction.se,
          height: 60,
        ),
        Furniture(
          name: 'modern_tv',
          left: 215,
          right: 150,
          layer: Layer.front,
          direction: Direction.se,
          height: 70,
        ),
        Furniture(
          name: 'vintage_tv',
          left: 210,
          right: 160,
          layer: Layer.front,
          direction: Direction.se,
          height: 65,
        ),
        Furniture(
          name: 'gaming_tv',
          layer: Layer.front,
          direction: Direction.se,
          height: 75,
          left: 210,
          right: 150,
        ),
        Furniture(
          name: 'mounted_vr_tv',
          layer: Layer.front,
          direction: Direction.se,
          height: 80,
          left: 205,
          right: 135,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [1023],
        doubleAfterEvent: [2000],
        randomItem: StoreItem(
          name: 'Automated DVD and Blue Ray Disk Organizer',
          price: 299.95,
          seller: Seller.modernElectronicsAndMore,
        ),
      ),
    ),
    //Bd6 dresser (done)
    Slot(
      id: 'Bd6',
      order: 3,
      height: 55,
      icon: 'OUTLINE_wall_NE',
      right: 240,
      left: 130,
      acceptables: const [
        Furniture(
          name: 'plastic_drawers',
          left: 130,
          right: 235,
          height: 60,
          layer: Layer.front,
          direction: Direction.sw,
        ),
        Furniture(
          name: 'pine_dresser',
          left: 130,
          right: 235,
          height: 60,
          layer: Layer.front,
          direction: Direction.sw,
        ),
        Furniture(
          name: 'sleek_dresser',
          left: 150,
          right: 230,
          height: 60,
          layer: Layer.front,
          direction: Direction.sw,
        ),
        Furniture(
          left: 140,
          right: 225,
          height: 75,
          name: 'mahogany_vanity',
          layer: Layer.front,
          direction: Direction.sw,
        ),
        Furniture(
          left: 140,
          right: 230,
          height: 60,
          name: 'rustic_dresser',
          layer: Layer.front,
          direction: Direction.sw,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [1007],
        doubleAfterEvent: [2020],
        wrongSlotItem: true,
      ),
    ),
    //Bd4
    Slot(
      id: 'Bd4',
      order: 4,
      height: 55,
      icon: 'OUTLINE_wall_NE',
      left: 130,
      right: 50,
      acceptables: const [
        Furniture(
          name: 'folding_desk',
          left: 130,
          right: 50,
          height: 60,
        ),
        Furniture(
          name: 'pine_desk',
          left: 130,
          right: 50,
          height: 60,
        ),
        Furniture(
          name: 'writing_desk',
          left: 130,
          right: 50,
          height: 60,
        ),
        Furniture(
          name: 'gaming_desk',
          left: 130,
          right: 50,
          height: 60,
        ),
        Furniture(
          name: 'mahogany_desk',
          left: 130,
          right: 50,
          height: 60,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [1018],
        doubleAfterEvent: [2030],
        overchargeRate: .5,
      ),
    ),
    // //Bd5
    // Slot(
    //   id: 'Bd5',
    //   order: 8,
    //   height: 30,
    //   icon: 'OUTLINE_box',
    //   left: 115,
    //   right: 45,
    //   acceptables: const [
    //     Furniture(
    //       name: 'old_computer',
    //       left: 120,
    //       right: 45,
    //       height: 30,
    //     ),
    //     Furniture(
    //       name: 'modern_laptop',
    //       left: 120,
    //       right: 40,
    //       height: 30,
    //     ),
    //     Furniture(
    //       name: 'basic_desktop_computer',
    //       left: 115,
    //       right: 40,
    //       height: 35,
    //     ),
    //     Furniture(
    //       name: 'file_organizer',
    //       left: 123,
    //       right: 32,
    //       height: 35,
    //     ),
    //     Furniture(
    //       name: 'gaming_computer',
    //       left: 115,
    //       right: 35,
    //       height: 40,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     delayEvent: [1018, 2033],
    //   ),
    // ),

    // //Bd8 corner 1 (done)
    // Slot(
    //   id: 'Bd8',
    //   order: 5,
    //   left: 38,
    //   right: 235,
    //   height: 55,
    //   icon: 'OUTLINE_tall',
    //   acceptables: const [
    //     Furniture(
    //       name: 'cat_tower',
    //       left: 40,
    //       right: 235,
    //       height: 55,
    //     ),
    //     Furniture(
    //       name: 'basic_pet_bed',
    //       left: 75,
    //       right: 240,
    //       height: 35,
    //     ),
    //     Furniture(
    //       name: 'luxury_dog_bed',
    //       left: 68,
    //       right: 240,
    //       height: 35,
    //     ),
    //     Furniture(
    //       name: 'plush_chair',
    //       direction: Direction.nw,
    //       left: 60,
    //       right: 230,
    //       height: 50,
    //     ),
    //     Furniture(
    //       name: 'luxury_chair',
    //       direction: Direction.nw,
    //       left: 50,
    //       right: 235,
    //       height: 50,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     delayEvent: [1023, 2000],
    //     scamStoreDuplicate: true,
    //   ),
    // ),
    //Bd9 Wall 1 (done)
    Slot(
      id: 'Bd9',
      order: 5,
      height: 40,
      icon: 'OUTLINE_wall_NW',
      left: 0,
      right: 120,
      acceptables: const [
        Furniture(
          name: 'bed_bug_picture',
          direction: Direction.nw,
          left: 10,
          right: 110,
          height: 40,
        ),
        Furniture(
          name: 'cowboy_print',
          direction: Direction.nw,
          left: 10,
          right: 115,
          height: 45,
        ),
        Furniture(
          name: 'abstract_painting',
          direction: Direction.nw,
          left: 10,
          right: 120,
          height: 45,
        ),
        Furniture(
          name: 'famous_impressionist_painting',
          direction: Direction.nw,
          left: 10,
          right: 125,
          height: 45,
        ),
        Furniture(
          name: 'rob_boss_mountain',
          direction: Direction.nw,
          left: 10,
          right: 120,
          height: 45,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [],
        doubleAfterEvent: [],
        randomItem: StoreItem(
          name: 'SMART Automated Door Opening System',
          seller: Seller.ellesElectronicEclectics,
          price: 529.99,
        ),
      ),
    ),
    //Bd10 Wall 2 (done)
    Slot(
      id: 'Bd10',
      order: 6,
      height: 40,
      icon: 'OUTLINE_wall_NE',
      left: 100,
      right: 10,
      layer: Layer.back,
      acceptables: const [
        Furniture(
          name: 'love_hope_picture',
          direction: Direction.ne,
          left: 100,
          right: 0,
          height: 40,
        ),
        Furniture(
          name: 'mounted_pike',
          direction: Direction.ne,
          left: 100,
          right: 0,
          height: 45,
        ),
        Furniture(
          name: 'impressionist_forest_painting',
          direction: Direction.ne,
          left: 95,
          right: 5,
          height: 45,
        ),
        Furniture(
          name: 'blue_abstract_painting',
          direction: Direction.ne,
          left: 90,
          right: 10,
          height: 45,
        ),
        Furniture(
          name: 'irises_painting',
          direction: Direction.ne,
          left: 95,
          right: 12,
          height: 40,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [2018],
        doubleAfterEvent: [2021, 2024],
      ),
    ),
    // //Bd11
    // Slot(
    //   id: 'Bd11',
    //   order: 4,
    //   height: 55,
    //   left: 38,
    //   right: 55,
    //   layer: Layer.back,
    //   icon: 'OUTLINE_tall',
    //   acceptables: const [
    //     // Furniture(
    //     //   name: 'potted_lily_plant',
    //     //   left: 50,
    //     //   right: 50,
    //     //   height: 50,
    //     // ),
    //     Furniture(
    //       name: 'golf_stand',
    //       left: 48,
    //       right: 48,
    //       height: 55,
    //     ),
    //     Furniture(
    //       name: 'vintage_corner_bookcase',
    //       left: 19,
    //       right: 35,
    //       height: 70,
    //     ),
    //     Furniture(
    //       name: 'corner_flower_cabinet',
    //       left: 19,
    //       right: 37,
    //       height: 70,
    //     ),
    //     Furniture(
    //       name: 'audio_system',
    //       direction: Direction.ne,
    //       left: 40,
    //       right: 55,
    //       height: 55,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     doubleCharge: true,
    //   ),
    // ),
  ],
);

Room livingroom = Room(
  name: 'living room',
  floorTexture: 'wood_flooring3.png',
  roomBehind: true,
  roomBeside: true,
  width: 200,
  length: 240,
  height: 80,
  unlockOrder: 2,
  deployUtil: 6,
  items: [
    const Furniture(
      name: 'doorway',
      direction: Direction.ne,
      left: 180,
      right: 40,
      height: 60,
    ),
    const Furniture(
      name: 'doorway',
      direction: Direction.nw,
      left: 25,
      right: 230,
      height: 60,
    ),
    // LR4_center (done)
    Slot(
      id: 'LR4',
      order: 0,
      height: 45,
      icon: 'OUTLINE_rug',
      acceptables: const [
        Furniture(
          name: 'basic_rug',
          layer: Layer.floor,
          height: 90,
          left: 120,
          right: 120,
        ),
        Furniture(
          name: 'animal_rug',
          layer: Layer.floor,
          height: 75,
          left: 150,
          right: 130,
        ),
        Furniture(
          name: 'classic_coffee_table',
          layer: Layer.middle,
          height: 60,
          left: 140,
          right: 160,
        ),
        Furniture(
          name: 'modern_coffee_table',
          layer: Layer.middle,
          height: 55,
          left: 140,
          right: 160,
        ),
        Furniture(
          name: 'luxury_modern_art_table',
          layer: Layer.middle,
          height: 65,
          left: 145,
          right: 160,
        ),
      ],
      left: 150,
      right: 155,
      setting: const SlotSetting(
        overchargeRate: .5,
      ),
    ),
    // LR1_sofa (done)
    Slot(
      id: 'LR1',
      order: 1,
      height: 65,
      icon: 'OUTLINE_sofa_NW',
      acceptables: const [
        Furniture(
          name: 'discount_sofa',
          direction: Direction.nw,
          height: 70,
          left: 55,
          right: 135,
        ),
        Furniture(
          name: 'leather_sofa',
          height: 60,
          left: 60,
          right: 140,
          direction: Direction.nw,
        ),
        Furniture(
          name: 'plush_sofa',
          direction: Direction.nw,
          height: 65,
          left: 55,
          right: 140,
        ),
        Furniture(
          name: 'modern_sofa',
          height: 60,
          left: 55,
          right: 140,
          direction: Direction.nw,
        ),
        Furniture(
          name: 'luxury_sofa',
          height: 65,
          left: 60,
          right: 140,
          direction: Direction.nw,
        ),
      ],
      left: 60,
      right: 140,
      setting: const SlotSetting(),
    ),
    // LR6_end_table (done)
    Slot(
      id: 'LR6',
      order: 2,
      height: 35,
      icon: 'OUTLINE_box',
      acceptables: const [
        Furniture(
          name: 'discount_end_table',
          height: 30,
          left: 80,
          right: 115,
        ),
        Furniture(
          name: 'classic_end_table',
          height: 30,
          left: 75,
          right: 120,
        ),
        Furniture(
          name: 'antique_end_table',
          height: 30,
          left: 80,
          right: 115,
        ),
        Furniture(
          name: 'modern_end_table',
          direction: Direction.sw,
          height: 30,
          left: 75,
          right: 120,
        ),
        Furniture(
          name: 'luxury_end_table',
          height: 30,
          left: 80,
          right: 115,
        ),
      ],
      left: 70,
      right: 115,
      setting: const SlotSetting(
        wrongSlotItem: true,
        //delayEvent: [1030],
        //doubleAfterEvent: [1026],
      ),
    ),
    // LR2_loveseat (done)
    Slot(
      id: 'LR2',
      order: 3,
      height: 55,
      icon: 'OUTLINE_loveseat_NE',
      acceptables: const [
        Furniture(
          name: 'discount_loveseat',
          direction: Direction.ne,
          layer: Layer.back,
          height: 55,
          left: 145,
          right: 95,
        ),
        Furniture(
          name: 'leather_loveseat',
          direction: Direction.nw,
          left: 145,
          height: 60,
          right: 95,
          layer: Layer.back,
        ),
        Furniture(
          name: 'plush_loveseat',
          height: 60,
          direction: Direction.ne,
          layer: Layer.back,
          left: 145,
          right: 95,
        ),
        Furniture(
          name: 'modern_loveseat',
          height: 50,
          direction: Direction.ne,
          layer: Layer.back,
          left: 145,
          right: 90,
        ),
        Furniture(
          name: 'luxury_loveseat',
          height: 50,
          direction: Direction.ne,
          layer: Layer.back,
          left: 145,
          right: 90,
        ),
      ],
      left: 145,
      right: 95,
      setting: const SlotSetting(
        overchargeRate: .25,
        delayEvent: [2011],
        doubleAfterEvent: [2015],
      ),
    ),
    // // LR9
    // Slot(
    //   id: 'LR9',
    //   order: 4,
    //   height: 60,
    //   icon: 'OUTLINE_tv',
    //   left: 215,
    //   right: 160,
    //   acceptables: const [
    //     Furniture(
    //       name: 'box_tv',
    //       direction: Direction.se,
    //       height: 60,
    //       left: 220,
    //       right: 155,
    //     ),
    //     Furniture(
    //       name: 'vintage_tv',
    //       direction: Direction.se,
    //       height: 65,
    //       left: 210,
    //       right: 170,
    //     ),
    //     Furniture(
    //       name: 'modern_tv',
    //       direction: Direction.se,
    //       height: 70,
    //       left: 215,
    //       right: 160,
    //     ),
    //     Furniture(
    //       name: 'gaming_tv',
    //       direction: Direction.se,
    //       height: 75,
    //       left: 210,
    //       right: 150,
    //     ),
    //     Furniture(
    //       name: 'mounted_vr_tv',
    //       direction: Direction.se,
    //       height: 80,
    //       left: 205,
    //       right: 145,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     scamStoreDuplicate: true,
    //     delayEvent: [2006],
    //     doubleAfterEvent: [2012],
    //   ),
    // ),
    // // LR3 (done)
    // Slot(
    //   id: 'LR3',
    //   order: 2,
    //   height: 45,
    //   icon: 'OUTLINE_chair_SW',
    //   acceptables: const [
    //     Furniture(
    //       name: 'beanbag_chair',
    //       direction: Direction.sw,
    //       layer: Layer.front,
    //       height: 40,
    //       left: 150,
    //       right: 230,
    //     ),
    //     Furniture(
    //       name: 'leather_chair',
    //       direction: Direction.sw,
    //       layer: Layer.front,
    //       height: 50,
    //       left: 150,
    //       right: 235,
    //     ),
    //     Furniture(
    //       name: 'plush_recliner',
    //       direction: Direction.sw,
    //       layer: Layer.front,
    //       height: 45,
    //       left: 150,
    //       right: 230,
    //     ),
    //     Furniture(
    //       name: 'modern_chair',
    //       direction: Direction.sw,
    //       layer: Layer.front,
    //       height: 40,
    //       left: 150,
    //       right: 230,
    //     ),
    //     Furniture(
    //       name: 'luxury_chair',
    //       direction: Direction.sw,
    //       layer: Layer.front,
    //       height: 50,
    //       left: 140,
    //       right: 230,
    //     ),
    //   ],
    //   left: 145,
    //   right: 230,
    // ),

    // LR5 (done)
    Slot(
      id: 'LR5',
      order: 4,
      height: 50,
      icon: 'OUTLINE_wall_NE',
      acceptables: const [
        Furniture(
          name: 'discount_bookcase',
          direction: Direction.ne,
          layer: Layer.floor,
          height: 65,
          left: 110,
          right: 45,
        ),
        Furniture(
          name: 'vintage_bookcase',
          direction: Direction.ne,
          layer: Layer.floor,
          height: 85,
          left: 100,
          right: 30,
        ),
        Furniture(
          name: 'upright_piano',
          direction: Direction.ne,
          layer: Layer.floor,
          height: 65,
          left: 125,
          right: 45,
        ),
        Furniture(
          name: 'fireplace',
          direction: Direction.ne,
          layer: Layer.floor,
          height: 85,
          left: 100,
          right: 35,
        ),
        Furniture(
          name: 'marble_fireplace',
          direction: Direction.ne,
          layer: Layer.floor,
          height: 60,
          left: 120,
          right: 45,
        ),
      ],
      left: 120,
      right: 50,
      setting: const SlotSetting(
        delayEvent: [2007],
        doubleAfterEvent: [2003],
      ),
    ),

    // // LR7 (done)
    // Slot(
    //   id: 'LR7',
    //   order: 6,
    //   height: 55,
    //   icon: 'OUTLINE_tall',
    //   acceptables: const [
    //     Furniture(
    //       name: 'potted_palm',
    //       height: 40,
    //       left: 55,
    //       right: 265,
    //     ),
    //     Furniture(
    //       name: 'model_plane_display',
    //       height: 50,
    //       left: 57,
    //       right: 267,
    //     ),
    //     Furniture(
    //       name: 'classic_standing_lamp',
    //       height: 55,
    //       left: 40,
    //       right: 275,
    //     ),
    //     Furniture(
    //       name: 'antique_table_vase',
    //       height: 45,
    //       left: 55,
    //       right: 270,
    //     ),
    //     Furniture(
    //       name: 'marble_statue',
    //       height: 60,
    //       left: 35,
    //       right: 265,
    //     ),
    //   ],
    //   left: 40,
    //   right: 270,
    // ),
    // LR8_C2 (done)
    Slot(
      id: 'LR8',
      order: 5,
      height: 55,
      icon: 'OUTLINE_tall',
      acceptables: const [
        Furniture(
          name: 'potted_chinese_evergreen',
          height: 35,
          left: 60,
          right: 60,
        ),
        Furniture(
          name: 'fishing_rod_rack',
          left: 60,
          right: 50,
          height: 60,
        ),
        Furniture(
          name: 'ceramic_art_display',
          left: 40,
          right: 55,
          height: 55,
        ),
        Furniture(
          name: 'classic_standing_lamp',
          left: 45,
          right: 60,
          height: 55,
        ),
        Furniture(
          name: 'audio_system',
          direction: Direction.ne,
          left: 40,
          right: 55,
          height: 55,
        ),
      ],
      left: 38,
      right: 55,
      setting: const SlotSetting(
        randomItem: StoreItem(
          name: 'Automated Litter Box',
          price: 699.99,
          seller: Seller.jiaHuisFurnitureDepot,
        ),
        delayEvent: [1020],
        doubleAfterEvent: [2008, 1005],
      ),
    ),

    // // LR10 (done)
    // Slot(
    //   id: 'LR10',
    //   order: 8,
    //   height: 40,
    //   icon: 'OUTLINE_wall_NW',
    //   acceptables: const [
    //     Furniture(
    //       name: 'live_laugh_love',
    //       direction: Direction.nw,
    //       layer: Layer.back,
    //       left: 10,
    //       right: 130,
    //       height: 30,
    //     ),
    //     Furniture(
    //       name: 'canyon_print',
    //       direction: Direction.nw,
    //       layer: Layer.back,
    //       left: 5,
    //       right: 130,
    //       height: 50,
    //     ),
    //     Furniture(
    //       name: 'rob_boss_painting',
    //       direction: Direction.nw,
    //       layer: Layer.back,
    //       left: 10,
    //       right: 130,
    //       height: 50,
    //     ),
    //     Furniture(
    //       name: 'modern_wall_art',
    //       direction: Direction.nw,
    //       layer: Layer.back,
    //       left: 0,
    //       right: 120,
    //       height: 65,
    //     ),
    //     Furniture(
    //       name: 'antique_impressionist_painting',
    //       direction: Direction.nw,
    //       layer: Layer.back,
    //       left: 5,
    //       right: 130,
    //       height: 50,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     delayEvent: [1005],
    //     doubleCharge: true,
    //     doubleAfterEvent: [2005],
    //     randomItem: StoreItem(
    //       name: 'Bear Statue',
    //       seller: Seller.donsPawnshop,
    //       price: 899.99,
    //     ),
    //   ),
    //   left: 10,
    //   right: 130,
    // ),
    // // LR11 (done)
    // Slot(
    //   id: 'LR11',
    //   order: 10,
    //   height: 40,
    //   icon: 'OUTLINE_box',
    //   acceptables: const [
    //     Furniture(
    //       name: 'potted_fiscus_tree',
    //       direction: Direction.ne,
    //       layer: Layer.front,
    //       height: 70,
    //       left: 197,
    //       right: 245,
    //     ),
    //     Furniture(
    //       name: 'easel',
    //       direction: Direction.se,
    //       height: 50,
    //       left: 220,
    //       right: 265,
    //     ),
    //     Furniture(
    //       name: 'puzzle_table',
    //       direction: Direction.ne,
    //       layer: Layer.front,
    //       height: 70,
    //       left: 197,
    //       right: 245,
    //     ),
    //     Furniture(
    //       name: 'guitar_stand',
    //       direction: Direction.se,
    //       height: 60,
    //       left: 210,
    //       right: 265,
    //     ),
    //     Furniture(
    //       name: 'poker_table',
    //       layer: Layer.front,
    //       height: 65,
    //       left: 190,
    //       right: 230,
    //     ),
    //   ],
    //   left: 225,
    //   right: 275,
    //   setting: const SlotSetting(
    //     delayEvent: [1020, 2008],
    //     // doubleCharge: true,
    //     doubleAfterEvent: [1005, 2005],
    //   ),
    // ),
  ],
);

Room bathroom = Room(
  name: 'bathroom',
  floorTexture: 'tile_floor1.png',
  roomBeside: true,
  width: 200,
  length: 100,
  height: 80,
  unlockOrder: 3,
  deployUtil: 3,
  items: [
    // Ba1
    Slot(
      id: 'Ba1',
      order: 0,
      icon: 'OUTLINE_bath',
      left: 55,
      right: 70,
      height: 60,
      acceptables: [
        const Furniture(
          name: 'discount_bathtub',
          left: 60,
          right: 75,
          height: 50,
        ),
        const Furniture(
          name: 'classic_combination_shower',
          left: 12,
          right: 38,
          height: 100,
        ),
        const Furniture(
          name: 'basic_shower_stall',
          direction: Direction.ne,
          left: 15,
          right: 38,
          height: 90,
        ),
        const Furniture(
          name: 'modern_shower',
          left: 20,
          right: 50,
          height: 90,
        ),
        const Furniture(
          name: 'luxury_bathtub',
          left: 33,
          right: 65,
          height: 87,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [1010, 2001],
      ),
    ),
    // Ba2
    Slot(
      id: 'Ba2',
      order: 2,
      icon: 'OUTLINE_toilet',
      acceptables: [
        const Furniture(
          name: 'cheap_toilet',
          direction: Direction.sw,
          left: 150,
          right: 135,
          height: 35,
        ),
        const Furniture(
          name: 'porcelain_toilet',
          direction: Direction.sw,
          left: 150,
          right: 135,
          height: 45,
        ),
        const Furniture(
          name: 'black_porcelain_toilet',
          direction: Direction.sw,
          left: 150,
          right: 132,
          height: 40,
        ),
        const Furniture(
          name: 'trendy_blue_toilet',
          direction: Direction.sw,
          left: 120,
          right: 115,
          height: 75,
        ),
        const Furniture(
          name: 'luxury_gold_toilet',
          direction: Direction.sw,
          left: 120,
          right: 115,
          height: 75,
        ),
      ],
      left: 150,
      right: 130,
      height: 40,
      setting: const SlotSetting(
        overchargeRate: .25,
        delayEvent: [1008, 2030],
      ),
    ),
    //Ba3
    Slot(
      id: 'Ba3',
      order: 3,
      left: 220,
      right: 90,
      height: 50,
      icon: 'OUTLINE_wall_NW',
      acceptables: [
        const Furniture(
          name: 'classic_pine_cabinet',
          left: 222,
          right: 95,
          height: 55,
          direction: Direction.se,
        ),
        const Furniture(
          name: 'sleek_modern_cabinet',
          direction: Direction.se,
          left: 222,
          right: 95,
          height: 55,
        ),
        const Furniture(
          name: 'plastic_drawers',
          direction: Direction.se,
          left: 220,
          right: 95,
          height: 55,
        ),
        const Furniture(
          name: 'walnut_vanity',
          direction: Direction.se,
          left: 222,
          right: 95,
          height: 55,
        ),
        const Furniture(
          name: 'luxury_vanity',
          direction: Direction.se,
          left: 224,
          right: 90,
          height: 52,
        ),
      ],
      setting: const SlotSetting(
        randomItem: StoreItem(
          name: 'Go-Kart',
          price: 699.99,
          seller: Seller.matildaMaes,
        ),
      ),
    ),
    // Ba4
    Slot(
      id: 'Ba4',
      order: 1,
      left: 190,
      right: 50,
      height: 50,
      icon: 'OUTLINE_long_E',
      acceptables: [
        const Furniture(
          name: 'basic_free-standing_sink',
          direction: Direction.ne,
          left: 130,
          right: 40,
          height: 60,
        ),
        const Furniture(
          name: 'classic_pine_sink',
          direction: Direction.ne,
          left: 135,
          right: 37,
          height: 75,
        ),
        const Furniture(
          name: 'sleek_modern_sink',
          direction: Direction.ne,
          left: 135,
          right: 30,
          height: 85,
        ),
        const Furniture(
          name: 'vintage_sink',
          direction: Direction.ne,
          left: 125,
          right: 30,
          height: 85,
        ),
        const Furniture(
          name: 'luxury_sink',
          direction: Direction.ne,
          left: 145,
          right: 45,
          height: 65,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [1024, 2014],
        scamStoreDuplicate: true,
      ),
    ),
  ],
);

Room kitchen = Room(
  name: 'kitchen',
  wallTexture: 'Plain Wallpaper Option3.png',
  floorTexture: 'tile_floor1.png',
  roomBehind: true,
  width: 170,
  length: 190,
  height: 80,
  unlockOrder: 4,
  deployUtil: 5,
  items: [
    const Furniture(
      name: 'doorway',
      direction: Direction.ne,
      left: 140,
      right: 40,
      height: 60,
    ),
    const Furniture(
      name: 'window',
      direction: Direction.nw,
      left: 10,
      right: 60,
      height: 50,
    ),

    // // K1
    // Slot(
    //   id: 'K1',
    //   order: 0,
    //   icon: 'OUTLINE_kitchen_cabinet_NW',
    //   left: 63,
    //   right: 210,
    //   height: 35,
    //   acceptables: [
    //     const Furniture(
    //       name: 'kitchen_cabinet_beige',
    //       left: 63,
    //       right: 210,
    //       height: 35,
    //       direction: Direction.nw,
    //     ),
    //     const Furniture(
    //       name: 'walnut_kitchen_counter',
    //       direction: Direction.nw,
    //       left: 63,
    //       right: 210,
    //       height: 35,
    //     ),
    //     const Furniture(
    //       name: 'black_walnut_kitchen_counter',
    //       left: 63,
    //       right: 210,
    //       height: 35,
    //       direction: Direction.nw,
    //     ),
    //     const Furniture(
    //       name: 'pine_kitchen_counter',
    //       left: 63,
    //       right: 210,
    //       height: 35,
    //       direction: Direction.nw,
    //     ),
    //     const Furniture(
    //       name: 'mahogany_kitchen_counter',
    //       left: 63,
    //       right: 210,
    //       height: 35,
    //       direction: Direction.nw,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     delayEvent: [2004, 2022],
    //   ),
    // ),

    // K1_cabinets
    Slot(
      id: 'K1',
      order: 0,
      icon: 'OUTLINE_kitchen_cabinet_NW',
      left: 63,
      right: 231,
      height: 35,
      acceptables: [
        const Furniture(
          name: 'kitchen_cabinet_beige',
          left: 63,
          right: 231,
          height: 35,
          direction: Direction.nw,
        ),
        const Furniture(
          name: 'walnut_kitchen_counter',
          left: 63,
          right: 231,
          height: 35,
          direction: Direction.nw,
        ),
        const Furniture(
          name: 'black_walnut_kitchen_counter',
          left: 63,
          right: 231,
          height: 35,
          direction: Direction.nw,
        ),
        const Furniture(
          name: 'pine_kitchen_counter',
          left: 63,
          right: 231,
          height: 35,
          direction: Direction.nw,
        ),
        const Furniture(
          name: 'mahogany_kitchen_counter',
          left: 63,
          right: 231,
          height: 35,
          direction: Direction.nw,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [2004],
        doubleAfterEvent: [2022],
      ),
    ),
    // K4_oven
    Slot(
      id: 'K4',
      order: 1,
      icon: 'OUTLINE_stove',
      left: 58,
      right: 128,
      height: 35,
      acceptables: [
        const Furniture(
          name: 'beige_stove',
          direction: Direction.nw,
          height: 35,
          left: 63,
          right: 128,
        ),
        const Furniture(
          name: 'steel_stove',
          direction: Direction.nw,
          height: 35,
          left: 63,
          right: 128,
        ),
        const Furniture(
          name: 'black_stove',
          direction: Direction.nw,
          height: 35,
          left: 63,
          right: 128,
        ),
        const Furniture(
          name: 'platinum_stove',
          direction: Direction.nw,
          height: 35,
          left: 63,
          right: 128,
        ),
        const Furniture(
          name: 'luxury_stove',
          direction: Direction.nw,
          height: 35,
          left: 63,
          right: 128,
        ),
      ],
      setting: const SlotSetting(
        overchargeRate: .5,
      ),
    ),
    // // K7
    // Slot(
    //   id: 'K7',
    //   order: 3,
    //   icon: 'OUTLINE_box',
    //   left: 48,
    //   right: 137,
    //   height: 25,
    //   acceptables: [
    //     const Furniture(
    //       name: 'toaster',
    //       height: 20,
    //       left: 57,
    //       right: 140,
    //     ),
    //     const Furniture(
    //       name: 'ceramic_canisters',
    //       height: 20,
    //       left: 55,
    //       right: 137,
    //     ),
    //     const Furniture(
    //       name: 'spice_rack',
    //       height: 20,
    //       left: 55,
    //       right: 138,
    //     ),
    //     const Furniture(
    //       name: 'texas_waffle_maker',
    //       left: 65,
    //       right: 144,
    //       height: 12,
    //     ),
    //     const Furniture(
    //       name: 'air_fryer',
    //       left: 52,
    //       right: 137,
    //       height: 24,
    //     ),
    //   ],
    // ),
    // K2
    Slot(
      id: 'K2',
      order: 2,
      icon: 'OUTLINE_fridge',
      left: 25,
      right: 160,
      height: 65,
      acceptables: [
        const Furniture(
          name: 'fridge_beige',
          left: 32,
          right: 162,
          height: 60,
        ),
        const Furniture(
          name: 'stainless_fridge',
          left: 27,
          right: 157,
          height: 70,
        ),
        const Furniture(
          name: 'black_stainless_fridge',
          left: 27,
          right: 157,
          height: 70,
        ),
        const Furniture(
          name: 'smart_fridge',
          left: 28,
          right: 156,
          height: 70,
        ),
        const Furniture(
          name: 'french_fridge',
          left: 35,
          right: 162,
          height: 65,
        ),
      ],
      setting: const SlotSetting(
        overchargeRate: 0.25,
      ),
    ),
    // K6
    Slot(
      id: 'K6',
      order: 3,
      icon: 'OUTLINE_kitchen_island',
      left: 120,
      right: 130,
      height: 70,
      acceptables: [
        const Furniture(
          name: 'kitchen_island_beige',
          height: 70,
          left: 120,
          right: 130,
        ),
        const Furniture(
          name: 'pine_kitchen_island',
          height: 70,
          left: 120,
          right: 130,
        ),
        const Furniture(
          name: 'kitchen_island_walnut',
          height: 70,
          left: 120,
          right: 130,
        ),
        const Furniture(
          name: 'black_walnut_kitchen_island',
          height: 70,
          left: 120,
          right: 130,
        ),
        const Furniture(
          name: 'kitchen_island_mahogany',
          height: 70,
          left: 130,
          right: 130,
        ),
      ],
      setting: const SlotSetting(
        wrongSlotItem: true,
        delayEvent: [
          1035,
        ],
      ),
    ),
    // // K5
    // Slot(
    //   id: 'K5',
    //   order: 5,
    //   icon: 'OUTLINE_box',
    //   left: 99,
    //   right: 65,
    //   height: 35,
    //   acceptables: [
    //     const Furniture(
    //       name: 'round_sink',
    //       height: 34,
    //       left: 106,
    //       right: 67,
    //     ),
    //     const Furniture(
    //       name: 'stainless_steel_sink',
    //       height: 34,
    //       left: 106,
    //       right: 67,
    //     ),
    //     const Furniture(
    //       name: 'black_double_sink',
    //       height: 37,
    //       left: 108,
    //       right: 64,
    //     ),
    //     const Furniture(
    //       name: 'platinum_double_sink',
    //       height: 38,
    //       left: 109,
    //       right: 63,
    //     ),
    //     const Furniture(
    //       name: 'luxury_marble_sink',
    //       height: 34,
    //       left: 106,
    //       right: 67,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     delayEvent: [1013, 1028, 1029],
    //   ),
    // ),
    // K11
    Slot(
      id: 'K11',
      order: 6,
      icon: 'OUTLINE_box',
      left: 200,
      right: 230,
      height: 35,
      acceptables: const [
        Furniture(
          name: 'potted_castiron_plant',
          left: 198,
          right: 223,
          height: 45,
        ),
        Furniture(
          name: 'tea_cart',
          direction: Direction.ne,
          left: 203,
          right: 222,
          height: 40,
        ),
        Furniture(
          name: 'barbecue',
          direction: Direction.se,
          left: 203,
          right: 213,
          height: 40,
        ),
        Furniture(
          name: 'table_fruit',
          left: 211,
          right: 232,
          height: 29,
        ),
        Furniture(
          name: 'ice_cream_maker',
          left: 200,
          right: 227,
          height: 42,
        ),
      ],
      setting: const SlotSetting(
        doubleCharge: true,
      ),
    ),
    // K8
    Slot(
      id: 'K8',
      order: 7,
      icon: 'OUTLINE_box',
      left: 48,
      right: 95,
      height: 25,
      acceptables: [
        const Furniture(
          name: 'microwave',
          height: 23,
          left: 52,
          right: 95,
        ),
        const Furniture(
          name: 'small_popcorn_maker',
          height: 27,
          left: 46,
          right: 96,
        ),
        const Furniture(
          name: 'coffee_machine',
          height: 23,
          left: 50,
          right: 96,
        ),
        const Furniture(
          name: 'knife_set',
          height: 18,
          left: 55,
          right: 102,
        ),
        const Furniture(
          name: 'tea_set',
          height: 23,
          left: 56,
          right: 90,
        ),
      ],
      setting: const SlotSetting(
        falseCharge: StoreItem(
          name: 'Heated Swimming Pool',
          price: 3225.99,
          seller: Seller.jiaHuisFurnitureDepot,
        ),
      ),
    ),
    // // K9
    // Slot(
    //   id: 'K9',
    //   order: 8,
    //   icon: 'OUTLINE_box',
    //   left: 200,
    //   right: 90,
    //   height: 35,
    //   layer: Layer.front,
    //   acceptables: const [
    //     Furniture(
    //       name: 'vintage_bookcase',
    //       direction: Direction.ne,
    //       left: 182,
    //       right: 47,
    //       height: 55,
    //     ),
    //     Furniture(
    //       name: 'bakers_rack',
    //       direction: Direction.ne,
    //       left: 193,
    //       right: 57,
    //       height: 50,
    //     ),
    //     Furniture(
    //       name: 'wire_shelves',
    //       direction: Direction.ne,
    //       left: 182,
    //       right: 50,
    //       height: 55,
    //     ),
    //     Furniture(
    //       name: 'china_cabinet',
    //       direction: Direction.ne,
    //       left: 182,
    //       right: 48,
    //       height: 55,
    //     ),
    //     Furniture(
    //       name: 'tv_cabinet',
    //       direction: Direction.ne,
    //       left: 198,
    //       right: 56,
    //       height: 39,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     scamStoreDuplicate: true,
    //     delayEvent: [1029, 1015],
    //   ),
    // ),
    // K10
    Slot(
      id: 'K10',
      order: 8,
      icon: 'OUTLINE_box',
      left: 30,
      right: 10,
      height: 35,
      acceptables: const [
        Furniture(
          name: 'fruit_flower_painting',
          left: 38,
          right: 26,
          height: 35,
        ),
        Furniture(
          name: 'rooster_portrait',
          left: 40,
          right: 26,
          height: 35,
        ),
        Furniture(
          name: 'mounted_planters',
          left: 36,
          right: 22,
          height: 40,
        ),
        Furniture(
          name: 'still_life_painting',
          left: 38,
          right: 26,
          height: 35,
        ),
        Furniture(
          name: 'pasta_picture',
          left: 42,
          right: 26,
          height: 35,
        ),
      ],
      setting: const SlotSetting(
        randomItem: StoreItem(
          name: 'Extra Large Trampoline',
          seller: Seller.tinasToysForTinyTots,
          price: 479,
        ),
      ),
    ),

    // K3
    Slot(
      id: 'K3',
      order: 9,
      icon: 'OUTLINE_box',
      left: 132,
      right: 62,
      height: 40,
      acceptables: const [
        Furniture(
          name: 'beige_dishwasher',
          height: 32,
          left: 129,
          right: 66,
        ),
        Furniture(
          name: 'steel_dishwasher',
          height: 32,
          left: 129,
          right: 66,
        ),
        Furniture(
          name: 'black_dishwasher',
          height: 32,
          left: 129,
          right: 66,
        ),
        Furniture(
          name: 'platinum_dishwasher',
          height: 32,
          left: 129,
          right: 66,
        ),
        Furniture(
          name: 'luxury_dishwasher',
          height: 32,
          left: 129,
          right: 66,
        ),
      ],
    ),
  ],
);

Room diningroom = Room(
  name: 'dining room',
  wallTexture: 'Plain Wallpaper Option3.png',
  floorTexture: 'wood_flooring3.png',
  roomBehind: true,
  width: 170,
  length: 190,
  height: 80,
  unlockOrder: 5,
  deployUtil: 5,
  items: [
    const Furniture(
      name: 'window',
      direction: Direction.nw,
      left: 10,
      right: 110,
      height: 50,
    ),
    const Furniture(
      name: 'doorway',
      direction: Direction.ne,
      left: 110,
      right: 42,
      height: 60,
    ),

    // // D2
    // Slot(
    //   id: 'D2',
    //   order: 2,
    //   height: 35,
    //   icon: 'OUTLINE_box',
    //   left: 100,
    //   right: 140,
    //   acceptables: const [
    //     Furniture(
    //       name: 'dining_chair_folding',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 100,
    //       right: 140,
    //     ),
    //     Furniture(
    //       name: 'dining_chair_pine',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 100,
    //       right: 140,
    //     ),
    //     Furniture(
    //       name: 'dining_chair_rustic',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 100,
    //       right: 140,
    //     ),
    //     Furniture(
    //       name: 'dining_chair_modern',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 100,
    //       right: 140,
    //     ),
    //     Furniture(
    //       name: 'dining_chair_mahogany',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 100,
    //       right: 140,
    //     )
    //   ],
    //   setting: const SlotSetting(
    //     overchargeRate: .25,
    //     delayEvent: [2010, 1003],
    //   ),
    // ),

    // D1 Dining Table
    Slot(
      id: 'D1',
      order: 1,
      height: 60,
      icon: 'OUTLINE_table_NE',
      acceptables: const [
        Furniture(
          name: 'dining_table_pine',
          left: 120,
          right: 130,
          height: 60,
        ),
        Furniture(
          name: 'dining_table_rustic',
          left: 120,
          right: 130,
          height: 60,
        ),
        Furniture(
          name: 'dining_table_mahogany',
          left: 120,
          right: 130,
          height: 60,
        ),
        Furniture(
          name: 'foldable_table',
          left: 120,
          right: 130,
          height: 60,
        ),
        Furniture(
          name: 'modern_dining_table',
          left: 120,
          right: 130,
          height: 60,
        ),
      ],
      left: 120,
      right: 130,
      setting: const SlotSetting(
        delayEvent: [2017, 1032],
      ),
    ),
    // D2
    Slot(
      id: 'D2',
      order: 2,
      height: 35,
      icon: 'OUTLINE_box',
      left: 160,
      right: 140,
      acceptables: const [
        Furniture(
          name: 'dining_chair_folding',
          direction: Direction.se,
          height: 35,
          left: 160,
          right: 140,
        ),
        Furniture(
          name: 'dining_chair_pine',
          height: 35,
          direction: Direction.se,
          left: 160,
          right: 140,
        ),
        Furniture(
          name: 'dining_chair_rustic',
          height: 35,
          direction: Direction.se,
          left: 160,
          right: 140,
        ),
        Furniture(
          name: 'dining_chair_modern',
          direction: Direction.se,
          height: 35,
          left: 160,
          right: 140,
        ),
        Furniture(
          name: 'dining_chair_mahogany',
          height: 35,
          direction: Direction.se,
          left: 160,
          right: 140,
        )
      ],
      setting: const SlotSetting(
        overchargeRate: .25,
        delayEvent: [2010, 1003],
      ),
    ),
    // D3
    Slot(
      id: 'D3',
      order: 0,
      height: 20,
      icon: 'OUTLINE_rug',
      acceptables: const [
        Furniture(
          name: 'woven_rug',
          height: 80,
          left: 125,
          right: 110,
        ),
        Furniture(
          name: 'antique_rug',
          height: 80,
          left: 125,
          right: 110,
        ),
        Furniture(
          name: 'rustic_rug',
          height: 80,
          left: 125,
          right: 100,
        ),
        Furniture(
          name: 'plush_rug',
          height: 80,
          left: 125,
          right: 100,
        ),
        Furniture(
          name: 'modern_patterned_rug',
          height: 80,
          left: 125,
          right: 100,
        ),
      ],
      left: 130,
      right: 130,
    ),
    // // D4
    // Slot(
    //   id: 'D4',
    //   order: 6,
    //   height: 40,
    //   icon: 'OUTLINE_box',
    //   acceptables: const [
    //     Furniture(
    //       name: 'snake_plant',
    //       height: 30,
    //       left: 62,
    //       right: 238,
    //       layer: Layer.middle,
    //     ),
    //     Furniture(
    //       name: 'standing_lamp',
    //       height: 55,
    //       left: 30,
    //       right: 222,
    //       layer: Layer.middle,
    //     ),
    //     Furniture(
    //       name: 'ship_display_table',
    //       height: 35,
    //       left: 64,
    //       right: 231,
    //       layer: Layer.middle,
    //     ),
    //     Furniture(
    //       name: 'potpourri_table',
    //       height: 35,
    //       left: 62,
    //       right: 233,
    //       layer: Layer.middle,
    //     ),
    //     Furniture(
    //       name: 'bonsai_tree',
    //       height: 45,
    //       left: 55,
    //       right: 220,
    //       layer: Layer.middle,
    //     ),
    //   ],
    //   left: 60,
    //   right: 225,
    //   setting: const SlotSetting(
    //     overchargeRate: .5,
    //   ),
    // ),
    // D5
    Slot(
      id: 'D5',
      order: 4,
      height: 40,
      icon: 'OUTLINE_box',
      left: 198,
      right: 65,
      acceptables: const [
        Furniture(
          name: 'fig_tree',
          left: 185,
          right: 45,
          height: 55,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'woven_baskets',
          left: 210,
          right: 67,
          height: 30,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'potpourri_table',
          left: 200,
          right: 62,
          height: 45,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'sports_display',
          left: 185,
          right: 53,
          height: 55,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'corner_tv',
          left: 185,
          right: 65,
          height: 50,
          layer: Layer.middle,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [2013, 1009],
      ),
    ),
    // D6
    Slot(
      id: 'D6',
      order: 5,
      left: 60,
      right: 65,
      height: 35,
      icon: 'OUTLINE_box',
      acceptables: const [
        Furniture(
          name: 'plastic_drawers',
          direction: Direction.ne,
          height: 40,
          left: 52,
          right: 59,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'half_sized_bookcase',
          direction: Direction.ne,
          height: 45,
          left: 55,
          right: 55,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'aquarium',
          direction: Direction.ne,
          height: 45,
          left: 60,
          right: 53,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'antique_hutch',
          height: 65,
          left: 33,
          right: 42,
          layer: Layer.middle,
        ),
        Furniture(
          name: 'modern_liquor_cabinet',
          direction: Direction.ne,
          height: 55,
          left: 58,
          right: 50,
          layer: Layer.middle,
        ),
      ],
      setting: const SlotSetting(
        wrongSlotItem: true,
        delayEvent: [1011, 2025],
      ),
    ),
    // D7
    Slot(
      id: 'D7',
      order: 3,
      height: 40,
      icon: 'OUTLINE_box',
      acceptables: const [
        Furniture(
          name: 'dog_statue',
          height: 40,
          left: 205,
          right: 225,
        ),
        Furniture(
          name: 'potted_monstera_plant',
          height: 45,
          left: 194,
          right: 205,
        ),
        Furniture(
          name: 'aromatic_end_table',
          height: 35,
          left: 198,
          right: 222,
        ),
        Furniture(
          name: 'bronze_horse',
          height: 45,
          left: 193,
          right: 225,
        ),
        Furniture(
          name: 'standing_lamp',
          height: 55,
          left: 183,
          right: 220,
        ),
      ],
      left: 198,
      right: 225,
    ),
    // D8
    Slot(
      id: 'D8',
      order: 6,
      height: 35,
      icon: 'OUTLINE_wall_NW',
      left: 20,
      right: 170,
      acceptables: const [
        Furniture(
          name: 'black_white_color_added',
          direction: Direction.nw,
          left: 15,
          right: 170,
          height: 45,
          layer: Layer.back,
        ),
        Furniture(
          name: 'knickerbocker_hotel',
          direction: Direction.nw,
          left: 20,
          right: 170,
          height: 40,
          layer: Layer.back,
        ),
        Furniture(
          name: 'forrest_reflection_painting',
          direction: Direction.nw,
          left: 20,
          right: 170,
          height: 40,
          layer: Layer.back,
        ),
        Furniture(
          name: 'brass_band',
          direction: Direction.nw,
          left: 20,
          right: 170,
          height: 40,
          layer: Layer.back,
        ),
        Furniture(
          name: 'renaissance_painting',
          direction: Direction.nw,
          left: 20,
          right: 170,
          height: 40,
          layer: Layer.back,
        ),
      ],
      setting: const SlotSetting(
        randomItem: StoreItem(
          name: 'Inflatable Bouncy Castle in Princess Pink',
          price: 425.95,
          seller: Seller.theFurnitureSpot,
        ),
      ),
    ),
    // // D9
    // Slot(
    //   id: 'D9',
    //   order: 7,
    //   height: 35,
    //   icon: 'OUTLINE_wall_NW',
    //   left: 20,
    //   right: 70,
    //   acceptables: const [
    //     Furniture(
    //       name: 'what_you_eat_picture',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 20,
    //       right: 70,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'idyll_of_the_south',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 20,
    //       right: 65,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'red_peonies',
    //       direction: Direction.nw,
    //       height: 40,
    //       left: 20,
    //       right: 70,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'longhorn_print',
    //       direction: Direction.nw,
    //       height: 35,
    //       left: 20,
    //       right: 60,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'abstract_acrylic',
    //       direction: Direction.nw,
    //       height: 40,
    //       left: 20,
    //       right: 60,
    //       layer: Layer.back,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     delayEvent: [2026, 1001],
    //     scamStoreDuplicate: true,
    //   ),
    // ),
    // D10
    Slot(
      id: 'D10',
      order: 7,
      height: 35,
      icon: 'OUTLINE_wall_NE',
      left: 55,
      right: 20,
      acceptables: const [
        Furniture(
          name: 'food_for_soul_picture',
          height: 35,
          left: 60,
          right: 20,
        ),
        Furniture(
          name: 'sam_houston_pistol_display',
          height: 35,
          left: 65,
          right: 20,
        ),
        Furniture(
          name: 'flower_vase_painting',
          height: 35,
          left: 60,
          right: 20,
        ),
        Furniture(
          name: 'great_wave',
          height: 35,
          left: 65,
          right: 20,
        ),
        Furniture(
          name: 'silk_tapestry',
          height: 35,
          left: 65,
          right: 20,
          layer: Layer.back,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [1002, 1031],
        doubleCharge: true,
      ),
    ),
    // // D11
    // Slot(
    //   id: 'D11',
    //   order: 8,
    //   height: 35,
    //   icon: 'OUTLINE_wall_NE',
    //   left: 150,
    //   right: 20,
    //   acceptables: const [
    //     Furniture(
    //       name: 'where_heart_is_picture',
    //       height: 35,
    //       left: 150,
    //       right: 20,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'jersey_display',
    //       height: 35,
    //       left: 145,
    //       right: 20,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'scotland_painting',
    //       height: 35,
    //       left: 150,
    //       right: 20,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'abstract_canvas_painting',
    //       height: 35,
    //       left: 150,
    //       right: 20,
    //       layer: Layer.back,
    //     ),
    //     Furniture(
    //       name: 'impressionist_masterpiece',
    //       height: 35,
    //       left: 145,
    //       right: 20,
    //       layer: Layer.back,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     doubleCharge: true,
    //   ),
    // ),
  ],
);

Room garage = Room(
  name: 'garage',
  wallTexture: 'Plain Wallpaper Option 1.png',
  floorTexture: 'Flooring Option 5.png',
  width: 170,
  length: 170,
  height: 80,
  unlockOrder: 6,
  deployUtil: 5,
  items: [
    const Furniture(
      name: 'garage_door',
      height: 75,
      left: 20,
      right: 100,
    ),
    // Ga1
    Slot(
      id: 'Ga1',
      order: 0,
      height: 35,
      icon: 'OUTLINE_box',
      left: 70,
      right: 65,
      acceptables: const [
        Furniture(
          name: 'beige_washer_dryer',
          direction: Direction.ne,
          height: 45,
          left: 67,
          right: 58,
        ),
        Furniture(
          name: 'steel_washer_dryer',
          direction: Direction.ne,
          height: 45,
          left: 67,
          right: 58,
        ),
        Furniture(
          name: 'black_washer_dryer',
          direction: Direction.ne,
          height: 45,
          left: 67,
          right: 58,
        ),
        Furniture(
          name: 'platinum_washer_dryer',
          direction: Direction.ne,
          height: 45,
          left: 67,
          right: 58,
        ),
        Furniture(
          name: 'luxury_washer_dryer',
          direction: Direction.ne,
          height: 45,
          left: 67,
          right: 58,
        ),
      ],
      setting: const SlotSetting(
        overchargeRate: .5,
      ),
    ),

    // Ga2
    Slot(
      id: 'Ga2',
      order: 2,
      height: 35,
      icon: 'OUTLINE_box',
      left: 60,
      right: 200,
      acceptables: const [
        Furniture(
          name: 'standard_treadmill',
          height: 50,
          left: 65,
          right: 200,
        ),
        Furniture(
          name: 'sewing_machine',
          height: 45,
          left: 57,
          right: 189,
        ),
        Furniture(
          name: 'potted_plants',
          height: 45,
          left: 60,
          right: 200,
        ),
        Furniture(
          name: 'electric_keyboard',
          height: 45,
          left: 50,
          right: 187,
        ),
        Furniture(
          name: 'motor_boat',
          height: 55,
          left: 105,
          right: 178,
        ),
      ],
      setting: const SlotSetting(
        delayEvent: [2028, 2023],
      ),
    ),
    // Ga3
    Slot(
      id: 'Ga3',
      order: 1,
      height: 45,
      icon: 'OUTLINE_wall_NE',
      left: 115,
      right: 60,
      acceptables: const [
        Furniture(
          name: 'wire_shelves',
          direction: Direction.ne,
          height: 50,
          left: 120,
          right: 53,
        ),
        Furniture(
          name: 'pine_bookcase',
          direction: Direction.ne,
          height: 40,
          left: 130,
          right: 58,
        ),
        Furniture(
          name: 'walnut_bookcase',
          direction: Direction.ne,
          height: 60,
          left: 110,
          right: 45,
        ),
        Furniture(
          name: 'luxury_wine_cabinet',
          direction: Direction.ne,
          height: 50,
          left: 120,
          right: 55,
        ),
        Furniture(
          name: 'tv_cabinet',
          direction: Direction.ne,
          height: 45,
          left: 120,
          right: 55,
        ),
      ],
      setting: const SlotSetting(
        wrongSlotItem: true,
        delayEvent: [2009, 2034],
      ),
    ),
    // // Ga4
    // Slot(
    //   id: 'Ga4',
    //   order: 3,
    //   height: 35,
    //   icon: 'OUTLINE_box',
    //   left: 200,
    //   right: 200,
    //   acceptables: const [
    //     Furniture(
    //       name: 'putting_green',
    //       height: 40,
    //       left: 205,
    //       right: 175,
    //     ),
    //     Furniture(
    //       name: 'potted_trees',
    //       height: 50,
    //       left: 190,
    //       right: 194,
    //     ),
    //     Furniture(
    //       name: 'crafts_table',
    //       height: 50,
    //       left: 180,
    //       right: 195,
    //     ),
    //     Furniture(
    //       name: 'electric_guitar',
    //       height: 50,
    //       left: 195,
    //       right: 195,
    //     ),
    //     Furniture(
    //       name: 'home_gym',
    //       height: 64,
    //       left: 175,
    //       right: 185,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     randomItem: StoreItem(
    //       name: 'Deluxe Satellite TV Antenna',
    //       seller: Seller.deansConnectionServices,
    //       price: 2499.99,
    //     ),
    //   ),
    // ),
    // // Ga5
    // Slot(
    //   id: 'Ga5',
    //   order: 4,
    //   height: 35,
    //   icon: 'OUTLINE_box',
    //   left: 200,
    //   right: 80,
    //   acceptables: const [
    //     Furniture(
    //       name: 'yoga_mat_and_exercise_ball',
    //       height: 40,
    //       left: 200,
    //       right: 80,
    //     ),
    //     Furniture(
    //       name: 'display_hutch',
    //       height: 40,
    //       left: 200,
    //       right: 80,
    //     ),
    //     Furniture(
    //       name: 'tool_hutch',
    //       height: 40,
    //       left: 200,
    //       right: 80,
    //     ),
    //     Furniture(
    //       name: 'drumset',
    //       height: 60,
    //       left: 180,
    //       right: 60,
    //     ),
    //     Furniture(
    //       name: 'pool_table',
    //       height: 40,
    //       left: 200,
    //       right: 80,
    //     ),
    //   ],
    //   setting: const SlotSetting(
    //     // doubleCharge: true,
    //     delayEvent: [1014, 2021, 2016, 1034],
    //     //doubleAfterEvent: [],
    //   ),
    // ),
  ],
);

String matchingIdwithDoc(id) {
  switch (id) {
    case 'Bd1':
      return 'Bd2';
    case 'Bd2':
      return 'Bd7';
    case 'Bd7':
      return 'Bd6';
    case 'Bd6':
      return 'Bd4';
    case 'Bd4':
      return 'Bd9';
    case 'Bd9':
      return 'Bd10';
    case 'Bd10':
      return 'Bd1';

    case 'LR4':
      return 'LR1';
    case 'LR1':
      return 'LR6';
    case 'LR6':
      return 'LR2';
    case 'LR2':
      return 'LR5';
    case 'LR5':
      return 'LR8';
    case 'LR8':
      return 'LR4';

    case 'Ba1':
      return 'Ba2';
    case 'Ba2':
      return 'Ba3';
    case 'Ba3':
      return 'Ba4';
    case 'Ba4':
      return 'Ba1';

    case 'K1':
      return 'K2';
    case 'K2':
      return 'K3';
    case 'K3':
      return 'K4';
    case 'K4':
      return 'K5';
    case 'K5':
      return 'K6';
    case 'K6':
      return 'K7';
    case 'K7':
      return 'K8';
    case 'K8':
      return 'K9';
    case 'K9':
      return 'K10';
    case 'K10':
      return 'K11';
    case 'K11':
      return 'K1';

    case 'D1':
      return 'D2';
    case 'D2':
      return 'D3';
    case 'D3':
      return 'D4';
    case 'D4':
      return 'D5';
    case 'D5':
      return 'D6';
    case 'D6':
      return 'D7';
    case 'D7':
      return 'D8';
    case 'D8':
      return 'D9';
    case 'D9':
      return 'D10';
    case 'D10':
      return 'D11';
    case 'D11':
      return 'D1';

    case 'Ga1':
      return 'Ga2';
    case 'Ga2':
      return 'Ga3';
    case 'Ga3':
      return 'Ga4';
    case 'Ga4':
      return 'Ga5';
    case 'Ga5':
      return 'Ga1';
    default:
      return id;
  }
}

// String matchIdWithDoc(id) {
//   switch (id) {
//     // case 'Bd3':
//     //   return 'Bd7';
//     case 'Bd4':
//       return 'Bd11';
//     case 'Bd1':
//       return 'Bd2';
//     case 'Bd0':
//       return 'Bd1';
//     case 'Bd2':
//       return 'Bd6';
//     case 'Bd6':
//       return 'Bd7';
//     case 'Bd7':
//       return 'Bd4';
//     case 'Bd8':
//       return 'Bd11';
//     case 'Bd11':
//       return 'Bd8';
//     case 'LR0':
//       return 'LR4';
//     case 'LR2':
//       return 'LR6';
//     case 'LR6':
//       return 'LR5';
//     case 'LR3':
//       return 'LR2';
//     case 'LR4':
//       return 'LR3';
//     case 'LR5':
//       return 'LR9';
//     case 'LR9':
//       return 'LR11';
//     case 'Ba0':
//       return 'Ba1';
//     case 'Ba1':
//       return 'Ba5';
//     case 'Ba2':
//       return 'Ba4';
//     case 'Ba3':
//       return 'Ba2';
//     case 'Ba4':
//       return 'Ba3';
//     case 'K0':
//       return 'K1';
//     case 'K1':
//       return 'K4';
//     case 'K2':
//       return 'K7';
//     case 'K7':
//       return 'K8';
//     case 'K3':
//       return 'K2';
//     case 'K10':
//       return 'K3';
//     case 'K4':
//       return 'K6';
//     case 'K6':
//       return 'K11';
//     case 'K8':
//       return 'K9';
//     case 'K9':
//       return 'K10';
//     case 'D0':
//       return 'D3';
//     case 'D7':
//       return 'D8';
//     case 'D6':
//       return 'D4';
//     case 'D5':
//       return 'D6';
//     case 'D3':
//       return 'D7';
//     case 'D4':
//       return 'D5';
//     case 'D8':
//       return 'D9';
//     case 'D9':
//       return 'D10';
//     case 'D10':
//       return 'D11';
//     case 'Ga0':
//       return 'Ga1';
//     case 'Ga1':
//       return 'Ga3';
//     case 'Ga3':
//       return 'Ga4';
//     case 'Ga4':
//       return 'Ga5';
//     default:
//       return id;
//   }
// }
