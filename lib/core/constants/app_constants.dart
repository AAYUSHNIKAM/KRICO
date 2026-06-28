abstract class AppConstants {
  AppConstants._();

  static const String appName = 'SportsEco';
  static const String appTagline = 'Your Complete Sports Ecosystem';
  static const String appVersion = '1.0.0';

  static const String defaultCity = 'Pune';
  static const List<String> puneLocalities = [
    'Koregaon Park',
    'Kalyani Nagar',
    'Viman Nagar',
    'Baner',
    'Hinjewadi',
    'Shivajinagar',
    'Deccan Gymkhana',
    'Camp',
    'Kothrud',
    'Hadapsar',
    'Aundh',
    'Wakad',
  ];

  static const List<String> sportCategories = [
    'Cricket',
    'Football',
    'Badminton',
    'Tennis',
    'Swimming',
    'Basketball',
    'Athletics',
    'Chess',
    'Yoga',
    'Martial Arts',
  ];

  static const double platformFeePercent = 10.0;
  static const double opportunityFeePercent = 10.0;
  static const double contractSavingsPercent = 10.0;

  static const int maxChatMessageLength = 1000;
  static const int maxFileSizeMB = 10;

  static const List<String> coachSubscriptionTiers = [
    'Starter',
    'Professional',
    'Elite',
  ];

  static const Map<String, double> coachSubscriptionPrices = {
    'Starter': 0,
    'Professional': 499,
    'Elite': 999,
  };

  static const Map<String, List<String>> coachSubscriptionFeatures = {
    'Starter': ['Basic Profile', 'Client Messaging', 'Standard Support'],
    'Professional': [
      'Enhanced Profile',
      'Priority Support',
      'Analytics Dashboard',
      'Session Scheduling',
    ],
    'Elite': [
      'Premium Profile Badge',
      'Dedicated Support',
      'Advanced Analytics',
      'Priority Matching',
      'Marketing Boost',
      'Contract Templates',
    ],
  };

  static const List<String> venueAmenities = [
    'Parking',
    'Changing Rooms',
    'Drinking Water',
    'Floodlights',
    'First Aid',
    'Equipment Rental',
    'Cafeteria',
    'Indoor Courts',
    'Air Conditioning',
    'Spectator Seating',
  ];
}
