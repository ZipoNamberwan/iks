class Option {
  final String id;
  final String label;
  final dynamic value;

  Option({
    required this.id,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
    };
  }

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      label: json['label'],
      value: json['value'],
    );
  }
}
