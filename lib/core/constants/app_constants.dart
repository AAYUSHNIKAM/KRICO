abstract class AppConstants {
  AppConstants._();

  static const String appName = 'KRICO';
  static const String appTagline = 'Krida • Coach • Community';
  static const String appVersion = '0.0.1 (Pilot)';

  static const String defaultCity = 'All Locations';
  static const List<String> majorCities = [
    'All Locations',
    'Mumbai',
    'Delhi NCR',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Chandigarh',
    'Lucknow',
    'Kochi',
    'Indore',
    'Goa',
  ];

  static const List<String> sportCategories = [
    'Cricket',
    'Football',
    'Badminton',
    'Tennis',
    'Basketball',
    'Swimming',
    'Table Tennis',
    'Athletics & Running',
    'Chess',
    'Martial Arts (Karate/Taekwondo)',
    'Boxing',
    'Yoga & Flexibility',
    'Volleyball',
    'Squash',
    'Golf',
    'Archery',
    'Gymnastics',
    'Shooting (Rifle/Pistol)',
    'Roller & Inline Skating',
    'Cycling (Road & Mountain)',
    'Field Hockey',
    'Wrestling (Freestyle/Greco)',
    'Strength & Conditioning',
    'Pickleball',
    'Padel',
    'Kabaddi',
    'Rock Climbing & Bouldering',
    'Rowing & Kayaking',
    'Snooker & Pool',
    'Handball',
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
