class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final List<ExerciseModel> exercises;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format
    String extractId(dynamic idField) {
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) {
        return idField['\$oid'];
      }
      return '';
    }

    return WorkoutModel(
      id: extractId(json['_id']),
      userId: extractId(json['user_id']),
      name: json['name'],
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class ExerciseModel {
  final String name;
  final List<SetModel> sets;
  final String? id; // Optional ID for MongoDB

  ExerciseModel({
    required this.name,
    required this.sets,
    this.id,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format
    String? extractId(dynamic idField) {
      if (idField == null) return null;
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) {
        return idField['\$oid'];
      }
      return null;
    }

    return ExerciseModel(
      name: json['name'],
      sets: (json['sets'] as List).map((s) => SetModel.fromJson(s)).toList(),
      id: extractId(json['_id']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
    if (id != null) {
      data['_id'] = id;
    }
    return data;
  }
}

class SetModel {
  int reps;
  double weight;
  final String? id; // Optional ID for MongoDB

  SetModel({
    required this.reps,
    required this.weight,
    this.id,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format
    String? extractId(dynamic idField) {
      if (idField == null) return null;
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) {
        return idField['\$oid'];
      }
      return null;
    }

    // Handle MongoDB NumberInt format
    int extractInt(dynamic intField) {
      if (intField is int) return intField;
      if (intField is Map && intField.containsKey('\$numberInt')) {
        return int.parse(intField['\$numberInt']);
      }
      return 0;
    }

    // Handle MongoDB NumberDouble format
    double extractDouble(dynamic doubleField) {
      if (doubleField is double) return doubleField;
      if (doubleField is int) return doubleField.toDouble();
      if (doubleField is Map) {
        if (doubleField.containsKey('\$numberInt')) {
          return int.parse(doubleField['\$numberInt']).toDouble();
        }
        if (doubleField.containsKey('\$numberDouble')) {
          return double.parse(doubleField['\$numberDouble']);
        }
      }
      return 0.0;
    }

    return SetModel(
      reps: extractInt(json['reps']),
      weight: extractDouble(json['weight']),
      id: extractId(json['_id']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'reps': reps,
      'weight': weight,
    };
    if (id != null) {
      data['_id'] = id;
    }
    return data;
  }
}
