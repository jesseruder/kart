
function loadSnowLevel()
    PATH_POINTS = SNOW_PATH_POINTS

    heightAtPoint = function(x, y)
        return _heightAtPoint(x, y)
    end

    FontColor = {0.3, 0.3, 0.3, 1}
    WorldSize = 60
    RoadScale = 45
    RoadRadius = 1.1
    MaxClosestRoadDistance = RoadRadius + 2

    makeHeightMap()
    addMountainRelative(0.5,0.5,8,0.2)
    addMountainRelative(0.63,0.5,2.5,0.1)
    addMountainRelative(0.55,0.57,2.5,0.1)

    addMountainRelative(0.85,0.52,7,0.2)
    addMountainRelative(0.5,0.9,6,0.2)
    addMountainRelative(0.2,0.5,8,0.2)

    math.randomseed(124125215)
    local numRows = 2 * WorldSize / GridSize
    for i = 0, 20 do
        addMountain(math.floor(math.random() * numRows), math.floor(math.random() * numRows), math.floor(math.random() * 4), math.random() * 0.05 + 0.02)
    end
    math.randomseed(os.time())

    updatePathPoints()
    --makeEmptyJump(320, 60, 7, 30, -7, true)
    makeTabletopJump(340, 40, 2.5, 30)
    for i = 380, 420 do
        PATH_POINTS[i][6] = true
    end
    makeRoad(snowRoadImage, snowTerrainImage, 0.2)

    if CASTLE_SERVER then
        return
    end

    skybox(grassSkyboxImage, nil, nil, 1.0)
    terrain(snowTerrainImage)
    clearItems()
    makeItems(40)
    makeItems(100)
    makeItems(160)
    makeItems(230)
    makeItems(350)
    makeItems(425)

    FogColor = {1,1,1,1}
    FogStartDist = 0
    FogDivide = 10
    GRAVITY = 4
    Engine.camera.pos.y = 5
    PREFER_GROUND_HEIGHT = false
    PARTICLES_ENABLED = true
end

-- generate with createpath.html
-- format is x,y,angle
-- [37,243.5625,313,20.5625,564,257.5625,319,528.5625,139,248.5625,306,116.5625,493,256.5625,332,376.5625,252,260.5625,325,227.5625,377,264.5625,341,340.5625,87,472.5625]
SNOW_PATH_POINTS = {{0.06560283687943262, 0.46080170273146503, -1.1071487177940904},
{0.07285627525302492, 0.4454569709966853, -1.0962915557665873},
{0.0801411987875246, 0.43032388961947454, -1.0884013038500164},
{0.0874621034248366, 0.41540684971616687, -1.079968627082537},
{0.0948234851068658, 0.4007102424030968, -1.0709750015175254},
{0.10222983977551718, 0.3862384587965986, -1.0614012432400872},
{0.10968566337269564, 0.37199589001300626, -1.0512275455725062},
{0.11719545184030607, 0.35798692716865466, -1.040433530304905},
{0.12476370112025344, 0.3442159613798777, -1.0289983153360747},
{0.1323949071544427, 0.33068738376301005, -1.0169006013600637},
{0.14009356588477867, 0.3174055854343857, -1.0041187804735476},
{0.14786417325316636, 0.30437495751033894, -0.9906310697917875},
{0.15571122520151062, 0.29159989110720436, -0.9764156733267129},
{0.16363921767171646, 0.27908477734131604, -0.9614509754732898},
{0.17165264660568877, 0.26683400732900847, -0.9457157694372977},
{0.17975600794533247, 0.2548519721866158, -0.9291895237797894},
{0.1879537976325525, 0.24314306303047262, -0.9118526899050208},
{0.19625051160925375, 0.23171167097691298, -0.8936870527279837},
{0.20465064581734113, 0.2205621871422713, -0.8746761258697591},
{0.21315869619871966, 0.20969900264288188, -0.8548055914883865},
{0.22177915869529416, 0.199126508595079, -0.8340637832097437},
{0.23051652924896956, 0.18884909611519707, -0.8124422085396588},
{0.23937530380165087, 0.17887115631957035, -0.7899361046002102},
{0.24835997829524295, 0.16919708032453312, -0.7665450180591926},
{0.2574750486716507, 0.15983125924641972, -0.7422733967785011},
{0.2667250108727791, 0.15077808420156455, -0.717131177121304},
{0.276114360840533, 0.14204194630630182, -0.6911343472262379},
{0.2856475945168174, 0.13362723667696588, -0.6643054631519991},
{0.2953292078435372, 0.12553834642989106, -0.6366740919614196},
{0.30516369676259736, 0.11777966668141164, -0.6082771539493068},
{0.3151555572159027, 0.11035558854786198, -0.579159135745007},
{0.32530928514535823, 0.10327050314557638, -0.549372147336439},
{0.33562937649286884, 0.09652880159088915, -0.5189757994796262},
{0.3461203272003395, 0.09013487500013463, -0.48803688363589703},
{0.356786633209675, 0.0840931144896471, -0.4566288444608704},
{0.3676327904627804, 0.0784079111757609, -0.4248310446359749},
{0.37866329490156064, 0.07308365617481034, -0.39272783288989466},
{0.38988264246792054, 0.06812474060312974, -0.36040743756381666},
{0.4012953291037651, 0.06353555557705344, -0.32796071902200596},
{0.41290585075099917, 0.05932049221291571, -0.2954798235397391},
{0.42471870335152767, 0.05548394162705088, -0.2630567880485293},
{0.43673838284725564, 0.052030294935793295, -0.23078214855389523},
{0.4489693851800879, 0.04896394325547724, -0.1987436047824993},
{0.4614162062919294, 0.04628927770243704, -0.16702478969221213},
{0.47408334212468517, 0.04401068939300702, -0.13570418532477269},
{0.48697528862025996, 0.04213256944352149, -0.10485421686636776},
{0.5000965417205587, 0.04065930897031477, -0.07454054569359703},
{0.5134515973674865, 0.039595299089721175, -0.0448215706806554},
{0.5270449515029481, 0.038944930918075014, -0.01574813611976822},
{0.5408811000688484, 0.03871259557171061, 0.01263656492912979},
{0.5549645390070922, 0.03890268416696228, 0.026559218245749028},
{0.5687643500671331, 0.03953533840103037, 0.07545769019473303},
{0.5825110021547897, 0.04064395704219148, 0.10754341230390985},
{0.5961953199970595, 0.04222005523544931, 0.13921896946285095},
{0.6098081283209411, 0.04425514812580761, 0.1704888312712567},
{0.623340251853432, 0.04674075085827009, 0.20136080957939018},
{0.6367825153215304, 0.04966837857784048, 0.2318457850048048},
{0.6501257434522345, 0.053029546429522526, 0.2619574346312574},
{0.6633607609725423, 0.05681576955831993, 0.29171196634255825},
{0.6764783926094523, 0.061018563109236465, 0.32112786407751326},
{0.6894694630899619, 0.06562944222727579, 0.3502256471970764},
{0.7023247971410694, 0.0706399220574417, 0.3790276461595732},
{0.7150352194897729, 0.07604151774473789, 0.4075577958199288},
{0.7275915548630705, 0.08182574443416808, 0.4358414469096008},
{0.73998462798796, 0.08798411727073603, 0.4639051956127833},
{0.7522052635914399, 0.09450815139944548, 0.4917767306233698},
{0.7642442864005081, 0.1013893619653001, 0.5194846966343227},
{0.7760925211421624, 0.10861926411330367, 0.5470585728628019},
{0.7877407925434012, 0.11618937298845991, 0.5745285649361578},
{0.7991799253312226, 0.12409120373577252, 0.601925508241476},
{0.8104007442326241, 0.13231627150024525, 0.6292807806614732},
{0.8213940739746045, 0.14085609142688182, 0.6566262224702988},
{0.8321507392841616, 0.149702178660686, 0.6839940610340787},
{0.8426615648882931, 0.15884604834666147, 0.711416837844684},
{0.8529173755139974, 0.16827921562981193, 0.7389273353052437},
{0.8629089958882729, 0.17799319565514118, 0.7665585005787019},
{0.8726272507381169, 0.18797950356765292, 0.7943433637051281},
{0.8820629647905278, 0.1982296545123509, 0.8223149470911815},
{0.8912069627725037, 0.20873516363423877, 0.8505061633808016},
{0.9000500694110428, 0.21948754607832038, 0.8789496986379446},
{0.9085831094331428, 0.23047831698959936, 0.9076778777218331},
{0.9167969075658025, 0.2416989915130795, 0.9367225087287714},
{0.9246822885360189, 0.2531410847937645, 0.9661147034324848},
{0.9322300770707908, 0.264796111976658, 0.9958846708023005},
{0.9394310978971161, 0.2766555882067639, 1.0260614809449193},
{0.946276175741993, 0.2887110286290858, 1.0566727972347747},
{0.9527561353324191, 0.30095394838862755, 1.0877445750067505},
{0.9588618013953929, 0.3133758626303928, 1.1193007260212053},
{0.9645839986579124, 0.32596828649938525, 1.1513627490108629},
{0.9699135518469756, 0.3387227351406087, 1.183949328012339},
{0.9748412856895804, 0.3516307236990667, 1.2170759018906243},
{0.9793580249127252, 0.36468376731976326, 1.2507542104833664},
{0.9834545942434078, 0.3778733811477019, 1.2849918250979613},
{0.9871218184086262, 0.39119108032788646, 1.3197916736288091},
{0.9903505221353788, 0.40462838000532053, 1.3551515732233694},
{0.9931315301506635, 0.418176795325008, 1.3910637860652748},
{0.9954556671814784, 0.4318278414319526, 1.4275146162632062},
{0.9973137579548212, 0.44557303347115795, 1.4644840677934179},
{0.9986966271976905, 0.45940388658762776, 1.5019455846675647},
{0.999595099637084, 0.47331191592636584, 1.5398658947013422},
{1, 0.48728863663237554, 1.5589858523405815},
{0.9998751122051672, 0.5021385496678187, 1.6205040833908972},
{0.9991814007167454, 0.5170294043398147, 1.659925139295583},
{0.9979325724863296, 0.5319469181078951, 1.698089037439154},
{0.9961423344655155, 0.5468768084315917, 1.7350232964055872},
{0.9938243936058978, 0.5618047927704356, 1.7707655515828669},
{0.9909924568590722, 0.5767165885839586, 1.8053615800770393},
{0.9876602311766335, 0.591597913331692, 1.838863533657751},
{0.9838414235101778, 0.6064344844731675, 1.8713283991364287},
{0.9795497408113002, 0.6212120194679174, 1.90281668939632},
{0.9747988900315956, 0.6359162357754718, 1.9333913568527186},
{0.969602578122659, 0.650532850855363, 1.9631169137199054},
{0.9639745120360865, 0.6650475821671226, 1.992058739280965},
{0.957928398723473, 0.679446147170282, 2.020282552597772},
{0.9514779451364139, 0.6937142633243728, 2.0478540290536955},
{0.9446368582265047, 0.7078376480889266, 2.0748385402083733},
{0.9374188449453401, 0.7218020189234747, 2.1013009982085933},
{0.929837612244516, 0.735593093287549, 2.1273057881059003},
{0.9219068670756275, 0.7491965886406807, 2.1529167736425636},
{0.91364031639027, 0.7625982224424015, 2.1781973642235344},
{0.9050516671400383, 0.7757837121522427, 2.2032106327918655},
{0.8961546262765284, 0.7887387752297363, 2.228019476109022},
{0.8869629007513351, 0.8014491291344136, 2.252686810477459},
{0.8774901975160538, 0.8139004913258059, 2.2772757972152142},
{0.8677502235222799, 0.8260785792634451, 2.301850093193681},
{0.8577566857216089, 0.8379691104068628, 2.3264741224744308},
{0.8475232910656355, 0.8495578022155901, 2.3512133655197123},
{0.8370637465059554, 0.8608303721491588, 2.3761346625872988},
{0.826391758994164, 0.8717725376671005, 2.4013065277258496},
{0.8155210354818561, 0.8823700162289465, 2.4267994692198744},
{0.8044652829206276, 0.8926085252942285, 2.452686311334779},
{0.7932382082620735, 0.9024737823224783, 2.4790425107037866},
{0.781853518457789, 0.9119515047732267, 2.505946458579992},
{0.7703249204593696, 0.9210274101060061, 2.533479757326873},
{0.7586661212184106, 0.9296872157803476, 2.561727455797893},
{0.7468908276865072, 0.9379166392557828, 2.5907782235059287},
{0.7350127468152546, 0.9457013979918433, 2.6207244375521195},
{0.7230455855562483, 0.9530272094480604, 2.6516621490432284},
{0.7110030508610835, 0.9598797910839658, 2.6836908871168506},
{0.6988988496813555, 0.9662448603590912, 2.7169132487903624},
{0.6867466889686595, 0.9721081347329679, 2.7514342119630646},
{0.6745602756745912, 0.9774553316651277, 2.7873600977183712},
{0.6623533167507454, 0.9822721686151016, 2.8247970978420898},
{0.6501395191487175, 0.9865443630424217, 2.8638492762252077},
{0.6379325898201031, 0.9902576324066192, 2.9046159516000722},
{0.6257462357164972, 0.9933976941672262, 2.9471883780958534},
{0.6135941637894953, 0.9959502657837735, 2.9916456647914043},
{0.6014900809906925, 0.9979010647157931, 3.0380499219701824},
{0.5894476942716841, 0.9992358084228162, 3.0864406960839728},
{0.5774807105840656, 0.9999402143643746, 3.1368288613159723},
{0.5656028368794326, 1, 3.162765959550137},
{0.5548823922204442, 0.9994184537173197, 3.251408493139219},
{0.5442788312321752, 0.998171575870404, 3.309568618087024},
{0.5337959136493272, 0.9962754057348813, 3.3666178736132215},
{0.5234373992066014, 0.9937459825863786, 3.4222899765832215},
{0.5132070476386994, 0.9905993457005241, 3.4763650003960427},
{0.5031086186803222, 0.986851534352945, 3.528671738512047},
{0.4931458720661719, 0.9825185878192697, 3.579087114425203},
{0.4833225675309493, 0.9776165453751254, 3.6275332264807982},
{0.47364246480935646, 0.9721614462961409, 3.6739727291658095},
{0.46410932363609436, 0.9661693298579427, 3.718403244879233},
{0.45472690374586416, 0.9596562353361588, 3.7608514087580986},
{0.4454989648733679, 0.9526382020064174, 3.8013670144018423},
{0.4364292667533066, 0.945131269144346, 3.8400175841687365},
{0.427521569120382, 0.9371514760255726, 3.8768835569334903},
{0.41877963170929516, 0.9287148619257246, 3.912054180616575},
{0.4102072142547478, 0.91983746612043, 3.9456241197071518},
{0.4018080764914411, 0.9105353278853163, 3.9776907372771544},
{0.39358597815407675, 0.9008244864960117, 4.0083519818335125},
{0.385544678977356, 0.8907209812281436, 4.037704796266059},
{0.37768793869598016, 0.8802408513573396, 4.065843964024939},
{0.37001951704465097, 0.8694001361592281, 4.092861312343539},
{0.3625431737580697, 0.8582148749094363, 4.1188452007048815},
{0.3552626685709377, 0.8467011068835918, 4.143880232681827},
{0.3481817612179564, 0.8348748713573229, 4.168047139385806},
{0.34130421143382744, 0.8227522076062571, 4.191422792229629},
{0.3346337789532519, 0.8103491549060221, 4.214080311138488},
{0.32817422351093145, 0.7976817525322456, 4.236089241579394},
{0.32192930484156745, 0.7847660397605555, 4.257515779829744},
{0.3159027826798613, 0.7716180558665794, 4.278423030862828},
{0.3100984167605144, 0.7582538401259453, 4.298871287224653},
{0.3045199668182283, 0.7446894318142807, 4.318918320456504},
{0.29917119258770425, 0.7309408702072134, 4.338619679120173},
{0.2940558538036438, 0.7170241945803714, 4.358028989433473},
{0.2891777102007483, 0.702955444209382, 4.377198256031071},
{0.2845405215137193, 0.6887506583698734, 4.396178161520817},
{0.280148047477258, 0.6744258763374733, 4.415018364382968},
{0.276004047826066, 0.6599971373878091, 4.433767795418158},
{0.2721122822948447, 0.6454804807965089, 4.452474953435602},
{0.2684765106182955, 0.6308919458392002, 4.471188201220271},
{0.26510049253111984, 0.6162475717915109, 4.4899560630507604},
{0.2619879877680191, 0.6015633979290688, 4.508827525173514},
{0.2591427560636947, 0.5868554635275016, 4.527852340680409},
{0.2565685571528481, 0.5721398078624369, 4.547081340183773},
{0.25426915077018075, 0.5574324702095027, 4.566566749525234},
{0.25224829665039405, 0.5427494898443267, 4.586362515472373},
{0.2505097545281894, 0.5281069060425365, 4.606524639919151},
{0.24905728413826822, 0.51352075807976, 4.627111522468694},
{0.24789464521533192, 0.49900708523162485, 4.648184310381004},
{0.24702559749408204, 0.4845819267737589, 4.669807253635733},
{0.24645390070921985, 0.4702613219817902, 4.6808460477744935},
{0.2464648309437787, 0.45671787447660717, -1.5153592307195454},
{0.24728985124719058, 0.44345698082709034, -1.4496746267417797},
{0.2489035602143548, 0.4304874266938215, -1.3840399812299777},
{0.25128055644017, 0.41781799773738243, -1.3188346543169134},
{0.2543954385195353, 0.4054574796183549, -1.254410158110237},
{0.25822280504734973, 0.39341465799732117, -1.1910774784444493},
{0.26273725461851216, 0.3816983185348628, -1.1290979734534003},
{0.2679133858279215, 0.3703172468915616, -1.0686782527938572},
{0.2737257972704769, 0.35928022872799964, -1.0099688919503138},
{0.28014908754107726, 0.34859604970475877, -0.9530664127476376},
{0.28715785523462156, 0.33827349548242075, -0.8980177166259082},
{0.2947266989460087, 0.3283213517215675, -0.8448260894803115},
{0.30283021727013787, 0.318748404082781, -0.7934579664163337},
{0.31144300880190773, 0.3095634382266429, -0.7438497969652742},
{0.32053967213621753, 0.3007752398137353, -0.6959145347904379},
{0.330094805867966, 0.2923925945046398, -0.6495474528145735},
{0.3400830085920523, 0.2844242879599385, -0.6046311330920107},
{0.3504788789033753, 0.2768791058402132, -0.5610395922411824},
{0.36125701539683414, 0.2697658338060457, -0.5186415786230021},
{0.3723920166673275, 0.263093257518018, -0.47730312239501993},
{0.38385848130975464, 0.25687016263671175, -0.43688944151209697},
{0.39563100791901434, 0.25110533482270914, -0.39726631286562974},
{0.40768419509000575, 0.24580755973659174, -0.3583010140490315},
{0.41999264141762765, 0.24098562303894155, -0.3198629322314137},
{0.4325309454967791, 0.23664831039034043, -0.2818239254615851},
{0.4452737059223592, 0.23280440745137032, -0.24405851043333526},
{0.4581955212892666, 0.22946269988261286, -0.20644394050251536},
{0.4668969959308556, 0.22751823086248885, -0.18139199682773444},
{0.4756592346907374, 0.22580346768140894, -0.15631884374657434},
{0.48447471122666, 0.224321013498064, -0.13119016732238076},
{0.49333589919637144, 0.22307347147114512, -0.10597221802488765},
{0.5022352722576191, 0.22206344475934303, -0.08063182974095162},
{0.5111653040681513, 0.22129353652134878, -0.05513644891464686},
{0.5201184682857155, 0.22076634991585328, -0.02945417595047828},
{0.5290872385680597, 0.22048448810154742, -0.003553820964458776},
{0.5425531914893617, 0.22052737377320564, 0.02259502408669878},
{0.5523931106174014, 0.22091360612137892, 0.06485212974371479},
{0.562204460872936, 0.22159328273531786, 0.09248271482685033},
{0.5719808423169911, 0.22256059180359597, 0.11969596866367271},
{0.5817158550105928, 0.22380972151478642, 0.1465076616218015},
{0.5914030990147663, 0.2253348600574627, 0.1729356612741424},
{0.6010361743905376, 0.22713019562019796, 0.19899972733091653},
{0.6106086811989326, 0.22918991639156566, 0.22472132552608204},
{0.6201142195009768, 0.2315082105601391, 0.2501234616293857},
{0.6295463893576965, 0.23407926631449175, 0.2752305361615499},
{0.6388987908301168, 0.2368972718431967, 0.30006821990617505},
{0.6481650239792637, 0.23995641533482742, 0.3246633499282683},
{0.6573386888661629, 0.24325088497795727, 0.3490438455136853},
{0.6664133855518402, 0.24677486896115955, 0.37323864322259115},
{0.6753827140973215, 0.25052255547300767, 0.39727765008925786},
{0.6842402745636323, 0.2544881327020749, 0.4211917138861101},
{0.6929796670117988, 0.2586657888369346, 0.4450126092883404},
{0.7015944915028461, 0.26304971206616, 0.4687730387137181},
{0.7100783480978007, 0.2676340905783247, 0.4925066465580048},
{0.7184248368576878, 0.2724131125620018, 0.516248045487804},
{0.7266275578435332, 0.2773809662057647, 0.540032853378047},
{0.7346801111163628, 0.2825318396981867, 0.5638977393790601},
{0.7425760967372024, 0.2878599212278413, 0.58788047745635},
{0.7503091147670777, 0.2933593989833017, 0.6120200055524199},
{0.7578727652670144, 0.29902446115314124, 0.6363564882608046},
{0.7652606482980383, 0.3048492959259333, 0.6609313805637285},
{0.772466363921175, 0.31082809149025115, 0.6857874897509217},
{0.7794835121974505, 0.3169550360346682, 0.7109690320916026},
{0.7863056931878905, 0.3232243177477578, 0.7365216801572619},
{0.7929265069535206, 0.3296301248180932, 0.7624925958723638},
{0.7993395535553668, 0.3361666454342478, 0.7889304433874417},
{0.8085555601595348, 0.3462038009193949, 0.8295728147200198},
{0.8172680909884585, 0.3565023704433602, 0.8715541904991772},
{0.8254555462480999, 0.3670427391425787, 0.9150561808210407},
{0.8330963261444212, 0.37780529215348546, 0.9602651974737506},
{0.8401688308833838, 0.38877041461251544, 1.0073698916980747},
{0.8466514606709501, 0.39991849165610377, 1.0565573171063587},
{0.8525226157130816, 0.4112299084206852, 1.108007498724331},
{0.8577606962157406, 0.42268505004269513, 1.1618860968255293},
{0.8623441023848887, 0.43426430165856833, 1.2183349228346634},
{0.8662512344264881, 0.4459480484047398, 1.2774602279968534},
{0.8694604925465004, 0.4577166754176446, 1.339318978696407},
{0.871950276950888, 0.46955056783371785, 1.4039037776146908},
{0.874113475177305, 0.4853967127823105, 1.471127674303735},
{0.8745892043185551, 0.49561898680396643, 1.603564887583076},
{0.8741229889634514, 0.5058101456162376, 1.698806781889143},
{0.8727514798427665, 0.5159529651323809, 1.7892730331603899},
{0.8705113276872717, 0.5260302212656531, 1.8742561236571254},
{0.8674391832277389, 0.5360246899293111, 1.9534286316892469},
{0.8635716971949406, 0.545919147036612, 2.02677465237545},
{0.8589455203196484, 0.5556963685008122, 2.0945061301041967},
{0.8535973033326341, 0.5653391302351687, 2.156983466402612},
{0.8475636969646697, 0.5748302081529387, 2.2146504519588834},
{0.8408813519465275, 0.5841523781673789, 2.2679862847471455},
{0.833586919008979, 0.5932884161917462, 2.3174732233038426},
{0.8257170488827964, 0.602221098139297, 2.3635767072502314},
{0.8173083922987515, 0.610933199923289, 2.4067345654036965},
{0.8083975999876162, 0.6194074974569784, 2.44735241522621},
{0.7990213226801627, 0.6276267666536226, 2.4858030416210957},
{0.7892162111071627, 0.6355737834264781, 2.522428187582894},
{0.779018915999388, 0.6432313236888018, 2.557541707349409},
{0.7684660880876107, 0.6505821633538506, 2.591433414663079},
{0.757594378102603, 0.6576090783348815, 2.6243732251512064},
{0.7464404367751365, 0.6642948445451512, 2.6566153705170983},
{0.7350409148359833, 0.6706222378979166, 2.6884025784776058},
{0.7234324630159154, 0.6765740343064348, 2.7199701859269805},
{0.7116517320457043, 0.6821330096839624, 2.7515501977729357},
{0.6997353726561224, 0.6872819399437563, 2.7833753296574506},
{0.6877200355779414, 0.6920036009990735, 2.815683084942749},
{0.6756423715419335, 0.6962807687631709, 2.84871991743589},
{0.6635390312788703, 0.7000962191493051, 2.882745521112686},
{0.651446665519524, 0.7034327280707331, 2.918037263499353},
{0.6394019249946663, 0.7062730714407119, 2.954894733899095},
{0.6274414604350694, 0.7086000251724984, 2.9936443004452715},
{0.615601922571505, 0.7103963651793492, 3.0346434444098085},
{0.6039199621347453, 0.7116448673745215, 3.0782844425377203},
{0.5886524822695035, 0.7124275747901146, 3.1249966670438845},
{0.5782644723152103, 0.7119888792369062, 3.2663777612378455},
{0.5682472122886901, 0.710342862091905, 3.3786634270960016},
{0.5586035853633746, 0.7075563497463108, 3.4875622277281826},
{0.5493364747126969, 0.703696168591324, 3.5910999084647575},
{0.540448763510089, 0.6988291450181452, 3.687938841486248},
{0.5319433349289828, 0.6930221054179743, 3.777392151961144},
{0.523823072142811, 0.6863418761820113, 3.8593245041788955},
{0.5160908583250057, 0.6788552837014571, 3.934002883422116},
{0.5087495766489994, 0.6706291543675116, 4.001948372591508},
{0.5018021102882241, 0.6617303145713748, 4.063816011486395},
{0.4952513424161125, 0.6522255907042476, 4.120310004329669},
{0.4891001562060966, 0.6421818091573295, 4.172130538489774},
{0.4833514348316087, 0.6316657963218213, 4.219944605104935},
{0.4780080614660812, 0.6207443785889231, 4.2643732810347545},
{0.4730729192829464, 0.609484382349835, 4.305989522724561},
{0.46854889145563644, 0.5979526339957574, 4.345322340404241},
{0.4644388611575838, 0.5862159599178906, 4.382864755239478},
{0.4607457115622205, 0.5743411865074346, 4.4190840890706085},
{0.45747232584297925, 0.5623951401555899, 4.454433956889477},
{0.454621587173292, 0.5504446472535566, 4.489367931918204},
{0.4521963787265912, 0.5385565341925351, 4.524355337294933},
{0.4501995836763091, 0.5267976273637254, 4.559900082057587},
{0.448634085195878, 0.5152347531583279, 4.596563992596385},
{0.44750276645873005, 0.5039347379675428, 4.634996789229827},
{0.44680851063829785, 0.49296440818257065, 4.665443632123282},
{0.44737061637214043, 0.4827815689580514, -1.3661072461470618},
{0.44989109716889986, 0.47365981484450015, -1.1343672263356606},
{0.4549569410129211, 0.46447595106844647, -0.8863398353375147},
{0.4611155605139756, 0.4574749399787997, -0.7011369243713861},
{0.46871140107612214, 0.4513922039338294, -0.5494798892998474},
{0.4775786409715076, 0.4461823033669887, -0.42766209529496835},
{0.48606536662158223, 0.44237693611210777, -0.3425348820815548},
{0.49525992919101774, 0.4391508365637705, -0.27143382132779004},
{0.5050579045013411, 0.4364753897179705, -0.2113588723969375},
{0.5153548683740788, 0.43432198057070137, -0.15990650875804002},
{0.5242415065318526, 0.43290560743316214, -0.12223755033450434},
{0.5333417170751912, 0.43181532933579797, -0.08835576543599011},
{0.5425950693452563, 0.43103458666980937, -0.057533394074176236},
{0.5519411326832088, 0.4305468198263959, -0.029158211056989458},
{0.5613194764302103, 0.4303354691967577, -0.0027034237746825784},
{0.5706696699274221, 0.43038397517209487, 0.022298152084455625},
{0.5762411347517731, 0.4305309211304245, 0.03198908403931533},
{0.5863740508921439, 0.4311861323321747, 0.09890636965295219},
{0.5961101434135693, 0.4324517586193199, 0.1630897507887763},
{0.6054110734802205, 0.43433478318513097, 0.23336395067620752},
{0.6142385022562686, 0.4368421892228783, 0.31053541764648807},
{0.6236980137734492, 0.4404813028964919, 0.40811620755576183},
{0.6324317705950452, 0.4449554800248213, 0.5164432052771051},
{0.640382543904892, 0.45027514449986233, 0.6356344525827238},
{0.6474931048868259, 0.4564507202136111, 0.7647574703917712},
{0.6537062247246826, 0.46349263105806365, 0.9015334903380465},
{0.6589646746022981, 0.4714113009252158, 1.0423560369126215},
{0.6632112257035082, 0.4802171537070637, 1.1827759604810675},
{0.6663886492121492, 0.4899206132956034, 1.3183483160128426},
{0.6684397163120568, 0.5005321035828308, 1.4301384289294732},
{0.6696532033971575, 0.5112351175326922, 1.48000859622857},
{0.6703703847233398, 0.5214907664895666, 1.531157650944247},
{0.6705610864621648, 0.5313363521785897, 1.590350619259485},
{0.6701951347851938, 0.5408091763248969, 1.657452420977855},
{0.669024388041348, 0.5514394397392556, 1.7447941724486804},
{0.6670069892930607, 0.5616723388265461, 1.839772750987366},
{0.66409502361832, 0.5715671073447389, 1.9390954929777853},
{0.6602405760951143, 0.5811829790518042, 2.038790842353867},
{0.6553957318014325, 0.5905791877057128, 2.134916662762402},
{0.6504184127915044, 0.5985031472037002, 2.211999723635498},
{0.6446480787096772, 0.6063465420058706, 2.282703648632636},
{0.6380545557275124, 0.6141466738373594, 2.3462947002832313},
{0.6306076700165714, 0.6219408444233031, 2.402585748207328},
{0.6237282886902633, 0.6284583442016453, 2.444064510959502},
{0.6162178786040613, 0.635019194848416, 2.4808826231777292},
{0.6080589780516931, 0.6416449830101061, 2.5133765601346916},
{0.6046099290780141, 0.6443183161877735, 2.5193887727012134},
{0.5928002707937533, 0.653436872488106, 2.5071191296743973},
{0.5812124859837675, 0.6625365367626155, 2.4996378288510783},
{0.5698398569591944, 0.6716079696676702, 2.4927430368623926},
{0.5586756660311715, 0.6806418318596391, 2.48645947240362},
{0.5477131955108363, 0.6896287839948906, 2.4808128361212027},
{0.5369457277093266, 0.6985594867297934, 2.475829953776506},
{0.52636654493778, 0.707424600720716, 2.4715389298570702},
{0.515968929507334, 0.7162147866240273, 2.4679693114183263},
{0.5057461637291265, 0.7249207050960962, 2.465152261753497},
{0.4956915299142946, 0.7335330167932909, 2.463120743227511},
{0.4857983103739762, 0.7420423823719797, 2.461909708248172},
{0.47605978741930877, 0.750439462488532, 2.461556296854609},
{0.4664692433614302, 0.7587149177993159, 2.4621000387424052},
{0.45701996051147786, 0.7668594089607006, 2.46358305667171},
{0.4477052211805893, 0.7748635966290542, 2.4660502670648383},
{0.43851830767990246, 0.7827181414607458, 2.4695495721289924},
{0.4294525023205545, 0.7904137041121436, 2.474132035962986},
{0.4205010874136834, 0.7979409452396167, 2.479852034740234},
{0.4116573452704266, 0.8052905254995334, 2.48676736811333},
{0.4029145582019216, 0.8124531055482623, 2.4949393153680988},
{0.3942660085193062, 0.8194193460421724, 2.5044326154884797},
{0.38570497853371805, 0.826179907637632, 2.515315345130288},
{0.3772247505562944, 0.83272545099101, 2.5276586625548405},
{0.36881860689817325, 0.839046636758675, 2.541536378960501},
{0.36047982987049204, 0.8451341255969957, 2.557024311656761},
{0.3522017017843883, 0.8509785781623403, 2.5741993666867913},
{0.3439775049509998, 0.856570655111078, 2.593138292709215},
{0.3358005216814639, 0.8619010170995769, 2.613916044555412},
{0.3276640342869185, 0.8669603247842063, 2.6366036958189762},
{0.31956132507850105, 0.8717392388213343, 2.661265847681511},
{0.3114856763673491, 0.8762284198673299, 2.687957499094404},
{0.3034303704646003, 0.8804185285785615, 2.7167203749111533},
{0.2913708594318466, 0.8861225012035328, 2.7637954652565133},
{0.2793193327181492, 0.8911010272673592, 2.8155644361744274},
{0.2672531181235973, 0.8953225864852846, 2.871864452978616},
{0.25514954344828045, 0.8987556585725532, 2.93235393480976},
{0.242985936492288, 0.9013687232444091, 2.9964920475997086},
{0.2307396250557094, 0.9031302602160967, 3.063537830682425},
{0.2183879369386341, 0.9040087492028599, 3.1325754286625194},
{0.20590819994115142, 0.9039726699199429, 3.2025667887635443},
{0.19327774186335084, 0.90299050208259, 3.2724259268222005},
{0.1804738905053218, 0.9010307254060456, 3.3411021863938846},
{0.1674739736671537, 0.8980618196055534, 3.4076569174009865},
{0.15425531914893617, 0.8940522643963581, 3.4504598772188864},
{0.14353762494294037, 0.8898532135175541, 3.5645588566380084},
{0.13322968022800205, 0.8847168714352416, 3.6476633471354463},
{0.12333997668652459, 0.8786808711893663, 3.727937248013179},
{0.11387700600091133, 0.871782845819873, 3.8049333575616324},
{0.10484925985356566, 0.864060428366707, 3.8783826906692944},
{0.09626522992689104, 0.8555512518698145, 3.9481756055914214},
{0.08813340790329076, 0.8462929493691395, 4.014333910059525},
{0.08046228546516818, 0.836323153904628, 4.076980123575988},
{0.07326035429492671, 0.8256794985162248, 4.136308314082897},
{0.06653610607496978, 0.8143996162438759, 4.192559020605907},
{0.0602980324877007, 0.8025211401275261, 4.2459992269345905},
{0.054554625215522894, 0.7900817032071207, 4.29690732666292},
{0.04931437594083972, 0.7771189385226052, 4.34556246720547},
{0.04610460206862369, 0.7682049419701237, 4.376882707502786},
{0.043124744108185564, 0.7590862316261455, 4.407401399162479},
{0.04037731811357078, 0.7497739580210243, 4.43719434127532},
{0.03786484013882478, 0.7402792716851146, 4.466334628753717},
{0.035589826237993005, 0.7306133231487705, 4.494892551482368},
{0.03355479246512093, 0.7207872629423459, 4.522935573214439},
{0.03176225487425396, 0.7108122415961953, 4.55052836902072},
{0.030214729519437572, 0.7006994096406725, 4.577732904083466},
{0.02891473245471719, 0.6904599176061321, 4.604608539989275},
{0.02786477973413827, 0.6801049160229278, 4.631212157455084},
{0.027067387411746264, 0.6696455554214141, 4.6575982866787164},
{0.0265250715415866, 0.6590929863319451, 4.683819238308932},
{0.026240348177704736, 0.6484583592848748, 4.70992522944886},
{0.02621573337414612, 0.6377528248105575, -1.5472208069736153},
{0.026453743184956184, 0.6269875334393473, -1.5212018900390398},
{0.026956893664180383, 0.6161736357015983, -1.4951587465843508},
{0.02772770086586417, 0.6053222821276648, -1.4690485138227203},
{0.028768680844052975, 0.5944446232479009, -1.4428299987307045},
{0.030082349652792256, 0.5835518095926607, -1.4164636530649877},
{0.03167122334612744, 0.5726549916922984, -1.3899115729188636},
{0.03353781797810399, 0.5617653200771682, -1.3631375243621124},
{0.035684649602767356, 0.550893945277624, -1.3361069965146295},
{0.038114234274162974, 0.5400520178240202, -1.3087872831767298},
{0.040829088046336275, 0.5292506882467112, -1.2811475938503225},
{0.043831726973332735, 0.5185011070760508, -1.253159194608759},
{0.04712466710919778, 0.5078144248423931, -1.2247955787837803},
{0.05071042450797686, 0.4972017920760924, -1.196032666812668},
{0.05459151522371542, 0.486674359307503, -1.1668490338081638},
{0.05877045531045891, 0.47624327706697883, -1.1372261624648363}}