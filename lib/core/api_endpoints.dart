class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8000';

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // Bazi
  static const String baziCalculate = '/api/bazi/calculate';
  static const String deepAnalysis = '/api/bazi/deep-analysis';
  static const String analyze = '/api/bazi/analyze';
  static const String predictEvents = '/api/bazi/predict-events';
  static const String match = '/api/bazi/match';

  // Divination
  static const String divination = '/api/divination';

  // Geo
  static const String provinces = '/api/geo/provinces';
  static const String cities = '/api/geo/cities';
  static const String districts = '/api/geo/districts';
  static const String longitude = '/api/geo/longitude';

  // Archive
  static const String records = '/api/archive/records';

  // Knowledge
  static const String books = '/api/knowledge/books';
  static const String bookContent = '/api/knowledge/books';
  static const String search = '/api/knowledge/search';
  static const String qa = '/api/knowledge/qa';

  // Feedback
  static const String feedback = '/api/feedback';
  static const String feedbackCategories = '/api/feedback/categories';

  // Predictions
  static const String predictions = '/api/predictions';

  // Health
  static const String health = '/api/health';
}
