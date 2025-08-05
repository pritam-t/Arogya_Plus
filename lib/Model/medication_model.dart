class Medication {
  final int? id;
  final String name;
  final String description;
  final String time;
  final bool isTaken;

  Medication({
    this.id,
    required this.name,
    required this.description,
    required this.time,
    this.isTaken = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'time': time,
      'isTaken': isTaken ? 1 : 0,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      time: map['time'],
      isTaken: map['isTaken'] == 1,
    );
  }
}
