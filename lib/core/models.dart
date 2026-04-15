// ── 数据模型，对应 API 的 Pydantic 模型 ──

class BaziInput {
  final int year, month, day, hour, minute;
  final int gender; // 1=男 0=女
  final double? longitude;

  const BaziInput({
    required this.year, required this.month, required this.day,
    required this.hour, required this.minute,
    required this.gender, this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'year': year, 'month': month, 'day': day,
    'hour': hour, 'minute': minute, 'gender': gender,
    if (longitude != null) 'longitude': longitude,
  };
}

class BaziMatchInput {
  final BaziInput person1, person2;
  final String matchType;

  const BaziMatchInput({
    required this.person1, required this.person2,
    this.matchType = '婚配',
  });

  Map<String, dynamic> toJson() => {
    'person1': person1.toJson(),
    'person2': person2.toJson(),
    'match_type': matchType,
  };
}

class DivinationInput {
  final String numbers;
  final String question;

  const DivinationInput({required this.numbers, this.question = ''});

  Map<String, dynamic> toJson() => {
    'numbers': numbers, 'question': question,
  };
}

class RecordInput {
  final String name, category;
  final int gender;
  final int year, month, day, hour, minute;
  final double? longitude;
  final String province, city, district;

  const RecordInput({
    required this.name, required this.category,
    required this.gender,
    required this.year, required this.month, required this.day,
    required this.hour, required this.minute,
    this.longitude,
    this.province = '', this.city = '', this.district = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name, 'category': category, 'gender': gender,
    'year': year, 'month': month, 'day': day,
    'hour': hour, 'minute': minute,
    if (longitude != null) 'longitude': longitude,
    'province': province, 'city': city, 'district': district,
  };
}

class FeedbackInput {
  final String category, content;

  const FeedbackInput({required this.category, required this.content});

  Map<String, dynamic> toJson() => {
    'category': category, 'content': content,
  };
}

class PredictionInput {
  final String type, title, content;
  final String detail;

  const PredictionInput({
    required this.type, required this.title, required this.content,
    this.detail = '',
  });

  Map<String, dynamic> toJson() => {
    'type': type, 'title': title, 'content': content, 'detail': detail,
  };
}

// ── API 响应模型 ──

class LoginResponse {
  final String accessToken;
  LoginResponse({required this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse(accessToken: json['access_token'] as String);
}

class Record {
  final String id;
  final String name, category;
  final int gender;
  final int year, month, day, hour, minute;
  final double? longitude;
  final String province, city, district;
  final String createdAt, updatedAt;

  const Record({
    required this.id, required this.name, required this.category,
    required this.gender,
    required this.year, required this.month, required this.day,
    required this.hour, required this.minute,
    this.longitude,
    this.province = '', this.city = '', this.district = '',
    required this.createdAt, required this.updatedAt,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    gender: json['gender'] as int,
    year: json['year'] as int,
    month: json['month'] as int,
    day: json['day'] as int,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    longitude: json['longitude'] as double?,
    province: (json['province'] ?? '') as String,
    city: (json['city'] ?? '') as String,
    district: (json['district'] ?? '') as String,
    createdAt: (json['created_at'] ?? '') as String,
    updatedAt: (json['updated_at'] ?? '') as String,
  );

  String get genderStr => gender == 1 ? '男' : '女';

  String get label => '$name（$category）| $year-${month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')} $genderStr';
}

class PredictionRecord {
  final int id;
  final String type, title, content, detail;
  final String createdAt;

  const PredictionRecord({
    required this.id, required this.type, required this.title,
    required this.content, required this.detail,
    required this.createdAt,
  });

  factory PredictionRecord.fromJson(Map<String, dynamic> json) => PredictionRecord(
    id: json['id'] as int,
    type: json['type'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    detail: (json['detail'] ?? '') as String,
    createdAt: (json['created_at'] ?? '') as String,
  );
}

const predictionTypeLabels = {
  'deep_analysis': '深度分析',
  'analyze': '命理分析',
  'predict': '大运流年',
  'match': '八字匹配',
  'divination': '数字起卦',
  'qa': '知识问答',
};
