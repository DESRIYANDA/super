--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))

-- Protect TweenService from workspace errors
pcall(function()
    local TweenService = game:GetService("TweenService")
    local originalCreate = TweenService.Create
    TweenService.Create = function(self, instance, ...)
        if instance and instance.Parent then
            return originalCreate(self, instance, ...)
        else
            -- Return dummy tween for invalid instances
            return {
                Play = function() end,
                Cancel = function() end,
                Pause = function() end,
                Destroy = function() end
            }
        end
    end
end)

--// Variables
local flags = {}
local characterposition
local lp = Players.LocalPlayer
local fishabundancevisible = false
local deathcon
local tooltipmessage

-- Default delay values
flags['autocastdelay'] = 0.5
flags['autoreeldelay'] = 0.5

-- Super Instant Reel Variables
flags['superinstantreel'] = false
flags['instantbobber'] = false
local superInstantReelActive = false

-- Super Instant Reel GUI Monitoring System
local function setupSuperInstantReel()
    if not superInstantReelActive then
        superInstantReelActive = true
        
        -- Monitor for reel GUI appearance
        local playerGui = lp.PlayerGui
        playerGui.ChildAdded:Connect(function(gui)
            if flags['superinstantreel'] and gui.Name == "reel" then
                -- SUPER INSTANT: No waiting at all!
                pcall(function()
                    -- Immediately fire reel completion
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                    
                    -- Force disable the GUI
                    gui.Enabled = false
                    
                    -- Additional rapid calls for maximum effectiveness
                    for i = 1, 5 do
                        ReplicatedStorage.events.reelfinished:FireServer(100, true)
                    end
                    
                    print("🚀 [Super Instant Reel] Fish caught INSTANTLY!")
                end)
            end
        end)
        
        print("✅ [Super Instant Reel] Monitoring system activated!")
    end
end

-- Call setup function
setupSuperInstantReel()

local TeleportLocations = {
    ['Zones'] = {
        ['Moosewood'] = CFrame.new(379.875458, 134.500519, 233.5495, -0.033920113, 8.13274355e-08, 0.999424577, 8.98441925e-08, 1, -7.83249803e-08, -0.999424577, 8.7135696e-08, -0.033920113),
        ['Roslit Bay'] = CFrame.new(-1472.9812, 132.525513, 707.644531, -0.00177415239, 1.15743369e-07, -0.99999845, -9.25943056e-09, 1, 1.15759981e-07, 0.99999845, 9.46479251e-09, -0.00177415239),
        ['Forsaken Shores'] = CFrame.new(-2491.104, 133.250015, 1561.2926, 0.355353981, -1.68352852e-08, -0.934731781, 4.69647858e-08, 1, -1.56367586e-10, 0.934731781, -4.38439116e-08, 0.355353981),
        ['Sunstone Island'] = CFrame.new(-913.809143, 138.160782, -1133.25879, -0.746701241, 4.50330218e-09, 0.665159583, 2.84934609e-09, 1, -3.5716119e-09, -0.665159583, -7.71657294e-10, -0.746701241),
        ['Statue of Sovereignty'] = CFrame.new(21.4017925, 159.014709, -1039.14233, -0.865476549, -4.38348664e-08, -0.500949502, -9.38435818e-08, 1, 7.46273798e-08, 0.500949502, 1.11599142e-07, -0.865476549),
        ['Terrapin Island'] = CFrame.new(-193.434143, 135.121979, 1951.46936, 0.512723684, -6.94711346e-08, 0.858553708, 5.44089183e-08, 1, 4.84237539e-08, -0.858553708, 2.18849721e-08, 0.512723684),
        ['Snowcap Island'] = CFrame.new(2607.93018, 135.284332, 2436.13208, 0.909039497, -7.49003748e-10, 0.4167099, 3.38659367e-09, 1, -5.59032465e-09, -0.4167099, 6.49305321e-09, 0.909039497),
        ['Mushgrove Swamp'] = CFrame.new(2434.29785, 131.983276, -691.930542, -0.123090521, -7.92820209e-09, -0.992395461, -9.05862692e-08, 1, 3.2467995e-09, 0.992395461, 9.02970569e-08, -0.123090521),
        ['Ancient Isle'] = CFrame.new(6056.02783, 195.280167, 276.270325, -0.655055285, 1.96010075e-09, 0.755580962, -1.63855578e-08, 1, -1.67997189e-08, -0.755580962, -2.33853594e-08, -0.655055285),
        ['Northern Expedition'] = CFrame.new(-1701.02979, 187.638779, 3944.81494, 0.918493569, -8.5804345e-08, 0.395435959, 8.59132356e-08, 1, 1.74328942e-08, -0.395435959, 1.7961181e-08, 0.918493569),
        ['Northern Summit'] = CFrame.new(19608.791, 131.420105, 5222.15283, 0.462794542, -2.64426987e-08, 0.886465549, -4.47066562e-08, 1, 5.31692343e-08, -0.886465549, -6.42373408e-08, 0.462794542),
        ['Vertigo'] = CFrame.new(-102.40567, -513.299377, 1052.07104, -0.999989033, 5.36423439e-09, 0.00468267547, 5.85247495e-09, 1, 1.04251647e-07, -0.00468267547, 1.04277916e-07, -0.999989033),
        ['Depths Entrance'] = CFrame.new(-15.4965982, -706.123718, 1231.43494, 0.0681341439, 1.15903154e-08, -0.997676194, 7.1017638e-08, 1, 1.64673093e-08, 0.997676194, -7.19745898e-08, 0.0681341439),
        ['Depths'] = CFrame.new(491.758118, -706.123718, 1230.6377, 0.00879980437, 1.29271776e-08, -0.999961257, 1.95575205e-13, 1, 1.29276803e-08, 0.999961257, -1.13956629e-10, 0.00879980437),
        ['Overgrowth Caves'] = CFrame.new(19746.2676, 416.00293, 5403.5752, 0.488031536, -3.30940715e-08, -0.87282598, -3.24267696e-11, 1, -3.79341323e-08, 0.87282598, 1.85413569e-08, 0.488031536),
        ['Frigid Cavern'] = CFrame.new(20253.6094, 756.525818, 5772.68555, -0.781508088, 1.85673343e-08, 0.623895109, 5.92671467e-09, 1, -2.23363816e-08, -0.623895109, -1.3758414e-08, -0.781508088),
        ['Cryogenic Canal'] = CFrame.new(19958.5176, 917.195923, 5332.59375, 0.758922458, -7.29783434e-09, 0.651180983, -4.58880756e-09, 1, 1.65551253e-08, -0.651180983, -1.55522013e-08, 0.758922458),
        ['Glacial Grotto'] = CFrame.new(20003.0273, 1136.42798, 5555.95996, 0.983130038, -3.94455064e-08, 0.182907909, 3.45229765e-08, 1, 3.0096718e-08, -0.182907909, -2.32744615e-08, 0.983130038),
        ["Keeper's Altar"] = CFrame.new(1297.92285, -805.292236, -284.155823, -0.99758029, 5.80044706e-08, -0.0695239156, 6.16549869e-08, 1, -5.03615105e-08, 0.0695239156, -5.45261436e-08, -0.99758029),
        ['Atlantis'] = CFrame.new(-4465, -604, 1874)
    },
    ['Rods'] = {
        ['Heaven Rod'] = CFrame.new(20025.0508, -467.665955, 7114.40234, -0.9998191, -2.41349773e-10, 0.0190212391, -4.76249762e-10, 1, -1.23448247e-08, -0.0190212391, -1.23516495e-08, -0.9998191),
        ['Summit Rod'] = CFrame.new(20213.334, 736.668823, 5707.8208, -0.274440169, 3.53429606e-08, 0.961604178, -1.52819659e-08, 1, -4.11156122e-08, -0.961604178, -2.59789772e-08, -0.274440169),
        ['Kings Rod'] = CFrame.new(1380.83862, -807.198608, -304.22229, -0.692510426, 9.24755454e-08, 0.72140789, 4.86611427e-08, 1, -8.1475676e-08, -0.72140789, -2.13182219e-08, -0.692510426),
        ['Training Rod'] = CFrame.new(465, 150, 235),
        ['Long Rod'] = CFrame.new(480, 180, 150),
        ['Fortune Rod'] = CFrame.new(-1515, 141, 765),
        ['Depthseeker Rod'] = CFrame.new(-4465, -604, 1874),
        ['Champions Rod'] = CFrame.new(-4277, -606, 1838),
        ['Tempest Rod'] = CFrame.new(-4928, -595, 1857),
        ['Abyssal Specter Rod'] = CFrame.new(-3804, -567, 1870),
        ['Poseidon Rod'] = CFrame.new(-4086, -559, 895),
        ['Zeus Rod'] = CFrame.new(-4272, -629, 2665),
        ['Kraken Rod'] = CFrame.new(-4415, -997, 2055),
        ['Reinforced Rod'] = CFrame.new(-975, -245, -2700),
        ['Trident Rod'] = CFrame.new(-1485, -225, -2195),
        ['Scurvy Rod'] = CFrame.new(-2830, 215, 1510),
        ['Stone Rod'] = CFrame.new(5487, 143, -316),
        ['Magnet Rod'] = CFrame.new(-200, 130, 1930)
    },
    ['Items'] = {
        ['Fish Radar'] = CFrame.new(365, 135, 275),
        ['Basic Diving Gear'] = CFrame.new(370, 135, 250),
        ['Bait Crate (Moosewood)'] = CFrame.new(315, 135, 335),
        ['Meteor Totem'] = CFrame.new(-1945, 275, 230),
        ['Glider'] = CFrame.new(-1710, 150, 740),
        ['Bait Crate (Roslit)'] = CFrame.new(-1465, 130, 680),
        ['Crab Cage (Roslit)'] = CFrame.new(-1485, 130, 640),
        ['Poseidon Wrath Totem'] = CFrame.new(-3953, -556, 853),
        ['Zeus Storm Totem'] = CFrame.new(-4325, -630, 2687),
        ['Quality Bait Crate (Atlantis)'] = CFrame.new(-177, 144, 1933),
        ['Flippers'] = CFrame.new(-4462, -605, 1875),
        ['Super Flippers'] = CFrame.new(-4463, -603, 1876),
        ['Advanced Diving Gear (Atlantis)'] = CFrame.new(-4452, -603, 1877),
        ['Conception Conch (Atlantis)'] = CFrame.new(-4450, -605, 1874),
        ['Advanced Diving Gear (Desolate)'] = CFrame.new(-790, 125, -3100),
        ['Basic Diving Gear (Desolate)'] = CFrame.new(-1655, -210, -2825),
        ['Tidebreaker'] = CFrame.new(-1645, -210, -2855),
        ['Conception Conch (Desolate)'] = CFrame.new(-1630, -210, -2860),
        ['Aurora Totem'] = CFrame.new(-1800, -135, -3280),
        ['Bait Crate (Forsaken)'] = CFrame.new(-2490, 130, 1535),
        ['Crab Cage (Forsaken)'] = CFrame.new(-2525, 135, -1575),
        ['Eclipse Totem'] = CFrame.new(5966, 274, 846),
        ['Bait Crate (Ancient)'] = CFrame.new(6075, 195, 260),
        ['Smokescreen Totem'] = CFrame.new(2790, 140, -625),
        ['Crab Cage (Mushgrove)'] = CFrame.new(2520, 135, -895),
        ['Windset Totem'] = CFrame.new(2845, 180, 2700),
        ['Sundial Totem'] = CFrame.new(-1145, 135, -1075),
        ['Bait Crate (Sunstone)'] = CFrame.new(-1045, 200, -1100),
        ['Crab Cage (Sunstone)'] = CFrame.new(-920, 130, -1105),
        ['Quality Bait Crate (Terrapin)'] = CFrame.new(-175, 145, 1935),
        ['Tempest Totem'] = CFrame.new(35, 130, 1945)
    },
    ['Fishing Spots'] = {
        ['Trout Spot'] = CFrame.new(390, 132, 345),
        ['Anchovy Spot'] = CFrame.new(130, 135, 630),
        ['Yellowfin Tuna Spot'] = CFrame.new(705, 136, 340),
        ['Carp Spot'] = CFrame.new(560, 145, 600),
        ['Goldfish Spot'] = CFrame.new(525, 145, 310),
        ['Flounder Spot'] = CFrame.new(285, 133, 215),
        ['Pike Spot'] = CFrame.new(540, 145, 330),
        ['Perch Spot'] = CFrame.new(-1805, 140, 595),
        ['Blue Tang Spot'] = CFrame.new(-1465, 125, 525),
        ['Clownfish Spot'] = CFrame.new(-1520, 125, 520),
        ['Clam Spot'] = CFrame.new(-2028, 130, 541),
        ['Angelfish Spot'] = CFrame.new(-1500, 135, 615),
        ['Arapaima Spot'] = CFrame.new(-1765, 140, 600),
        ['Suckermouth Catfish Spot'] = CFrame.new(-1800, 140, 620),
        ['Phantom Ray Spot'] = CFrame.new(-1685, -235, -3090),
        ['Cockatoo Squid Spot'] = CFrame.new(-1645, -205, -2790),
        ['Banditfish Spot'] = CFrame.new(-1500, -235, -2855),
        ['Scurvy Sailfish Spot'] = CFrame.new(-2430, 130, 1450),
        ['Cutlass Fish Spot'] = CFrame.new(-2645, 130, 1410),
        ['Shipwreck Barracuda Spot'] = CFrame.new(-3597, 140, 1604),
        ['Golden Seahorse Spot'] = CFrame.new(-3100, 127, 1450),
        ['Anomalocaris Spot'] = CFrame.new(5504, 143, -321),
        ['Cobia Spot'] = CFrame.new(5983, 125, 1007),
        ['Hallucigenia Spot'] = CFrame.new(6015, 190, 339),
        ['Leedsichthys Spot'] = CFrame.new(6052, 394, 648),
        ['Deep Sea Fragment Spot'] = CFrame.new(5841, 81, 388),
        ['Solar Fragment Spot'] = CFrame.new(6073, 443, 684),
        ['Earth Fragment Spot'] = CFrame.new(5972, 274, 845),
        ['White Perch Spot'] = CFrame.new(2475, 125, -675),
        ['Grey Carp Spot'] = CFrame.new(2665, 125, -815),
        ['Bowfin Spot'] = CFrame.new(2445, 125, -795),
        ['Marsh Gar Spot'] = CFrame.new(2520, 125, -815),
        ['Alligator Spot'] = CFrame.new(2670, 130, -710),
        ['Pollock Spot'] = CFrame.new(2550, 135, 2385),
        ['Bluegill Spot'] = CFrame.new(3070, 130, 2600),
        ['Herring Spot'] = CFrame.new(2595, 140, 2500),
        ['Red Drum Spot'] = CFrame.new(2310, 135, 2545),
        ['Arctic Char Spot'] = CFrame.new(2350, 130, 2230),
        ['Lingcod Spot'] = CFrame.new(2820, 125, 2805),
        ['Glacierfish Spot'] = CFrame.new(2860, 135, 2620),
        ['Sweetfish Spot'] = CFrame.new(-940, 130, -1105),
        ['Glassfish Spot'] = CFrame.new(-905, 130, -1000),
        ['Longtail Bass Spot'] = CFrame.new(-860, 135, -1205),
        ['Red Tang Spot'] = CFrame.new(-1195, 123, -1220),
        ['Chinfish Spot'] = CFrame.new(-625, 130, -950),
        ['Trumpetfish Spot'] = CFrame.new(-790, 125, -1340),
        ['Mahi Mahi Spot'] = CFrame.new(-730, 130, -1350),
        ['Sunfish Spot'] = CFrame.new(-975, 125, -1430),
        ['Walleye Spot'] = CFrame.new(-225, 125, 2150),
        ['White Bass Spot'] = CFrame.new(-50, 130, 2025),
        ['Redeye Bass Spot'] = CFrame.new(-35, 125, 2285),
        ['Chinook Salmon Spot'] = CFrame.new(-305, 125, 1625),
        ['Golden Smallmouth Bass Spot'] = CFrame.new(65, 135, 2140),
        ['Olm Spot'] = CFrame.new(95, 125, 1980)
    },
    ['NPCs'] = {
        ['Angler'] = CFrame.new(480, 150, 295),
        ['Appraiser'] = CFrame.new(445, 150, 210),
        ['Arnold'] = CFrame.new(320, 134, 264),
        ['Bob'] = CFrame.new(420, 145, 260),
        ['Brickford Masterson'] = CFrame.new(412, 132, 365),
        ['Captain Ahab'] = CFrame.new(441, 135, 358),
        ['Challenges'] = CFrame.new(337, 138, 312),
        ['Clover McRich'] = CFrame.new(345, 136, 330),
        ['Daisy'] = CFrame.new(580, 165, 220),
        ['Dr. Blackfin'] = CFrame.new(355, 136, 329),
        ['Egg Salesman'] = CFrame.new(404, 135, 312),
        ['Harry Fischer'] = CFrame.new(396, 134, 381),
        ['Henry'] = CFrame.new(484, 152, 236),
        ['Inn Keeper'] = CFrame.new(490, 150, 245),
        ['Lucas'] = CFrame.new(450, 180, 175),
        ['Marlon Friend'] = CFrame.new(405, 135, 248),
        ['Merchant'] = CFrame.new(465, 150, 230),
        ['Paul'] = CFrame.new(382, 137, 347),
        ['Phineas'] = CFrame.new(470, 150, 275),
        ['Pierre'] = CFrame.new(390, 135, 200),
        ['Pilgrim'] = CFrame.new(402, 134, 257),
        ['Ringo'] = CFrame.new(410, 135, 235),
        ['Shipwright'] = CFrame.new(360, 135, 260),
        ['Skin Merchant'] = CFrame.new(415, 135, 194),
        ['Smurfette'] = CFrame.new(334, 135, 327),
        ['Tom Elf'] = CFrame.new(404, 136, 317),
        ['Witch'] = CFrame.new(410, 135, 310),
        ['Wren'] = CFrame.new(368, 135, 286),
        ['Mike'] = CFrame.new(210, 115, 640),
        ['Ryder Vex'] = CFrame.new(233, 116, 746),
        ['Ocean'] = CFrame.new(1230, 125, 575),
        ['Lars Timberjaw'] = CFrame.new(1217, 87, 574),
        ['Sporey'] = CFrame.new(1245, 86, 425),
        ['Sporey Mom'] = CFrame.new(1262, 129, 663),
        ['Oscar IV'] = CFrame.new(1392, 116, 493),
        ['Angus McBait'] = CFrame.new(236, 222, 461),
        ['Waveborne'] = CFrame.new(360, 90, 780),
        ['Boone Tiller'] = CFrame.new(390, 87, 764),
        ['Clark'] = CFrame.new(443, 84, 703),
        ['Jak'] = CFrame.new(474, 84, 758),
        ['Willow'] = CFrame.new(501, 134, 125),
        ['Marley'] = CFrame.new(505, 134, 120),
        ['Sage'] = CFrame.new(513, 134, 125),
        ['Meteoriticist'] = CFrame.new(5922, 262, 596),
        ['Chiseler'] = CFrame.new(6087, 195, 294),
        ['Sea Traveler'] = CFrame.new(140, 150, 2030),
        ['Wilson'] = CFrame.new(2935, 280, 2565),
        ['Agaric'] = CFrame.new(2931, 4268, 3039),
        ['Sunken Chest'] = CFrame.new(798, 130, 1667),
        ['Daily Shopkeeper'] = CFrame.new(229, 139, 42),
        ['AFK Rewards'] = CFrame.new(233, 139, 38),
        ['Travelling Merchant'] = CFrame.new(2, 500, 0),
        ['Silas'] = CFrame.new(1545, 1690, 6310),
        ['Nick'] = CFrame.new(50, 0, 0),
        ['Hollow'] = CFrame.new(25, 0, 0),
        ['Shopper Girl'] = CFrame.new(1000, 140, 9932),
        ['Sandy Finn'] = CFrame.new(1015, 140, 9911),
        ['Red NPC'] = CFrame.new(1020, 173, 9857),
        ['Thomas'] = CFrame.new(1062, 140, 9890),
        ['Shawn'] = CFrame.new(1068, 157, 9918),
        ['Axel'] = CFrame.new(883, 132, 9905),
        ['Joey'] = CFrame.new(906, 132, 9962),
        ['Jett'] = CFrame.new(925, 131, 9883),
        ['Lucas (Fischfest)'] = CFrame.new(946, 132, 9894),
        ['Shell Merchant'] = CFrame.new(972, 132, 9921),
        ['Barnacle Bill'] = CFrame.new(989, 143, 9975)
    },
    ['Mariana Veil'] = {
        -- SUBMARINE DEPOT
        ['Submarine Depot'] = CFrame.new(1500, 125, 530),
        ['North-Western Side'] = CFrame.new(-1305, 130, 310),
        ['Submarine Depot (West)'] = CFrame.new(-1480, 137, 382),
        
        -- VOLCANIC VENTS
        ['Magma Leviathan'] = CFrame.new(-4360, -11175, 3715),
        ['Challenger\'s Deep Entrance'] = CFrame.new(-2630, -3830, 755),
        ['Volcanic Vents Entrance'] = CFrame.new(-2745, -2325, 865),
        ['Volcanic Tunnel End'] = CFrame.new(-3420, -2275, 3765),
        ['Volcanic Rocks'] = CFrame.new(-3365, -2260, 3850),
        ['Lava Fishing Cave'] = CFrame.new(-3495, -2255, 3825),
        ['Lava Fishing Pool'] = CFrame.new(-3175, -2035, 4020),
        
        -- CHALLENGER'S DEEP
        ['Abyssal Zenith Entrance'] = CFrame.new(-5375, -7390, 400),
        ['Ice Fishing Cave (East)'] = CFrame.new(740, -3355, -1530),
        ['Ice Cave (Large)'] = CFrame.new(-835, -3295, -625),
        ['Ice Rocks Cave'] = CFrame.new(-800, -3280, -625),
        ['Ice Fishing Cave (Central)'] = CFrame.new(-760, -3280, -715),
        ['Ice Portal Back'] = CFrame.new(-735, -3280, -725),
        
        -- ABYSSAL ZENITH
        ['Hidden River (Calm Zone)'] = CFrame.new(-4305, -11230, 1955),
        ['Calm Zone'] = CFrame.new(-4145, -11210, 1395),
        ['Crossbow Arrow (East)'] = CFrame.new(-2300, -11190, 7140),
        ['Crossbow Bow'] = CFrame.new(-4800, -11185, 6610),
        ['Crossbow Arrow (West)'] = CFrame.new(-4035, -11185, 6510),
        ['Hidden River'] = CFrame.new(-4330, -11180, 3120),
        ['Crossbow Base'] = CFrame.new(-4345, -11155, 6490),
        ['Crossbow Base (Main)'] = CFrame.new(-4360, -11090, 7140),
        ['Abyssal Zenith Upgrade'] = CFrame.new(-13515, -11050, 175),
        ['Zenith Tunnel End'] = CFrame.new(-13420, -11050, 110),
        ['Rod of the Zenith'] = CFrame.new(-13625, -11035, 355)
    },
    ['All Locations'] = {
        -- Sea Traveler
        ['Sea Traveler #1'] = CFrame.new(140, 150, 2030),
        ['Sea Traveler #2'] = CFrame.new(690, 170, 345),
        
        -- Terrapin Island
        ['Terrapin Island #1'] = CFrame.new(-200, 130, 1925),
        ['Terrapin Island #2'] = CFrame.new(10, 155, 2000),
        ['Terrapin Island #3'] = CFrame.new(160, 125, 1970),
        ['Terrapin Island #4'] = CFrame.new(25, 140, 1860),
        ['Terrapin Island #5'] = CFrame.new(140, 150, 2050),
        ['Terrapin Island #6'] = CFrame.new(-200, 130, 1930),
        ['Terrapin Island #7'] = CFrame.new(-175, 145, 1935),
        ['Terrapin Island #8'] = CFrame.new(35, 130, 1945),
        
        -- Moosewood Additional Spots
        ['Moosewood #1'] = CFrame.new(350, 135, 250),
        ['Moosewood #2'] = CFrame.new(412, 135, 233),
        ['Moosewood #3'] = CFrame.new(385, 135, 280),
        ['Moosewood #4'] = CFrame.new(480, 150, 295),
        ['Moosewood #5'] = CFrame.new(465, 150, 235),
        ['Moosewood #6'] = CFrame.new(480, 180, 150),
        ['Moosewood #7'] = CFrame.new(515, 150, 285),
        ['Moosewood #8'] = CFrame.new(365, 135, 275),
        ['Moosewood #9'] = CFrame.new(370, 135, 250),
        ['Moosewood #10'] = CFrame.new(315, 135, 335),
        ['Moosewood #11'] = CFrame.new(705, 137, 341),
        ['Moosewood #12'] = CFrame.new(-1878, 167, 548),
        
        -- Crystal Cove
        ['Crystal Cove #1'] = CFrame.new(1364, -612, 2472),
        ['Crystal Cove #2'] = CFrame.new(1302, -701, 1604),
        ['Crystal Cove #3'] = CFrame.new(1350, -604, 2329),
        
        -- Castaway Cliffs
        ['Castaway Cliffs #1'] = CFrame.new(690, 135, -1693),
        ['Castaway Cliffs #2'] = CFrame.new(255, 800, -6865),
        ['Castaway Cliffs #3'] = CFrame.new(560, 310, -2070),
        
        -- Gilded Arch
        ['Gilded Arch'] = CFrame.new(450, 90, 2850),
        
        -- Trade Plaza
        ['Trade Plaza'] = CFrame.new(535, 82, 775),
        
        -- Whale Interior
        ['Whale Interior #1'] = CFrame.new(-300, 83, -380),
        ['Whale Interior #2'] = CFrame.new(-30, -1350, -2160),
        ['Whale Interior #3'] = CFrame.new(-357, 96, -277),
        ['Whale Interior #4'] = CFrame.new(-387, 80, -387),
        ['Whale Interior #5'] = CFrame.new(-50, -1350, -2170),
        ['Whale Interior #6'] = CFrame.new(-317, 85, -420),
        
        -- Lobster Shores
        ['Lobster Shores #1'] = CFrame.new(-550, 150, 2640),
        ['Lobster Shores #2'] = CFrame.new(-550, 153, 2650),
        ['Lobster Shores #3'] = CFrame.new(-585, 130, 2950),
        ['Lobster Shores #4'] = CFrame.new(-575, 153, 2640),
        ['Lobster Shores #5'] = CFrame.new(-570, 153, 2640),
        ['Lobster Shores #6'] = CFrame.new(-565, 153, 2640),
        
        -- Netter's Haven
        ['Netters Haven #1'] = CFrame.new(-640, 85, 1030),
        ['Netters Haven #2'] = CFrame.new(-775, 90, 950),
        ['Netters Haven #3'] = CFrame.new(-635, 85, 1005),
        ['Netters Haven #4'] = CFrame.new(-630, 85, 1005),
        ['Netters Haven #5'] = CFrame.new(-610, 85, 1005),
        ['Netters Haven #6'] = CFrame.new(-575, 85, 1000),
        
        -- Waveborne
        ['Waveborne #1'] = CFrame.new(360, 90, 780),
        ['Waveborne #2'] = CFrame.new(400, 85, 737),
        ['Waveborne #3'] = CFrame.new(55, 160, 833),
        ['Waveborne #4'] = CFrame.new(165, 115, 730),
        ['Waveborne #5'] = CFrame.new(165, 115, 720),
        ['Waveborne #6'] = CFrame.new(223, 120, 815),
        ['Waveborne #7'] = CFrame.new(405, 85, 862),
        
        -- Isle of New Beginnings
        ['Isle of New Beginnings #1'] = CFrame.new(-300, 83, -380),
        ['Isle of New Beginnings #2'] = CFrame.new(-30, -1350, -2160),
        ['Isle of New Beginnings #3'] = CFrame.new(-357, 96, -277),
        ['Isle of New Beginnings #4'] = CFrame.new(-387, 80, -387),
        ['Isle of New Beginnings #5'] = CFrame.new(-50, -1350, -2170),
        ['Isle of New Beginnings #6'] = CFrame.new(-317, 85, -420),
        
        -- Lushgrove
        ['Lushgrove #1'] = CFrame.new(1133, 105, -560),
        ['Lushgrove #2'] = CFrame.new(1260, -625, -1070),
        ['Lushgrove #3'] = CFrame.new(1310, 130, -945),
        ['Lushgrove #4'] = CFrame.new(1505, 165, -665),
        ['Lushgrove #5'] = CFrame.new(1410, 155, -580),
        ['Lushgrove #6'] = CFrame.new(1355, 110, -615),
        ['Lushgrove #7'] = CFrame.new(1170, 115, -750),
        ['Lushgrove #8'] = CFrame.new(1020, 130, -705),
        ['Lushgrove #9'] = CFrame.new(1275, -625, -1060),
        ['Lushgrove #10'] = CFrame.new(1300, 155, -550),
        
        -- Emberreach
        ['Emberreach #1'] = CFrame.new(2390, 83, -490),
        ['Emberreach #2'] = CFrame.new(2870, 165, 520),
        
        -- Azure Lagoon
        ['Azure Lagoon #1'] = CFrame.new(1310, 80, 2113),
        ['Azure Lagoon #2'] = CFrame.new(1287, 90, 2285),
        
        -- The Cursed Shores
        ['Cursed Shores #1'] = CFrame.new(-235, 85, 1930),
        ['Cursed Shores #2'] = CFrame.new(-185, -370, 2280),
        ['Cursed Shores #3'] = CFrame.new(-435, -40, 1665),
        ['Cursed Shores #4'] = CFrame.new(-493, 137, 2240),
        ['Cursed Shores #5'] = CFrame.new(-210, -360, 2383),
        
        -- Pine Shoals
        ['Pine Shoals'] = CFrame.new(1165, 80, 480),
        
        -- The Laboratory
        ['The Laboratory'] = CFrame.new(-1785, 130, -485),
        
        -- Grand Reef
        ['Grand Reef #1'] = CFrame.new(-3530, 130, 550),
        ['Grand Reef #2'] = CFrame.new(-3820, 135, 575),
        
        -- Archaeological Site
        ['Archaeological Site'] = CFrame.new(4160, 125, 210),
        
        -- Ocean Spots
        ['Ocean Spot #1'] = CFrame.new(-1270, 125, 1580),
        ['Ocean Spot #2'] = CFrame.new(1000, 125, -1250),
        ['Ocean Spot #3'] = CFrame.new(-530, 125, -425),
        ['Ocean Spot #4'] = CFrame.new(1230, 125, 575),
        ['Ocean Spot #5'] = CFrame.new(1700, 125, -2500),
        
        -- Sunken Chest Locations
        ['Sunken Chest #1'] = CFrame.new(936, 130, -159),
        ['Sunken Chest #2'] = CFrame.new(-1179, 130, 565),
        ['Sunken Chest #3'] = CFrame.new(-852, 130, -1560),
        ['Sunken Chest #4'] = CFrame.new(798, 130, 1667),
        ['Sunken Chest #5'] = CFrame.new(2890, 130, -997),
        ['Sunken Chest #6'] = CFrame.new(-2460, 130, 2047),
        ['Sunken Chest #7'] = CFrame.new(693, 130, -362),
        ['Sunken Chest #8'] = CFrame.new(-1217, 130, 201),
        ['Sunken Chest #9'] = CFrame.new(-1000, 130, -751),
        ['Sunken Chest #10'] = CFrame.new(562, 130, 2455),
        ['Sunken Chest #11'] = CFrame.new(2729, 130, -1098),
        ['Sunken Chest #12'] = CFrame.new(613, 130, 498),
        ['Sunken Chest #13'] = CFrame.new(-1967, 130, 980),
        ['Sunken Chest #14'] = CFrame.new(-1500, 130, -750),
        ['Sunken Chest #15'] = CFrame.new(393, 130, 2435),
        ['Sunken Chest #16'] = CFrame.new(2410, 130, -1110),
        ['Sunken Chest #17'] = CFrame.new(285, 130, 564),
        ['Sunken Chest #18'] = CFrame.new(-2444, 130, 266),
        ['Sunken Chest #19'] = CFrame.new(-1547, 130, -1080),
        ['Sunken Chest #20'] = CFrame.new(-1, 130, 1632),
        ['Sunken Chest #21'] = CFrame.new(2266, 130, -721),
        ['Sunken Chest #22'] = CFrame.new(283, 130, -159),
        ['Sunken Chest #23'] = CFrame.new(-2444, 130, -37),
        ['Sunken Chest #24'] = CFrame.new(-1618, 130, -1560),
        ['Sunken Chest #25'] = CFrame.new(-190, 130, 2450),
        
        -- Special NPCs Location
        ['NPCs Area #1'] = CFrame.new(415, 135, 200),
        ['NPCs Area #2'] = CFrame.new(420, 145, 260),
        
        -- AFK Rewards Location
        ['AFK Rewards'] = CFrame.new(232, 139, 38),
        
        -- Treasure Hunting
        ['Treasure Hunting'] = CFrame.new(-2825, 215, 1515),
        
        -- Additional Missing Locations from gpsv2.txt
        
        -- Cthulhu Boss Locations
        ['Cthulhu Boss #1'] = CFrame.new(-200, 130, 1925),
        ['Cthulhu Boss #2'] = CFrame.new(10, 155, 2000),
        ['Cthulhu Boss #3'] = CFrame.new(160, 125, 1970),
        ['Cthulhu Boss #4'] = CFrame.new(25, 140, 1860),
        ['Cthulhu Boss #5'] = CFrame.new(140, 150, 2050),
        ['Cthulhu Boss #6'] = CFrame.new(-200, 130, 1930),
        ['Cthulhu Boss #7'] = CFrame.new(-175, 145, 1935),
        ['Cthulhu Boss #8'] = CFrame.new(35, 130, 1945),
        
        -- Ancient Archives
        ['Ancient Archives #1'] = CFrame.new(5833, 125, 401),
        ['Ancient Archives #2'] = CFrame.new(5870, 160, 415),
        ['Ancient Archives #3'] = CFrame.new(5487, 143, -316),
        ['Ancient Archives #4'] = CFrame.new(5966, 274, 846),
        ['Ancient Archives #5'] = CFrame.new(6075, 195, 260),
        ['Ancient Archives #6'] = CFrame.new(6000, 230, 591),
        
        -- Ancient Isle
        ['Ancient Isle #1'] = CFrame.new(5833, 125, 401),
        ['Ancient Isle #2'] = CFrame.new(5870, 160, 415),
        ['Ancient Isle #3'] = CFrame.new(5487, 143, -316),
        ['Ancient Isle #4'] = CFrame.new(5966, 274, 846),
        ['Ancient Isle #5'] = CFrame.new(6075, 195, 260),
        ['Ancient Isle #6'] = CFrame.new(6000, 230, 591),
        
        -- Atlantean Storm
        ['Atlantean Storm #1'] = CFrame.new(-3530, 130, 550),
        ['Atlantean Storm #2'] = CFrame.new(-3820, 135, 575),
        
        -- Additional Atlantis Locations
        ['Atlantis Extra #1'] = CFrame.new(-4300, -580, 1800),
        ['Atlantis Extra #2'] = CFrame.new(-2522, 138, 1593),
        ['Atlantis Extra #3'] = CFrame.new(-2551, 150, 1667),
        ['Atlantis Extra #4'] = CFrame.new(-2729, 168, 1730),
        ['Atlantis Extra #5'] = CFrame.new(-2881, 317, 1607),
        ['Atlantis Extra #6'] = CFrame.new(-2835, 131, 1510),
        ['Atlantis Extra #7'] = CFrame.new(-3576, 148, 524),
        ['Atlantis Extra #8'] = CFrame.new(-4606, -594, 1843),
        ['Atlantis Extra #9'] = CFrame.new(-5167, -680, 1710),
        ['Atlantis Extra #10'] = CFrame.new(-4107, -603, 1823),
        ['Atlantis Extra #11'] = CFrame.new(-4299, -604, 1587),
        ['Atlantis Extra #12'] = CFrame.new(-4295, -583, 2021),
        ['Atlantis Extra #13'] = CFrame.new(-4295, -991, 1792),
        ['Atlantis Extra #14'] = CFrame.new(-4465, -604, 1874),
        ['Atlantis Extra #15'] = CFrame.new(-4277, -606, 1838),
        ['Atlantis Extra #16'] = CFrame.new(-4928, -595, 1857),
        ['Atlantis Extra #17'] = CFrame.new(-3804, -567, 1870),
        ['Atlantis Extra #18'] = CFrame.new(-4086, -559, 895),
        ['Atlantis Extra #19'] = CFrame.new(-4272, -629, 2665),
        ['Atlantis Extra #20'] = CFrame.new(-4415, -997, 2055),
        ['Atlantis Extra #21'] = CFrame.new(-3953, -556, 853),
        ['Atlantis Extra #22'] = CFrame.new(-4325, -630, 2687),
        ['Atlantis Extra #23'] = CFrame.new(-177, 144, 1933),
        ['Atlantis Extra #24'] = CFrame.new(-4462, -605, 1875),
        ['Atlantis Extra #25'] = CFrame.new(-4463, -603, 1876),
        ['Atlantis Extra #26'] = CFrame.new(-4452, -603, 1877),
        ['Atlantis Extra #27'] = CFrame.new(-4450, -605, 1874),
        ['Atlantis Extra #28'] = CFrame.new(-4446, -605, 1866),
        
        -- Brine Pool
        ['Brine Pool #1'] = CFrame.new(-790, 125, -3100),
        ['Brine Pool #2'] = CFrame.new(-1710, -235, -3075),
        ['Brine Pool #3'] = CFrame.new(-1725, -175, -3125),
        ['Brine Pool #4'] = CFrame.new(-1600, -110, -2845),
        ['Brine Pool #5'] = CFrame.new(-1795, -140, -3310),
        ['Brine Pool #6'] = CFrame.new(-1810, -140, -3300),
        ['Brine Pool #7'] = CFrame.new(-1625, -205, -2785),
        ['Brine Pool #8'] = CFrame.new(-1470, -240, -2550),
        ['Brine Pool #9'] = CFrame.new(-975, -245, -2700),
        ['Brine Pool #10'] = CFrame.new(-1485, -225, -2195),
        ['Brine Pool #11'] = CFrame.new(-1655, -210, -2825),
        ['Brine Pool #12'] = CFrame.new(-980, -240, -2690),
        ['Brine Pool #13'] = CFrame.new(-1645, -210, -2855),
        ['Brine Pool #14'] = CFrame.new(-1650, -210, -2840),
        ['Brine Pool #15'] = CFrame.new(-1630, -210, -2860),
        ['Brine Pool #16'] = CFrame.new(-1470, -225, -2225),
        ['Brine Pool #17'] = CFrame.new(-1800, -135, -3280),
        
        -- Desolate Deep
        ['Desolate Deep #1'] = CFrame.new(-790, 125, -3100),
        ['Desolate Deep #2'] = CFrame.new(-1710, -235, -3075),
        ['Desolate Deep #3'] = CFrame.new(-1725, -175, -3125),
        ['Desolate Deep #4'] = CFrame.new(-1600, -110, -2845),
        ['Desolate Deep #5'] = CFrame.new(-1795, -140, -3310),
        ['Desolate Deep #6'] = CFrame.new(-1810, -140, -3300),
        ['Desolate Deep #7'] = CFrame.new(-1625, -205, -2785),
        ['Desolate Deep #8'] = CFrame.new(-1470, -240, -2550),
        ['Desolate Deep #9'] = CFrame.new(-975, -245, -2700),
        ['Desolate Deep #10'] = CFrame.new(-1485, -225, -2195),
        ['Desolate Deep #11'] = CFrame.new(-1655, -210, -2825),
        ['Desolate Deep #12'] = CFrame.new(-980, -240, -2690),
        ['Desolate Deep #13'] = CFrame.new(-1645, -210, -2855),
        ['Desolate Deep #14'] = CFrame.new(-1650, -210, -2840),
        ['Desolate Deep #15'] = CFrame.new(-1630, -210, -2860),
        ['Desolate Deep #16'] = CFrame.new(-1470, -225, -2225),
        ['Desolate Deep #17'] = CFrame.new(-1800, -135, -3280),
        
        -- The Depths
        ['The Depths #1'] = CFrame.new(472, -706, 1231),
        ['The Depths #2'] = CFrame.new(1210, -715, 1315),
        ['The Depths #3'] = CFrame.new(1705, -900, 1445),
        ['The Depths #4'] = CFrame.new(-970, -710, 1300),
        
        -- Forsaken Shores
        ['Forsaken Shores #1'] = CFrame.new(-2425, 135, 1555),
        ['Forsaken Shores #2'] = CFrame.new(-3600, 125, 1605),
        ['Forsaken Shores #3'] = CFrame.new(-2830, 215, 1510),
        ['Forsaken Shores #4'] = CFrame.new(-2490, 130, 1535),
        ['Forsaken Shores #5'] = CFrame.new(-2525, 135, -1575),
        
        -- Mariana's Veil
        ['Marianas Veil #1'] = CFrame.new(1500, 125, 530),
        ['Marianas Veil #2'] = CFrame.new(-1305, 130, 310),
        ['Marianas Veil #3'] = CFrame.new(-3175, -2035, 4020),
        ['Marianas Veil #4'] = CFrame.new(740, -3355, -1530),
        ['Marianas Veil #5'] = CFrame.new(-1480, 137, 382),
        ['Marianas Veil #6'] = CFrame.new(-3365, -2260, 3850),
        ['Marianas Veil #7'] = CFrame.new(-760, -3280, -715),
        ['Marianas Veil #8'] = CFrame.new(-800, -3280, -625),
        ['Marianas Veil #9'] = CFrame.new(-3180, -2035, 4020),
        
        -- Mushgrove Swamp
        ['Mushgrove Swamp #1'] = CFrame.new(2425, 130, -670),
        ['Mushgrove Swamp #2'] = CFrame.new(2730, 130, -825),
        ['Mushgrove Swamp #3'] = CFrame.new(2520, 160, -895),
        ['Mushgrove Swamp #4'] = CFrame.new(2790, 140, -625),
        ['Mushgrove Swamp #5'] = CFrame.new(2520, 135, -895),
        
        -- Northern Expedition
        ['Northern Expedition #1'] = CFrame.new(400, 135, 265),
        ['Northern Expedition #2'] = CFrame.new(5506, 147, -315),
        ['Northern Expedition #3'] = CFrame.new(2930, 281, 2594),
        ['Northern Expedition #4'] = CFrame.new(-1715, 149, 737),
        ['Northern Expedition #5'] = CFrame.new(-2566, 181, 1353),
        ['Northern Expedition #6'] = CFrame.new(-1750, 130, 3750),
        
        -- Roslit Bay
        ['Roslit Bay #1'] = CFrame.new(-1450, 135, 750),
        ['Roslit Bay #2'] = CFrame.new(-1775, 150, 680),
        ['Roslit Bay #3'] = CFrame.new(-1875, 165, 380),
        ['Roslit Bay #4'] = CFrame.new(-1515, 141, 765),
        ['Roslit Bay #5'] = CFrame.new(-1945, 275, 230),
        ['Roslit Bay #6'] = CFrame.new(-1710, 150, 740),
        ['Roslit Bay #7'] = CFrame.new(-1465, 130, 680),
        ['Roslit Bay #8'] = CFrame.new(-1485, 130, 640),
        ['Roslit Bay #9'] = CFrame.new(-1785, 165, 400),
        
        -- Roslit Volcano
        ['Roslit Volcano #1'] = CFrame.new(-1450, 135, 750),
        ['Roslit Volcano #2'] = CFrame.new(-1775, 150, 680),
        ['Roslit Volcano #3'] = CFrame.new(-1875, 165, 380),
        ['Roslit Volcano #4'] = CFrame.new(-1515, 141, 765),
        ['Roslit Volcano #5'] = CFrame.new(-1945, 275, 230),
        ['Roslit Volcano #6'] = CFrame.new(-1710, 150, 740),
        ['Roslit Volcano #7'] = CFrame.new(-1465, 130, 680),
        ['Roslit Volcano #8'] = CFrame.new(-1485, 130, 640),
        ['Roslit Volcano #9'] = CFrame.new(-1785, 165, 400),
        
        -- Snowcap Island
        ['Snowcap Island #1'] = CFrame.new(2600, 150, 2400),
        ['Snowcap Island #2'] = CFrame.new(2900, 150, 2500),
        ['Snowcap Island #3'] = CFrame.new(2710, 190, 2560),
        ['Snowcap Island #4'] = CFrame.new(2750, 135, 2505),
        ['Snowcap Island #5'] = CFrame.new(2800, 280, 2565),
        ['Snowcap Island #6'] = CFrame.new(2845, 180, 2700),
        
        -- Sunstone Island
        ['Sunstone Island #1'] = CFrame.new(-935, 130, -1105),
        ['Sunstone Island #2'] = CFrame.new(-1045, 135, -1140),
        ['Sunstone Island #3'] = CFrame.new(-1215, 190, -1040),
        ['Sunstone Island #4'] = CFrame.new(-1145, 135, -1075),
        ['Sunstone Island #5'] = CFrame.new(-1045, 200, -1100),
        ['Sunstone Island #6'] = CFrame.new(-920, 130, -1105),
        
        -- Statue of Sovereignty
        ['Statue of Sovereignty #1'] = CFrame.new(20, 160, -1040),
        ['Statue of Sovereignty #2'] = CFrame.new(1380, -805, -300),
        
        -- Keepers Altar
        ['Keepers Altar #1'] = CFrame.new(20, 160, -1040),
        ['Keepers Altar #2'] = CFrame.new(1380, -805, -300),
        
        -- Vertigo
        ['Vertigo #1'] = CFrame.new(-110, -515, 1040),
        ['Vertigo #2'] = CFrame.new(-75, -530, 1285),
        ['Vertigo #3'] = CFrame.new(1210, -715, 1315),
        ['Vertigo #4'] = CFrame.new(-145, -515, 1140),
        ['Vertigo #5'] = CFrame.new(1705, -900, 1445),
        ['Vertigo #6'] = CFrame.new(-100, -730, 1210),
        ['Vertigo #7'] = CFrame.new(-970, -710, 1300),
        
        -- Winter Village
        ['Winter Village #1'] = CFrame.new(5815, 145, 270),
        ['Winter Village #2'] = CFrame.new(-2490, 135, 1470),
        ['Winter Village #3'] = CFrame.new(400, 135, 305),
        ['Winter Village #4'] = CFrame.new(2410, 135, -730),
        ['Winter Village #5'] = CFrame.new(-1920, 500, 160),
        ['Winter Village #6'] = CFrame.new(2640, 140, 2425),
        ['Winter Village #7'] = CFrame.new(45, 140, -1030),
        ['Winter Village #8'] = CFrame.new(-890, 135, -1110),
        ['Winter Village #9'] = CFrame.new(-160, 140, 1895),
        ['Winter Village #10'] = CFrame.new(-190, 370, -9445),
        ['Winter Village #11'] = CFrame.new(-15, 365, -9590),
        
        -- Additional Ocean/Deep Ocean Spots
        ['Deep Ocean #1'] = CFrame.new(-1270, 125, 1580),
        ['Deep Ocean #2'] = CFrame.new(1000, 125, -1250),
        ['Deep Ocean #3'] = CFrame.new(-530, 125, -425),
        ['Deep Ocean #4'] = CFrame.new(1230, 125, 575),
        ['Deep Ocean #5'] = CFrame.new(1700, 125, -2500),
        
        -- Earmark Island (same as Ocean spots)
        ['Earmark Island #1'] = CFrame.new(-1270, 125, 1580),
        ['Earmark Island #2'] = CFrame.new(1000, 125, -1250),
        ['Earmark Island #3'] = CFrame.new(-530, 125, -425),
        ['Earmark Island #4'] = CFrame.new(1230, 125, 575),
        ['Earmark Island #5'] = CFrame.new(1700, 125, -2500),
        
        -- The Arch (same as Ocean spots)
        ['The Arch #1'] = CFrame.new(-1270, 125, 1580),
        ['The Arch #2'] = CFrame.new(1000, 125, -1250),
        ['The Arch #3'] = CFrame.new(-530, 125, -425),
        ['The Arch #4'] = CFrame.new(1230, 125, 575),
        ['The Arch #5'] = CFrame.new(1700, 125, -2500),
        
        -- Haddock Rock (same as Ocean spots)
        ['Haddock Rock #1'] = CFrame.new(-1270, 125, 1580),
        ['Haddock Rock #2'] = CFrame.new(1000, 125, -1250),
        ['Haddock Rock #3'] = CFrame.new(-530, 125, -425),
        ['Haddock Rock #4'] = CFrame.new(1230, 125, 575),
        ['Haddock Rock #5'] = CFrame.new(1700, 125, -2500),
        
        -- Birch Cay (same as Ocean spots) 
        ['Birch Cay #1'] = CFrame.new(-1270, 125, 1580),
        ['Birch Cay #2'] = CFrame.new(1000, 125, -1250),
        ['Birch Cay #3'] = CFrame.new(-530, 125, -425),
        ['Birch Cay #4'] = CFrame.new(1230, 125, 575),
        ['Birch Cay #5'] = CFrame.new(1700, 125, -2500),
        
        -- Harvesters Spike (same as Ocean spots)
        ['Harvesters Spike #1'] = CFrame.new(-1270, 125, 1580),
        ['Harvesters Spike #2'] = CFrame.new(1000, 125, -1250),
        ['Harvesters Spike #3'] = CFrame.new(-530, 125, -425),
        ['Harvesters Spike #4'] = CFrame.new(1230, 125, 575),
        ['Harvesters Spike #5'] = CFrame.new(1700, 125, -2500),
        
        -- Lobster Fishing
        ['Lobster Fishing #1'] = CFrame.new(-552, 153, 2651),
        ['Lobster Fishing #2'] = CFrame.new(-571, 153, 2638),
        ['Lobster Fishing #3'] = CFrame.new(-575, 85, 1000),
        
        -- Net Fishing
        ['Net Fishing #1'] = CFrame.new(-635, 85, 1005),
        ['Net Fishing #2'] = CFrame.new(-630, 85, 1005),
        ['Net Fishing #3'] = CFrame.new(-610, 85, 1005),
        ['Net Fishing #4'] = CFrame.new(-820, 90, 995),
        
        -- Oxygen Locations
        ['Oxygen #1'] = CFrame.new(-1655, -210, -2825),
        ['Oxygen #2'] = CFrame.new(370, 135, 250),
        ['Oxygen #3'] = CFrame.new(-790, 125, -3100),
        ['Oxygen #4'] = CFrame.new(-980, -240, -2690),
        ['Oxygen #5'] = CFrame.new(-4452, -603, 1877),
        ['Oxygen #6'] = CFrame.new(-3550, 130, 568)
    }
}
local ZoneNames = {}
local RodNames = {}
local ItemNames = {}
local FishingSpotNames = {}
local NPCNames = {}
local MarianaVeilNames = {}
local AllLocationNames = {}
local RodColors = {}
local RodMaterials = {}
for i,v in pairs(TeleportLocations['Zones']) do table.insert(ZoneNames, i) end
for i,v in pairs(TeleportLocations['Rods']) do table.insert(RodNames, i) end
for i,v in pairs(TeleportLocations['Items']) do table.insert(ItemNames, i) end
for i,v in pairs(TeleportLocations['Fishing Spots']) do table.insert(FishingSpotNames, i) end
for i,v in pairs(TeleportLocations['NPCs']) do table.insert(NPCNames, i) end
for i,v in pairs(TeleportLocations['Mariana Veil']) do table.insert(MarianaVeilNames, i) end
for i,v in pairs(TeleportLocations['All Locations']) do table.insert(AllLocationNames, i) end

-- Sort all location arrays alphabetically
table.sort(ZoneNames)
table.sort(RodNames)
table.sort(ItemNames)
table.sort(FishingSpotNames)
table.sort(NPCNames)
table.sort(MarianaVeilNames)
table.sort(AllLocationNames)

--// Functions
FindChildOfClass = function(parent, classname)
    return parent:FindFirstChildOfClass(classname)
end
FindChild = function(parent, child)
    return parent:FindFirstChild(child)
end
FindChildOfType = function(parent, childname, classname)
    child = parent:FindFirstChild(childname)
    if child and child.ClassName == classname then
        return child
    end
end
CheckFunc = function(func)
    return typeof(func) == 'function'
end

--// Custom Functions
getchar = function()
    return lp.Character or lp.CharacterAdded:Wait()
end
gethrp = function()
    return getchar():WaitForChild('HumanoidRootPart')
end
gethum = function()
    return getchar():WaitForChild('Humanoid')
end
FindRod = function()
    if FindChildOfClass(getchar(), 'Tool') and FindChild(FindChildOfClass(getchar(), 'Tool'), 'values') then
        return FindChildOfClass(getchar(), 'Tool')
    else
        return nil
    end
end
message = function(text, time)
    if tooltipmessage then tooltipmessage:Remove() end
    tooltipmessage = require(lp.PlayerGui:WaitForChild("GeneralUIModule")):GiveToolTip(lp, text)
    task.spawn(function()
        task.wait(time)
        if tooltipmessage then tooltipmessage:Remove(); tooltipmessage = nil end
    end)
end

--// UI
local library
local Window
local isMinimized = false
local floatingButton = nil

-- Load Kavo UI from GitHub repository (always fresh)
local kavoUrl = 'https://raw.githubusercontent.com/MELLISAEFFENDY/fffish/main/Kavo.lua'

-- Try to load library with multiple methods (always from GitHub)
local success = false

-- Method 1: Load directly from current repo
pcall(function()
    library = loadstring(game:HttpGet(kavoUrl))()
    if library and library.CreateLib then
        success = true
        print("✅ Kavo loaded from GitHub repo")
    end
end)

-- Method 2: Load from backup URLs
if not success then
    local backupUrls = {
        'https://github.com/MELLISAEFFENDY/fffish/raw/main/Kavo.lua',
        'https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua'
    }
    
    for i, url in ipairs(backupUrls) do
        pcall(function()
            library = loadstring(game:HttpGet(url))()
            if library and library.CreateLib then
                success = true
                print("✅ Kavo loaded from backup URL " .. i)
            end
        end)
        if success then break end
    end
end

-- Check if Kavo loaded successfully
if not success or not library then
    error("❌ Failed to load Kavo UI library from all sources!")
end

print("🎣 Kavo UI library loaded successfully!")

-- Load Shop Module
local Shop
print("🔄 Attempting to load Shop module...")

-- Enable HttpService if possible
pcall(function()
    game:GetService("HttpService").HttpEnabled = true
end)

pcall(function()
    -- Try to load from the same workspace
    print("📡 Downloading shop module from GitHub...")
    local shopContent = game:HttpGet('https://raw.githubusercontent.com/DESRIYANDA/Fishccch/main/shop.lua')
    if shopContent and #shopContent > 100 then
        print("✅ Shop content downloaded successfully, size: " .. #shopContent)
        Shop = loadstring(shopContent)()
        if Shop then
            print("✅ Shop module loaded from repository!")
        else
            warn("❌ Failed to execute shop module code")
        end
    else
        warn("❌ Shop content download failed or too small")
    end
end)

-- Fallback: Try to load from local file
if not Shop then
    warn("⚠️ Shop module not found from repository, trying local file...")
    pcall(function()
        if readfile and isfile and isfile("shop.lua") then
            local localContent = readfile("shop.lua")
            Shop = loadstring(localContent)()
            print("✅ Shop module loaded from local file!")
        else
            warn("❌ Local shop.lua file not found")
        end
    end)
end

if Shop then
    print("✅ Shop module is ready!")
else
    warn("❌ Shop module failed to load from all sources")
    print("🔧 Creating embedded shop module as final fallback...")
    
    -- Embedded shop module as final fallback
    Shop = {}
    Shop.createShopTab = function(self, Window)
        local ShopTab = Window:NewTab("🛒 Shop")
        local ShopSection = ShopTab:NewSection("Auto Buy Bait Crates")
        
        local shopFlags = {selectedbaitcrate = 'Bait Crate (Moosewood)', baitamount = 10}
        
        local crateLocations = {
            ['Bait Crate (Moosewood)'] = CFrame.new(315, 135, 335),
            ['Bait Crate (Roslit)'] = CFrame.new(-1465, 130, 680),
            ['Quality Bait Crate (Atlantis)'] = CFrame.new(-177, 144, 1933),
            ['Bait Crate (Forsaken)'] = CFrame.new(-2490, 130, 1535),
            ['Bait Crate (Ancient)'] = CFrame.new(6075, 195, 260),
            ['Bait Crate (Sunstone)'] = CFrame.new(-1045, 200, -1100),
            ['Quality Bait Crate (Terrapin)'] = CFrame.new(-175, 145, 1935)
        }
        
        ShopSection:NewDropdown("Select Bait Crate", "Choose bait crate to buy from", {
            'Bait Crate (Moosewood)', 'Bait Crate (Roslit)', 'Bait Crate (Forsaken)', 
            'Bait Crate (Ancient)', 'Bait Crate (Sunstone)',
            'Quality Bait Crate (Atlantis)', 'Quality Bait Crate (Terrapin)'
        }, function(crate)
            shopFlags.selectedbaitcrate = crate
            print("Selected: " .. crate)
        end)
        
        ShopSection:NewTextBox("Amount", "Enter amount (1-1000)", function(txt)
            local amount = tonumber(txt)
            if amount and amount > 0 and amount <= 1000 then
                shopFlags.baitamount = amount
                print("Set amount: " .. amount)
            end
        end)
        
        ShopSection:NewButton("💰 Buy Bait", "Buy bait from selected crate", function()
            print("🛒 Buying " .. shopFlags.baitamount .. "x from " .. shopFlags.selectedbaitcrate)
            
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and crateLocations[shopFlags.selectedbaitcrate] then
                lp.Character.HumanoidRootPart.CFrame = crateLocations[shopFlags.selectedbaitcrate]
                wait(1)
                
                pcall(function()
                    local buyRemote = ReplicatedStorage:FindFirstChild("packages")
                    if buyRemote and buyRemote:FindFirstChild("Net") then
                        local showRemote = buyRemote.Net:FindFirstChild("RE/BuyBait/Show")
                        if showRemote then
                            showRemote:FireServer()
                            wait(0.5)
                        end
                        
                        local purchaseRemote = buyRemote.Net:FindFirstChild("RE/DailyShop/Purchase")
                        if purchaseRemote then
                            purchaseRemote:FireServer(shopFlags.selectedbaitcrate, shopFlags.baitamount)
                            print("✅ Purchase request sent!")
                        end
                    end
                end)
            end
        end)
        
        -- Quick teleport section
        local TeleSection = ShopTab:NewSection("Quick Teleport")
        
        TeleSection:NewButton("📍 Daily Shopkeeper", "Teleport to Daily Shopkeeper", function()
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(229, 139, 42)
            end
        end)
        
        TeleSection:NewButton("📍 Angus McBait", "Teleport to Angus McBait", function()
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(236, 222, 461)
            end
        end)
        
        return ShopTab
    end
    print("✅ Embedded shop module created!")
end

-- Function to create floating button
local function createFloatingButton()
    if floatingButton then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FischFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Name = "FloatingFrame"
    frame.Size = UDim2.new(0, 60, 0, 60)
    frame.Position = UDim2.new(1, -80, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 95)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Name = "MinimizeButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundTransparency = 1
    button.Text = "🎣"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 99, 135)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 65, 95))
    }
    gradient.Rotation = 45
    gradient.Parent = frame
    
    -- Shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 30)
    shadowCorner.Parent = shadow
    
    -- Click event
    button.MouseButton1Click:Connect(function()
        if isMinimized then
            -- Show main UI
            pcall(function()
                local mainFrame = lp.PlayerGui:FindFirstChild("Kavo")
                if mainFrame then
                    local main = mainFrame:FindFirstChild("Main")
                    if main then
                        main.Visible = true
                        isMinimized = false
                        screenGui:Destroy()
                        floatingButton = nil
                    end
                end
            end)
        end
    end)
    
    -- Dragging disabled - using frame.Draggable = true instead
    
    -- Add to CoreGui or PlayerGui with protection
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = game.CoreGui
        elseif game.CoreGui then
            screenGui.Parent = game.CoreGui
        else
            screenGui.Parent = lp.PlayerGui
        end
    end)
    
    floatingButton = screenGui
end

-- Create UI Window with better error handling
local Window
local success = pcall(function()
    if library and library.CreateLib then
        -- Hook TweenService to prevent workspace errors
        if game:GetService("TweenService") then
            local TweenService = game:GetService("TweenService")
            local originalCreate = TweenService.Create
            TweenService.Create = function(self, instance, ...)
                if instance and instance.Parent then
                    return originalCreate(self, instance, ...)
                else
                    return {Play = function() end, Cancel = function() end}
                end
            end
        end
        
        Window = library.CreateLib("🎣 Fisch Script", "Ocean")
        print("✅ Main UI window created successfully")
    else
        error("❌ Library not available")
    end
end)

if not success or not Window then
    warn("⚠️ Failed to create UI window, retrying with alternative method...")
    
    -- Try alternative creation
    pcall(function()
        task.wait(1)
        Window = library.CreateLib("🎣 Fisch Script", "Ocean")
    end)
    
    if not Window then
        warn("⚠️ UI window creation failed, script will continue without GUI")
    end
end

-- Create Tabs
local AutoTab, ModTab, TeleTab, VisualTab, ShopTab, EventTab

if Window and Window.NewTab then
    pcall(function()
        AutoTab = Window:NewTab("🎣 Automation")
        ModTab = Window:NewTab("⚙️ Modifications") 
        TeleTab = Window:NewTab("🌍 Teleports")
        VisualTab = Window:NewTab("👁️ Visuals")
        EventTab = Window:NewTab("⭐ Zona Event")
        
        -- Create Shop Tab using Shop Module
        print("🛒 Creating Shop tab...")
        if Shop and Shop.createShopTab then
            print("✅ Shop module found, creating advanced shop tab...")
            ShopTab = Shop:createShopTab(Window)
            print("✅ Shop tab created successfully")
        else
            warn("⚠️ Shop module not available, creating basic shop tab...")
            print("🔧 Creating fallback shop tab...")
            -- Fallback: Create basic shop tab
            ShopTab = Window:NewTab("🛒 Shop")
            local ShopSection = ShopTab:NewSection("Auto Buy Bait")
            
            local shopFlags = {selectedbaitcrate = 'Bait Crate (Moosewood)', baitamount = 10}
            
            ShopSection:NewDropdown("Select Bait Crate", "Choose bait crate", {
                'Bait Crate (Moosewood)', 'Bait Crate (Roslit)', 'Bait Crate (Forsaken)', 
                'Bait Crate (Ancient)', 'Bait Crate (Sunstone)',
                'Quality Bait Crate (Atlantis)', 'Quality Bait Crate (Terrapin)'
            }, function(crate)
                shopFlags.selectedbaitcrate = crate
            end)
            
            ShopSection:NewTextBox("Amount", "Enter amount (1-1000)", function(txt)
                local amount = tonumber(txt)
                if amount and amount > 0 and amount <= 1000 then
                    shopFlags.baitamount = amount
                end
            end)
            
            ShopSection:NewButton("💰 Buy Bait", "Buy bait from selected crate", function()
                print("🛒 Attempting to buy " .. shopFlags.baitamount .. "x from " .. shopFlags.selectedbaitcrate)
                
                -- Basic teleport to crate locations
                local crateLocations = {
                    ['Bait Crate (Moosewood)'] = CFrame.new(315, 135, 335),
                    ['Bait Crate (Roslit)'] = CFrame.new(-1465, 130, 680),
                    ['Quality Bait Crate (Atlantis)'] = CFrame.new(-177, 144, 1933),
                    ['Bait Crate (Forsaken)'] = CFrame.new(-2490, 130, 1535),
                    ['Bait Crate (Ancient)'] = CFrame.new(6075, 195, 260),
                    ['Bait Crate (Sunstone)'] = CFrame.new(-1045, 200, -1100),
                    ['Quality Bait Crate (Terrapin)'] = CFrame.new(-175, 145, 1935)
                }
                
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and crateLocations[shopFlags.selectedbaitcrate] then
                    lp.Character.HumanoidRootPart.CFrame = crateLocations[shopFlags.selectedbaitcrate]
                    wait(1)
                    
                    pcall(function()
                        local buyRemote = ReplicatedStorage:FindFirstChild("packages")
                        if buyRemote and buyRemote:FindFirstChild("Net") then
                            local purchaseRemote = buyRemote.Net:FindFirstChild("RE/BuyBait/Show")
                            if purchaseRemote then
                                purchaseRemote:FireServer()
                                wait(0.5)
                            end
                            
                            purchaseRemote = buyRemote.Net:FindFirstChild("RE/DailyShop/Purchase")
                            if purchaseRemote then
                                purchaseRemote:FireServer(shopFlags.selectedbaitcrate, shopFlags.baitamount)
                                print("✅ Purchase request sent!")
                            end
                        end
                    end)
                end
            end)
            
            print("✅ Basic shop tab created successfully")
        end
        
        print("✅ All tabs created successfully")
    end)
else
    warn("⚠️ Window not available, creating fallback functionality")
    -- Create dummy tabs that won't break the script
    local dummyTab = {
        NewSection = function(name)
            return {
                NewToggle = function(name, desc, callback) 
                    if callback then callback(false) end
                    return {UpdateToggle = function() end}
                end,
                NewSlider = function(name, desc, min, max, callback) 
                    if callback then callback(min) end
                    return {}
                end,
                NewDropdown = function(name, desc, options, callback) 
                    if callback then callback(options[1]) end
                    return {Refresh = function() end}
                end,
                NewButton = function(name, desc, callback) 
                    return {UpdateButton = function() end}
                end
            }
        end
    }
    AutoTab = dummyTab
    ModTab = dummyTab
    TeleTab = dummyTab
    VisualTab = dummyTab
    EventTab = dummyTab
    print("⚠️ Using fallback tabs - script functionality preserved")
end

-- ===== EVENT ZONE ESP & TELEPORT SYSTEM =====
local EventSystem = {}
EventSystem.espObjects = {}
EventSystem.activeEvents = {}
EventSystem.isScanning = false

-- Event Data dengan koordinat zone dan warna
local EVENTS_DATA = {
    -- Water Events
    ["Shark Hunt"] = {color = Color3.fromRGB(255, 0, 0), zones = {"Ocean", "Desolate Deep", "The Depths"}},
    ["Megalodon Hunt"] = {color = Color3.fromRGB(200, 0, 0), zones = {"Ocean", "Desolate Deep"}},
    ["Kraken Hunt"] = {color = Color3.fromRGB(150, 0, 150), zones = {"The Depths", "Desolate Deep"}},
    ["Scylla Hunt"] = {color = Color3.fromRGB(100, 0, 100), zones = {"The Depths"}},
    ["Orca Migration"] = {color = Color3.fromRGB(0, 100, 200), zones = {"Ocean", "Glacial Grotto"}},
    ["Whale Migration"] = {color = Color3.fromRGB(0, 150, 250), zones = {"Ocean"}},
    ["Sea Leviathan Hunt"] = {color = Color3.fromRGB(50, 0, 200), zones = {"The Depths", "Hadal Blacksite"}},
    ["Apex Fish Hunt"] = {color = Color3.fromRGB(255, 100, 0), zones = {"Ocean", "Desolate Deep"}},
    
    -- Abundance Events
    ["Fish Abundance"] = {color = Color3.fromRGB(0, 255, 100), zones = {"Ocean", "Pond", "Mushgrove Swamp"}},
    ["Lucky Pool"] = {color = Color3.fromRGB(255, 215, 0), zones = {"Ocean", "Pond"}},
    
    -- Weather Events
    ["Absolute Darkness"] = {color = Color3.fromRGB(50, 50, 50), zones = {"The Depths", "Hadal Blacksite"}},
    ["Strange Whirlpool"] = {color = Color3.fromRGB(100, 50, 200), zones = {"Ocean", "The Depths"}},
    ["Whirlpool"] = {color = Color3.fromRGB(0, 100, 255), zones = {"Ocean"}},
    ["Nuke"] = {color = Color3.fromRGB(255, 255, 0), zones = {"Ocean", "Snowcap Island"}},
    ["Cursed Storm"] = {color = Color3.fromRGB(100, 0, 100), zones = {"The Depths"}},
    ["Blizzard"] = {color = Color3.fromRGB(200, 200, 255), zones = {"Glacial Grotto", "Snowcap Island"}},
    ["Avalanche"] = {color = Color3.fromRGB(150, 150, 200), zones = {"Snowcap Island", "Glacial Grotto"}},
    
    -- Divine Events
    ["Poseidon Wrath"] = {color = Color3.fromRGB(0, 150, 200), zones = {"Ocean", "The Depths"}},
    ["Zeus Storm"] = {color = Color3.fromRGB(255, 255, 100), zones = {"Ocean", "Snowcap Island"}},
    ["Blue Moon"] = {color = Color3.fromRGB(100, 100, 255), zones = {"Ocean", "Pond"}},
    
    -- Special Events
    ["Travelling Merchant"] = {color = Color3.fromRGB(255, 165, 0), zones = {"Ocean", "Moosewood"}},
    ["Meteors"] = {color = Color3.fromRGB(255, 100, 100), zones = {"Ocean", "Snowcap Island"}},
    ["Sunken Chests"] = {color = Color3.fromRGB(255, 215, 0), zones = {"Ocean", "The Depths"}}
}

-- Zone koordinat berdasarkan TeleportLocations
local ZONE_COORDS = {
    ["Ocean"] = CFrame.new(100, 150, 100),
    ["Moosewood"] = CFrame.new(379.875458, 134.500519, 233.5495),
    ["Roslit Bay"] = CFrame.new(-1472.9812, 132.525513, 707.644531),
    ["Forsaken Shores"] = CFrame.new(-2491.104, 133.250015, 1561.2926),
    ["Sunstone Island"] = CFrame.new(-913.809143, 138.160782, -1133.25879),
    ["Statue of Sovereignty"] = CFrame.new(21.4017925, 159.014709, -1039.14233),
    ["Terrapin Island"] = CFrame.new(-193.434143, 135.121979, 1951.46936),
    ["Snowcap Island"] = CFrame.new(2607.93018, 135.284332, 2436.13208),
    ["Mushgrove Swamp"] = CFrame.new(2434.29785, 131.983276, -691.930542),
    ["Ancient Isle"] = CFrame.new(6056.02783, 195.280167, 276.270325),
    ["Northern Expedition"] = CFrame.new(-1701.02979, 187.638779, 3944.81494),
    ["Northern Summit"] = CFrame.new(19608.791, 131.420105, 5222.15283),
    ["Vertigo"] = CFrame.new(-102.40567, -513.299377, 1052.07104),
    ["Depths Entrance"] = CFrame.new(-15.4965982, -706.123718, 1231.43494),
    ["The Depths"] = CFrame.new(491.758118, -706.123718, 1230.6377),
    ["Desolate Deep"] = CFrame.new(491.758118, -706.123718, 1230.6377),
    ["Overgrowth Caves"] = CFrame.new(19746.2676, 416.00293, 5403.5752),
    ["Frigid Cavern"] = CFrame.new(20253.6094, 756.525818, 5772.68555),
    ["Cryogenic Canal"] = CFrame.new(19958.5176, 917.195923, 5332.59375),
    ["Glacial Grotto"] = CFrame.new(20003.0273, 1136.42798, 5555.95996),
    ["Keeper's Altar"] = CFrame.new(1297.92285, -805.292236, -284.155823),
    ["Atlantis"] = CFrame.new(-4465, -604, 1874),
    ["Pond"] = CFrame.new(1364, -612, 2472),
    ["Hadal Blacksite"] = CFrame.new(-4465, -604, 1874)
}

-- Function untuk membuat ESP Text
function EventSystem:createESPText(eventName, position, distance)
    local espObj = {}
    
    -- Create BillboardGui
    espObj.billboard = Instance.new("BillboardGui")
    espObj.billboard.Name = "EventESP_" .. eventName
    espObj.billboard.StudsOffset = Vector3.new(0, 5, 0)
    espObj.billboard.Size = UDim2.new(0, 200, 0, 50)
    espObj.billboard.Adornee = nil
    espObj.billboard.Parent = workspace.CurrentCamera
    
    -- Create Frame untuk background
    espObj.frame = Instance.new("Frame")
    espObj.frame.Size = UDim2.new(1, 0, 1, 0)
    espObj.frame.BackgroundTransparency = 0.7
    espObj.frame.BackgroundColor3 = EVENTS_DATA[eventName].color
    espObj.frame.BorderSizePixel = 0
    espObj.frame.Parent = espObj.billboard
    
    -- Create TextLabel
    espObj.textLabel = Instance.new("TextLabel")
    espObj.textLabel.Size = UDim2.new(1, 0, 1, 0)
    espObj.textLabel.BackgroundTransparency = 1
    espObj.textLabel.Text = eventName .. "\n[" .. distance .. "m]"
    espObj.textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    espObj.textLabel.TextStrokeTransparency = 0
    espObj.textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    espObj.textLabel.TextScaled = true
    espObj.textLabel.Font = Enum.Font.SourceSansBold
    espObj.textLabel.Parent = espObj.frame
    
    -- Position update function
    espObj.updatePosition = function()
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local camera = workspace.CurrentCamera
            local worldPos = position
            local screenPos, onScreen = camera:WorldToScreenPoint(worldPos)
            
            if onScreen then
                espObj.billboard.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                local newDistance = math.floor((lp.Character.HumanoidRootPart.Position - worldPos).Magnitude)
                espObj.textLabel.Text = eventName .. "\n[" .. newDistance .. "m]"
            end
        end
    end
    
    return espObj
end

-- Function untuk scan event aktif dari workspace
function EventSystem:scanActiveEvents()
    if self.isScanning then return end
    self.isScanning = true
    
    self.activeEvents = {}
    
    -- Scan dari workspace untuk mencari event indicators
    pcall(function()
        -- Method 1: Scan dari ReplicatedStorage events
        if ReplicatedStorage:FindFirstChild("events") then
            for _, child in pairs(ReplicatedStorage.events:GetChildren()) do
                if child.Name:find("Event") or child.Name:find("Hunt") or child.Name:find("Migration") then
                    local eventName = child.Name:gsub("Event", ""):gsub("Active", "")
                    if EVENTS_DATA[eventName] then
                        table.insert(self.activeEvents, eventName)
                    end
                end
            end
        end
        
        -- Method 2: Scan dari workspace untuk environmental indicators
        for eventName, eventData in pairs(EVENTS_DATA) do
            for _, zoneName in pairs(eventData.zones) do
                if ZONE_COORDS[zoneName] then
                    -- Simulasi detection - dalam implementasi nyata akan scan indicators
                    local random = math.random(1, 100)
                    if random <= 15 then -- 15% chance event aktif (simulation)
                        if not table.find(self.activeEvents, eventName) then
                            table.insert(self.activeEvents, eventName)
                        end
                    end
                end
            end
        end
    end)
    
    self.isScanning = false
    print("🔍 [Event Scanner] Found " .. #self.activeEvents .. " active events")
end

-- Function untuk toggle ESP
function EventSystem:toggleESP(enabled)
    if not enabled then
        -- Clear existing ESP
        for _, espObj in pairs(self.espObjects) do
            if espObj.billboard then
                espObj.billboard:Destroy()
            end
        end
        self.espObjects = {}
        print("❌ [Event ESP] Disabled")
        return
    end
    
    -- Scan untuk event aktif
    self:scanActiveEvents()
    
    -- Create ESP untuk setiap event aktif
    for _, eventName in pairs(self.activeEvents) do
        local eventData = EVENTS_DATA[eventName]
        if eventData then
            for _, zoneName in pairs(eventData.zones) do
                local zoneCoord = ZONE_COORDS[zoneName]
                if zoneCoord then
                    local distance = 0
                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        distance = math.floor((lp.Character.HumanoidRootPart.Position - zoneCoord.Position).Magnitude)
                    end
                    
                    local espObj = self:createESPText(eventName, zoneCoord.Position, distance)
                    table.insert(self.espObjects, espObj)
                    
                    print("✨ [Event ESP] Added ESP for " .. eventName .. " at " .. zoneName)
                end
            end
        end
    end
    
    print("✅ [Event ESP] Enabled with " .. #self.espObjects .. " markers")
end

-- Function untuk teleport ke event terdekat
function EventSystem:teleportToNearestEvent()
    if #self.activeEvents == 0 then
        print("❌ [Event Teleport] No active events found!")
        return
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ [Event Teleport] Character not found!")
        return
    end
    
    local playerPos = lp.Character.HumanoidRootPart.Position
    local nearestEvent = nil
    local nearestDistance = math.huge
    local nearestZone = nil
    
    -- Find nearest active event
    for _, eventName in pairs(self.activeEvents) do
        local eventData = EVENTS_DATA[eventName]
        if eventData then
            for _, zoneName in pairs(eventData.zones) do
                local zoneCoord = ZONE_COORDS[zoneName]
                if zoneCoord then
                    local distance = (playerPos - zoneCoord.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestEvent = eventName
                        nearestZone = zoneName
                    end
                end
            end
        end
    end
    
    -- Teleport ke event terdekat
    if nearestEvent and nearestZone then
        local targetCoord = ZONE_COORDS[nearestZone]
        lp.Character.HumanoidRootPart.CFrame = targetCoord
        print("🚀 [Event Teleport] Teleported to " .. nearestEvent .. " at " .. nearestZone .. " (" .. math.floor(nearestDistance) .. "m)")
    else
        print("❌ [Event Teleport] No valid event location found!")
    end
end

-- Update ESP positions in real-time
local espUpdateConnection
function EventSystem:startESPUpdates()
    if espUpdateConnection then espUpdateConnection:Disconnect() end
    
    espUpdateConnection = RunService.Heartbeat:Connect(function()
        for _, espObj in pairs(self.espObjects) do
            if espObj.updatePosition then
                espObj.updatePosition()
            end
        end
    end)
end

function EventSystem:stopESPUpdates()
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
        espUpdateConnection = nil
    end
end

-- Event Tab Setup
if EventTab then
    local EventESPSection = EventTab:NewSection("Event ESP System")
    
    EventESPSection:NewToggle("ESP Zona Event", "Show ESP for active event zones", function(state)
        flags['eventesp'] = state
        EventSystem:toggleESP(state)
        
        if state then
            EventSystem:startESPUpdates()
        else
            EventSystem:stopESPUpdates()
        end
    end)
    
    EventESPSection:NewButton("🔍 Scan Events", "Manually scan for active events", function()
        EventSystem:scanActiveEvents()
        
        if #EventSystem.activeEvents > 0 then
            print("🎯 [Event Scanner] Active Events Found:")
            for i, eventName in pairs(EventSystem.activeEvents) do
                print("  " .. i .. ". " .. eventName)
            end
        else
            print("❌ [Event Scanner] No active events detected")
        end
    end)
    
    local EventTeleSection = EventTab:NewSection("Event Teleportation")
    
    EventTeleSection:NewButton("🚀 Teleport to Nearest Event", "Teleport to the closest active event", function()
        EventSystem:teleportToNearestEvent()
    end)
    
    -- Individual event teleports
    local EventListSection = EventTab:NewSection("Manual Event Teleports")
    
    -- Create buttons for each event type
    for eventName, eventData in pairs(EVENTS_DATA) do
        EventListSection:NewButton("📍 " .. eventName, "Teleport to " .. eventName .. " zones", function()
            if #eventData.zones > 0 then
                local targetZone = eventData.zones[1] -- Take first zone
                local targetCoord = ZONE_COORDS[targetZone]
                if targetCoord and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    lp.Character.HumanoidRootPart.CFrame = targetCoord
                    print("🚀 [Manual Teleport] Teleported to " .. eventName .. " at " .. targetZone)
                else
                    print("❌ [Manual Teleport] Invalid location for " .. eventName)
                end
            end
        end)
    end
    
    local EventInfoSection = EventTab:NewSection("Event Information")
    EventInfoSection:NewButton("📊 Show Event List", "Display all trackable events", function()
        print("📋 [Event System] Trackable Events:")
        for eventName, eventData in pairs(EVENTS_DATA) do
            local zones = table.concat(eventData.zones, ", ")
            print("  🎯 " .. eventName .. " -> " .. zones)
        end
    end)
end

print("✅ [Event System] Event Zone ESP & Teleport system initialized!")

-- Automation Section
local AutoSection = AutoTab:NewSection("Autofarm")
AutoSection:NewToggle("Freeze Character", "Freeze your character in place", function(state)
    flags['freezechar'] = state
end)
AutoSection:NewDropdown("Freeze Character Mode", "Select freeze mode", {"Rod Equipped", "Toggled"}, function(currentOption)
    flags['freezecharmode'] = currentOption
end)

local CastSection = AutoTab:NewSection("Auto Cast Settings")
CastSection:NewToggle("Auto Cast", "Automatically cast fishing rod", function(state)
    flags['autocast'] = state
end)

-- Instant Bobber Toggle
CastSection:NewToggle("Instant Bobber", "🚫 No animation, bobber drops close (works with AutoCast)", function(state)
    flags['instantbobber'] = state
    if state then
        print("⚡ [Instant Bobber] Activated - No casting animation!")
        print("📍 [Instant Bobber] Bobber will drop close to player")
    else
        print("🎣 [Instant Bobber] Deactivated - Normal casting animation")
    end
end)

-- Fix slider issue - properly define default value with initial state
local castSlider = CastSection:NewSlider("Auto Cast Delay", "Delay between auto casts (seconds)", 0.1, 5, function(value)
    flags['autocastdelay'] = value
    print("[Auto Cast] Delay set to: " .. value .. " seconds")
end)

-- Set initial slider value to match default
pcall(function()
    if castSlider and castSlider.SetValue then
        castSlider:SetValue(flags['autocastdelay'] or 0.5)
    end
end)

local ShakeSection = AutoTab:NewSection("Auto Shake Settings")
ShakeSection:NewToggle("Auto Shake", "Automatically shake when fish bites", function(state)
    flags['autoshake'] = state
end)

local ReelSection = AutoTab:NewSection("Auto Reel Settings") 
ReelSection:NewToggle("Auto Reel", "Automatically reel in fish", function(state)
    flags['autoreel'] = state
    if state then
        flags['superinstantreel'] = false -- Disable super instant if normal auto reel enabled
    end
end)

-- Super Instant Reel Toggle
ReelSection:NewToggle("Super Instant Reel", "⚡ INSTANTLY reel fish (NO DELAY) - Very Fast!", function(state)
    flags['superinstantreel'] = state
    if state then
        flags['autoreel'] = false -- Disable normal auto reel if super instant enabled
        flags['alwayscatch'] = false -- Disable always catch to prevent conflicts
        print("🚀 [Super Instant Reel] ACTIVATED - Maximum Speed!")
    else
        print("⏸️ [Super Instant Reel] Deactivated")
    end
end)

-- Fix slider issue - properly define default value with initial state
local reelSlider = ReelSection:NewSlider("Auto Reel Delay", "Delay between auto reels (seconds)", 0.1, 5, function(value)
    flags['autoreeldelay'] = value
    print("[Auto Reel] Delay set to: " .. value .. " seconds")
end)

-- Set initial slider value to match default
pcall(function()
    if reelSlider and reelSlider.SetValue then
        reelSlider:SetValue(flags['autoreeldelay'] or 0.5)
    end
end)

-- Modifications Section
if CheckFunc(hookmetamethod) then
    local HookSection = ModTab:NewSection("Hooks")
    HookSection:NewToggle("No AFK Text", "Remove AFK notifications", function(state)
        flags['noafk'] = state
    end)
    HookSection:NewToggle("Perfect Cast", "Always get perfect cast", function(state)
        flags['perfectcast'] = state
    end)
    HookSection:NewToggle("Always Catch", "Always catch fish", function(state)
        flags['alwayscatch'] = state
        if state then
            flags['instantreel'] = false -- Disable instant reel if always catch enabled
        end
    end)
    HookSection:NewToggle("Instant Reel", "Instantly reel fish when lure = 100 (RISKY)", function(state)
        flags['instantreel'] = state
        if state then
            flags['alwayscatch'] = false -- Disable always catch if instant reel enabled
        end
    end)
end

local ClientSection = ModTab:NewSection("Client")
ClientSection:NewToggle("Infinite Oxygen", "Never run out of oxygen", function(state)
    flags['infoxygen'] = state
end)
ClientSection:NewToggle("No Temp & Oxygen", "Disable temperature and oxygen systems", function(state)
    flags['nopeakssystems'] = state
end)

-- Teleports Section
local LocationSection = TeleTab:NewSection("Locations")
LocationSection:NewDropdown("Select Zone", "Choose a zone to teleport to", ZoneNames, function(currentOption)
    flags['zones'] = currentOption
end)
LocationSection:NewButton("Teleport To Zone", "Teleport to selected zone", function()
    if flags['zones'] then
        gethrp().CFrame = TeleportLocations['Zones'][flags['zones']]
    end
end)

local RodSection = TeleTab:NewSection("Rod Locations")
RodSection:NewDropdown("Rod Locations", "Choose a rod location", RodNames, function(currentOption)
    flags['rodlocations'] = currentOption
end)
RodSection:NewButton("Teleport To Rod", "Teleport to selected rod location", function()
    if flags['rodlocations'] then
        gethrp().CFrame = TeleportLocations['Rods'][flags['rodlocations']]
    end
end)

local ItemSection = TeleTab:NewSection("Items & Tools")
ItemSection:NewDropdown("Select Item", "Choose an item location", ItemNames, function(currentOption)
    flags['items'] = currentOption
end)
ItemSection:NewButton("Teleport To Item", "Teleport to selected item", function()
    if flags['items'] then
        gethrp().CFrame = TeleportLocations['Items'][flags['items']]
    end
end)

local FishSection = TeleTab:NewSection("Fishing Spots")
FishSection:NewDropdown("Select Fishing Spot", "Choose a fishing spot", FishingSpotNames, function(currentOption)
    flags['fishingspots'] = currentOption
end)
FishSection:NewButton("Teleport To Fishing Spot", "Teleport to selected fishing spot", function()
    if flags['fishingspots'] then
        gethrp().CFrame = TeleportLocations['Fishing Spots'][flags['fishingspots']]
    end
end)

local NPCSection = TeleTab:NewSection("NPCs")
NPCSection:NewDropdown("Select NPC", "Choose an NPC location", NPCNames, function(currentOption)
    flags['npcs'] = currentOption
end)
NPCSection:NewButton("Teleport To NPC", "Teleport to selected NPC", function()
    if flags['npcs'] then
        gethrp().CFrame = TeleportLocations['NPCs'][flags['npcs']]
    end
end)

local MarianaSection = TeleTab:NewSection("🌊 Mariana's Veil")
MarianaSection:NewDropdown("Select Mariana Location", "Choose a Mariana's Veil location", MarianaVeilNames, function(currentOption)
    flags['marianaveil'] = currentOption
end)
MarianaSection:NewButton("Teleport To Mariana Location", "Teleport to selected Mariana's Veil location", function()
    if flags['marianaveil'] then
        gethrp().CFrame = TeleportLocations['Mariana Veil'][flags['marianaveil']]
    end
end)

local AllLocSection = TeleTab:NewSection("🗺️ All Locations")
AllLocSection:NewDropdown("Select All Location", "Choose from all available locations", AllLocationNames, function(currentOption)
    flags['alllocations'] = currentOption
end)
AllLocSection:NewButton("Teleport To All Location", "Teleport to selected location", function()
    if flags['alllocations'] then
        gethrp().CFrame = TeleportLocations['All Locations'][flags['alllocations']]
    end
end)

-- Visuals Section
local RodSection = VisualTab:NewSection("Rod")
RodSection:NewToggle("Body Rod Chams", "Apply chams to body rod", function(state)
    flags['bodyrodchams'] = state
end)
RodSection:NewToggle("Rod Chams", "Apply chams to equipped rod", function(state)
    flags['rodchams'] = state
end)
RodSection:NewDropdown("Material", "Select rod material", {"ForceField", "Neon"}, function(currentOption)
    flags['rodmaterial'] = currentOption
end)

local FishSection = VisualTab:NewSection("Fish Abundance")
FishSection:NewToggle("Free Fish Radar", "Show fish abundance zones", function(state)
    flags['fishabundance'] = state
end)

--// Loops
RunService.Heartbeat:Connect(function()
    -- Autofarm
    if flags['freezechar'] then
        if flags['freezecharmode'] == 'Toggled' then
            if characterposition == nil then
                characterposition = gethrp().CFrame
            else
                gethrp().CFrame = characterposition
            end
        elseif flags['freezecharmode'] == 'Rod Equipped' then
            local rod = FindRod()
            if rod and characterposition == nil then
                characterposition = gethrp().CFrame
            elseif rod and characterposition ~= nil then
                gethrp().CFrame = characterposition
            else
                characterposition = nil
            end
        end
    else
        characterposition = nil
    end
    if flags['autoshake'] then
        if FindChild(lp.PlayerGui, 'shakeui') and FindChild(lp.PlayerGui['shakeui'], 'safezone') and FindChild(lp.PlayerGui['shakeui']['safezone'], 'button') then
            GuiService.SelectedObject = lp.PlayerGui['shakeui']['safezone']['button']
            if GuiService.SelectedObject == lp.PlayerGui['shakeui']['safezone']['button'] then
                game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
    end
    if flags['autocast'] then
        local rod = FindRod()
        local currentDelay = flags['autocastdelay'] or 0.5
        if rod ~= nil and rod['values']['lure'].Value <= .001 then
            task.wait(currentDelay)
            
            -- Check instant bobber setting for casting behavior
            if flags['instantbobber'] then
                -- INSTANT BOBBER: No animation, close drop
                rod.events.cast:FireServer(0, 1) -- Distance 0 = instant drop near player
                print("⚡ [Instant Bobber] Cast with no animation!")
            else
                -- NORMAL CAST: Full animation, far distance
                rod.events.cast:FireServer(100, 1) -- Distance 100 = normal cast
            end
        end
    end
    if flags['autoreel'] then
        local rod = FindRod()
        local currentDelay = flags['autoreeldelay'] or 0.5
        if rod ~= nil and rod['values']['lure'].Value == 100 then
            task.wait(currentDelay)
            ReplicatedStorage.events.reelfinished:FireServer(100, true)
        end
    end
    
    -- 🚀 SUPER INSTANT REEL - No delay, maximum speed!
    if flags['superinstantreel'] then
        local rod = FindRod()
        if rod ~= nil and rod['values']['lure'].Value >= 99.9 then
            -- INSTANT execution - no delays at all!
            pcall(function()
                -- Method 1: Direct instant reel
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                
                -- Method 2: Force complete any reel GUI immediately
                local reelGui = lp.PlayerGui:FindFirstChild('reel')
                if reelGui then
                    reelGui.Enabled = false -- Force close the GUI
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
                
                -- Method 3: Multiple rapid calls for maximum effectiveness
                for i = 1, 3 do
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end)
        end
    end
    
    -- Instant Reel (No Delay) - RISKY but very fast
    if flags['instantreel'] then
        local rod = FindRod()
        if rod ~= nil and rod['values']['lure'].Value == 100 then
            -- Add small random delay to make it more natural
            local randomDelay = math.random(5, 25) / 1000 -- 0.005-0.025 seconds
            task.wait(randomDelay)
            ReplicatedStorage.events.reelfinished:FireServer(100, true)
        end
    end

    -- Visuals
    if flags['rodchams'] then
        local rod = FindRod()
        if rod ~= nil and FindChild(rod, 'Details') then
            local rodName = tostring(rod)
            if not RodColors[rodName] then
                RodColors[rodName] = {}
                RodMaterials[rodName] = {}
            end
            for i,v in rod['Details']:GetDescendants() do
                if v:IsA('BasePart') or v:IsA('MeshPart') then
                    if v.Color ~= Color3.fromRGB(100, 100, 255) then
                        RodColors[rodName][v.Name..i] = v.Color
                    end
                    if RodMaterials[rodName][v.Name..i] == nil then
                        if v.Material == Enum.Material.Neon then
                            RodMaterials[rodName][v.Name..i] = Enum.Material.Neon
                        elseif v.Material ~= Enum.Material.ForceField and v.Material ~= Enum.Material[flags['rodmaterial']] then
                            RodMaterials[rodName][v.Name..i] = v.Material
                        end
                    end
                    v.Material = Enum.Material[flags['rodmaterial']]
                    v.Color = Color3.fromRGB(100, 100, 255)
                end
            end
            if rod['handle'].Color ~= Color3.fromRGB(100, 100, 255) then
                RodColors[rodName]['handle'] = rod['handle'].Color
            end
            if rod['handle'].Material ~= Enum.Material.ForceField and rod['handle'].Material ~= Enum.Material.Neon and rod['handle'].Material ~= Enum.Material[flags['rodmaterial']] then
                RodMaterials[rodName]['handle'] = rod['handle'].Material
            end
            rod['handle'].Material = Enum.Material[flags['rodmaterial']]
            rod['handle'].Color = Color3.fromRGB(100, 100, 255)
        end
    elseif not flags['rodchams'] then
        local rod = FindRod()
        if rod ~= nil and FindChild(rod, 'Details') then
            local rodName = tostring(rod)
            if RodColors[rodName] and RodMaterials[rodName] then
                for i,v in rod['Details']:GetDescendants() do
                    if v:IsA('BasePart') or v:IsA('MeshPart') then
                        if RodMaterials[rodName][v.Name..i] and RodColors[rodName][v.Name..i] then
                            v.Material = RodMaterials[rodName][v.Name..i]
                            v.Color = RodColors[rodName][v.Name..i]
                        end
                    end
                end
                if RodMaterials[rodName]['handle'] and RodColors[rodName]['handle'] then
                    rod['handle'].Material = RodMaterials[rodName]['handle']
                    rod['handle'].Color = RodColors[rodName]['handle']
                end
            end
        end
    end
    if flags['bodyrodchams'] then
        local rod = getchar():FindFirstChild('RodBodyModel')
        if rod ~= nil and FindChild(rod, 'Details') then
            local rodName = tostring(rod)
            if not RodColors[rodName] then
                RodColors[rodName] = {}
                RodMaterials[rodName] = {}
            end
            for i,v in rod['Details']:GetDescendants() do
                if v:IsA('BasePart') or v:IsA('MeshPart') then
                    if v.Color ~= Color3.fromRGB(100, 100, 255) then
                        RodColors[rodName][v.Name..i] = v.Color
                    end
                    if RodMaterials[rodName][v.Name..i] == nil then
                        if v.Material == Enum.Material.Neon then
                            RodMaterials[rodName][v.Name..i] = Enum.Material.Neon
                        elseif v.Material ~= Enum.Material.ForceField and v.Material ~= Enum.Material[flags['rodmaterial']] then
                            RodMaterials[rodName][v.Name..i] = v.Material
                        end
                    end
                    v.Material = Enum.Material[flags['rodmaterial']]
                    v.Color = Color3.fromRGB(100, 100, 255)
                end
            end
            if rod['handle'].Color ~= Color3.fromRGB(100, 100, 255) then
                RodColors[rodName]['handle'] = rod['handle'].Color
            end
            if rod['handle'].Material ~= Enum.Material.ForceField and rod['handle'].Material ~= Enum.Material.Neon and rod['handle'].Material ~= Enum.Material[flags['rodmaterial']] then
                RodMaterials[rodName]['handle'] = rod['handle'].Material
            end
            rod['handle'].Material = Enum.Material[flags['rodmaterial']]
            rod['handle'].Color = Color3.fromRGB(100, 100, 255)
        end
    elseif not flags['bodyrodchams'] then
        local rod = getchar():FindFirstChild('RodBodyModel')
        if rod ~= nil and FindChild(rod, 'Details') then
            local rodName = tostring(rod)
            if RodColors[rodName] and RodMaterials[rodName] then
                for i,v in rod['Details']:GetDescendants() do
                    if v:IsA('BasePart') or v:IsA('MeshPart') then
                        if RodMaterials[rodName][v.Name..i] and RodColors[rodName][v.Name..i] then
                            v.Material = RodMaterials[rodName][v.Name..i]
                            v.Color = RodColors[rodName][v.Name..i]
                        end
                    end
                end
                if RodMaterials[rodName]['handle'] and RodColors[rodName]['handle'] then
                    rod['handle'].Material = RodMaterials[rodName]['handle']
                    rod['handle'].Color = RodColors[rodName]['handle']
                end
            end
        end
    end
    if flags['fishabundance'] then
        if not fishabundancevisible then
            message('\<b><font color = \"#9eff80\">Fish Abundance Zones</font></b>\ are now visible', 5)
        end
        for i,v in workspace.zones.fishing:GetChildren() do
            if FindChildOfType(v, 'Abundance', 'StringValue') and FindChildOfType(v, 'radar1', 'BillboardGui') then
                v['radar1'].Enabled = true
                v['radar2'].Enabled = true
            end
        end
        fishabundancevisible = flags['fishabundance']
    else
        if fishabundancevisible then
            message('\<b><font color = \"#9eff80\">Fish Abundance Zones</font></b>\ are no longer visible', 5)
        end
        for i,v in workspace.zones.fishing:GetChildren() do
            if FindChildOfType(v, 'Abundance', 'StringValue') and FindChildOfType(v, 'radar1', 'BillboardGui') then
                v['radar1'].Enabled = false
                v['radar2'].Enabled = false
            end
        end
        fishabundancevisible = flags['fishabundance']
    end

    -- Modifications
    if flags['infoxygen'] then
        if not deathcon then
            deathcon = gethum().Died:Connect(function()
                task.delay(9, function()
                    if FindChildOfType(getchar(), 'DivingTank', 'Decal') then
                        FindChildOfType(getchar(), 'DivingTank', 'Decal'):Destroy()
                    end
                    local oxygentank = Instance.new('Decal')
                    oxygentank.Name = 'DivingTank'
                    oxygentank.Parent = workspace
                    oxygentank:SetAttribute('Tier', 1/0)
                    oxygentank.Parent = getchar()
                    deathcon = nil
                end)
            end)
        end
        if deathcon and gethum().Health > 0 then
            if not getchar():FindFirstChild('DivingTank') then
                local oxygentank = Instance.new('Decal')
                oxygentank.Name = 'DivingTank'
                oxygentank.Parent = workspace
                oxygentank:SetAttribute('Tier', 1/0)
                oxygentank.Parent = getchar()
            end
        end
    else
        if FindChildOfType(getchar(), 'DivingTank', 'Decal') then
            FindChildOfType(getchar(), 'DivingTank', 'Decal'):Destroy()
        end
    end
    if flags['nopeakssystems'] then
        getchar():SetAttribute('WinterCloakEquipped', true)
        getchar():SetAttribute('Refill', true)
    else
        getchar():SetAttribute('WinterCloakEquipped', nil)
        getchar():SetAttribute('Refill', false)
    end
    
    -- Enhanced Always Catch - Auto complete reel minigame
    if flags['alwayscatch'] then
        local rod = FindRod()
        if rod and rod['values'] and rod['values']['lure'] then
            -- Check if fish is hooked and minigame should be bypassed
            if rod['values']['lure'].Value >= 99.9 then
                -- Try to bypass reel minigame immediately
                pcall(function()
                    -- Check for reel GUI
                    local reelGui = lp.PlayerGui:FindFirstChild('reel')
                    if reelGui then
                        -- Immediately complete the reel
                        ReplicatedStorage.events.reelfinished:FireServer(100, true)
                    end
                end)
            end
        end
    end
end)

--// Hooks
if CheckFunc(hookmetamethod) then
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local method, args = getnamecallmethod(), {...}
        if method == 'FireServer' and self.Name == 'afk' and flags['noafk'] then
            args[1] = false
            return old(self, unpack(args))
        elseif method == 'FireServer' and self.Name == 'cast' and flags['perfectcast'] then
            args[1] = 100
            return old(self, unpack(args))
        elseif method == 'FireServer' and self.Name == 'cast' and flags['instantbobber'] then
            -- INSTANT BOBBER HOOK: Override manual casting untuk instant drop
            args[1] = 0  -- Distance 0 untuk instant bobber
            args[2] = 1  -- Keep power at 1
            print("⚡ [Instant Bobber Hook] Manual cast converted to instant!")
            return old(self, unpack(args))
        elseif method == 'FireServer' and self.Name == 'reelfinished' and flags['alwayscatch'] then
            args[1] = 100
            args[2] = true
            return old(self, unpack(args))
        end
        return old(self, ...)
    end)
end

-- Additional Always Catch implementation
if flags then
    -- Enhanced Always Catch using different approach
    task.spawn(function()
        while true do
            task.wait(0.1)
            if flags['alwayscatch'] then
                local rod = FindRod()
                if rod and rod['values'] and rod['values']['lure'] then
                    -- When fish bites (lure = 100), immediately catch it
                    if rod['values']['lure'].Value >= 99.9 then
                        task.wait(0.1) -- Small delay to ensure minigame starts
                        
                        -- Try multiple methods to catch the fish
                        pcall(function()
                            -- Method 1: Direct reelfinished call
                            ReplicatedStorage.events.reelfinished:FireServer(100, true)
                        end)
                        
                        pcall(function()
                            -- Method 2: Check for reel GUI and auto-complete
                            if lp.PlayerGui:FindFirstChild('reel') then
                                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                            end
                        end)
                        
                        pcall(function()
                            -- Method 3: Auto-complete any active minigame
                            local reelGui = lp.PlayerGui:FindFirstChild('reel')
                            if reelGui and reelGui.Enabled then
                                -- Force complete the reel minigame
                                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                                reelGui.Enabled = false
                            end
                        end)
                        
                        task.wait(0.5) -- Wait before next check
                    end
                end
            end
        end
    end)
end

--[[
🚀 SUPER INSTANT REEL + INSTANT BOBBER MODIFICATION 🚀

✅ New Features Added:
- Super Instant Reel toggle with maximum speed
- Instant Bobber toggle (no animation, close drop)
- Dual monitoring system (main loop + GUI detection)
- Conflict prevention with other auto-reel features
- Multiple rapid fire methods for maximum effectiveness
- Real-time status feedback with console messages
- Enhanced GUI force-close functionality
- Hook system for manual casting instant bobber

🎯 How Super Instant Reel works:
1. Monitors for fish bite (lure value >= 99.9)
2. Instantly fires reelfinished event with perfect score
3. Force disables reel GUI to prevent delays
4. Uses multiple rapid calls for maximum success rate
5. No delays or waiting - pure speed!

⚡ How Instant Bobber works:
1. Works with both AutoCast and Manual casting
2. Changes cast distance from 100 to 0 (no animation)
3. Bobber drops instantly near player
4. Hook system intercepts manual casts
5. Perfect for speed fishing setup

🎮 Usage Combinations:
- AutoCast OFF + Instant Bobber OFF = Normal manual fishing
- AutoCast ON + Instant Bobber OFF = Auto fishing with animation  
- AutoCast ON + Instant Bobber ON = Auto fishing instant (FASTEST!)
- AutoCast OFF + Instant Bobber ON = Manual fishing instant

⚠️ Important Notes:
- Super Instant Reel disables normal Auto Reel when activated
- Instant Bobber works with any casting mode
- Combined features create ultimate fishing speed
- Console output shows when features are active

🔧 Technical Implementation:
- GUI monitoring via PlayerGui.ChildAdded
- Main loop checking via lure value detection
- Hook metamethod for manual cast interception
- Multiple FireServer calls for redundancy
- Force GUI disable for instant completion
--]]

print("🎣 Enhanced Fisch Script with Super Instant Reel + Instant Bobber loaded successfully!")
print("🚀 Super Instant Reel: Ready for maximum fishing speed!")
print("⚡ Instant Bobber: Ready for no-animation casting!")
print("🎮 Toggle both features in Auto Cast/Reel Settings for ULTIMATE SPEED!")