class Appointment {
  int? id;
  String doctor;
  String specialty;
  String date;
  String time;
  String type;

  Appointment({
    this.id,
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.type,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctor: map['doctor'],
      specialty: map['specialty'],
      date: map['date'],
      time: map['time'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor': doctor,
      'specialty': specialty,
      'date': date,
      'time': time,
      'type': type,
    };
  }
}
