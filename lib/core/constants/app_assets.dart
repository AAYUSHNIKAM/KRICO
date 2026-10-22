abstract final class AppAssets {
  AppAssets._();

  // Logos & Brand
  static const String logoDark = 'assets/logos/logo_dark.svg';
  static const String logoLight = 'assets/logos/logo_light.svg';
  static const String appIconSymbol = 'assets/logos/app_icon_symbol.svg';
  static const String splashEmblem = 'assets/logos/splash_emblem.png';

  // 3D Sports Crests
  static const String cricket3d = 'assets/icons/sports_3d/cricket_3d.png';
  static const String football3d = 'assets/icons/sports_3d/football_3d.png';
  static const String badminton3d = 'assets/icons/sports_3d/badminton_3d.png';
  static const String tennis3d = 'assets/icons/sports_3d/tennis_3d.png';
  static const String basketball3d = 'assets/icons/sports_3d/basketball_3d.png';
  static const String swimming3d = 'assets/icons/sports_3d/swimming_3d.png';
  static const String athletics3d = 'assets/icons/sports_3d/athletics_3d.png';
  static const String tableTennis3d = 'assets/icons/sports_3d/table_tennis_3d.png';
  static const String squash3d = 'assets/icons/sports_3d/squash_3d.png';
  static const String chess3d = 'assets/icons/sports_3d/chess_3d.png';

  // Stadium & Backgrounds
  static const String floodlitTurfNight = 'assets/backgrounds/floodlit_turf_night.webp';
  static const String indoorBadmintonArena = 'assets/backgrounds/indoor_badminton_arena.webp';
  static const String cricketStadiumSunset = 'assets/backgrounds/cricket_stadium_sunset.webp';
  static const String swimmingOlympicPool = 'assets/backgrounds/swimming_olympic_pool.webp';
  static const String courtGeometryGrid = 'assets/backgrounds/court_geometry_grid.svg';

  // Accreditation Badges
  static const String badgeBwf = 'assets/icons/accreditations/badge_bwf_certified.png';
  static const String badgeFifa = 'assets/icons/accreditations/badge_fifa_turf.png';
  static const String badgeBcci = 'assets/icons/accreditations/badge_bcci_level.png';
  static const String badgeVerifiedSafety = 'assets/icons/accreditations/badge_verified_safety.png';
  static const String badgeHallOfFame = 'assets/icons/accreditations/badge_hall_of_fame.png';

  // Lottie Micro-Animations
  static const String celebrationConfetti = 'assets/lottie/celebration_confetti.json';
  static const String qrScanPulse = 'assets/lottie/qr_scan_pulse.json';
  static const String levelUpBurst = 'assets/lottie/level_up_burst.json';
  static const String bookingSlotTimer = 'assets/lottie/booking_slot_timer.json';
  static const String liveSessionPulse = 'assets/lottie/live_session_pulse.json';

  // Animated Fallback GIFs (Ready in assets/animations)
  static const String animConfetti = 'assets/animations/confetti_celebration.gif';
  static const String animRunner = 'assets/animations/loading_runner.gif';
  static const String animTrophy = 'assets/animations/shimmering_trophy.gif';
  static const String animRadar = 'assets/animations/running_radar.gif';
  static const String animFlame = 'assets/animations/flame_streak.gif';
  static const String animStopwatch = 'assets/animations/stopwatch_loop.gif';

  // Dashboard Banners (Ready in assets/images/dashboard)
  static const String bannerAiVideo = 'assets/images/dashboard/ai_video_analysis_banner.jpg';
  static const String bannerArenaDiscovery = 'assets/images/dashboard/arena_discovery_banner.jpg';
  static const String bannerContractEscrow = 'assets/images/dashboard/contract_escrow_banner.jpg';
  static const String bannerSquadGoals = 'assets/images/dashboard/squad_goals_banner.jpg';

  // Empty State Illustrations (Ready in assets/empty)
  static const String emptyBookings = 'assets/empty/no_bookings.png';
  static const String emptyCertificates = 'assets/empty/no_certificates.png';
  static const String emptyChallenges = 'assets/empty/no_challenges.png';
  static const String emptyMessages = 'assets/empty/no_messages.png';
  static const String emptyNotifications = 'assets/empty/no_notifications.png';

  // Avatars (Ready in assets/avatars)
  static const String avatarAthleteGirl = 'assets/avatars/athlete_racket_girl.jpg';
  static const String avatarAthleteSprinter = 'assets/avatars/athlete_teen_sprinter.jpg';
  static const String avatarCoachBadminton = 'assets/avatars/coach_badminton_pro.jpg';
  static const String avatarCoachFootball = 'assets/avatars/coach_football_trainer.jpg';
  static const String avatarCoachTennis = 'assets/avatars/coach_tennis_master.jpg';
  static const String avatarParent = 'assets/avatars/parent_guardian_1.jpg';

  // Sport Photography Heroes (Ready in assets/images/sports)
  static const String heroCricket = 'assets/images/sports/cricket_hero.jpg';
  static const String heroFootball = 'assets/images/sports/football_hero.jpg';
  static const String heroBadminton = 'assets/images/sports/badminton_hero.jpg';
  static const String heroTennis = 'assets/images/sports/tennis_hero.jpg';
  static const String heroBasketball = 'assets/images/sports/basketball_hero.jpg';
  static const String heroSwimming = 'assets/images/sports/swimming_hero.jpg';
  static const String heroAthletics = 'assets/images/sports/athletics_hero.jpg';

  /// Safe sport hero photography resolver with graceful fallback
  static String getSportHero(String sportName) {
    final s = sportName.toLowerCase();
    if (s.contains('cricket')) return heroCricket;
    if (s.contains('foot') || s.contains('soccer')) return heroFootball;
    if (s.contains('badminton')) return heroBadminton;
    if (s.contains('tennis')) return heroTennis;
    if (s.contains('basket')) return heroBasketball;
    if (s.contains('swim')) return heroSwimming;
    if (s.contains('athletic') || s.contains('run')) return heroAthletics;
    return heroFootball;
  }

  /// Safe 3D sport icon resolver
  static String? getSport3dIcon(String sportName) {
    final s = sportName.toLowerCase();
    if (s.contains('cricket')) return cricket3d;
    if (s.contains('foot') || s.contains('soccer')) return football3d;
    if (s.contains('badminton')) return badminton3d;
    if (s.contains('tennis')) return tennis3d;
    if (s.contains('basket')) return basketball3d;
    if (s.contains('swim')) return swimming3d;
    if (s.contains('athletic') || s.contains('run')) return athletics3d;
    if (s.contains('table') || s.contains('ping')) return tableTennis3d;
    if (s.contains('squash')) return squash3d;
    if (s.contains('chess')) return chess3d;
    return null;
  }
}
