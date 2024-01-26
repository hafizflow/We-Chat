class Message {
  Message({
    required this.formId,
    required this.type,
    required this.msg,
    required this.read,
    required this.toId,
    required this.sent,
  });
  late final String formId;
  late final Type type;
  late final String msg;
  late final String read;
  late final String toId;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    formId = json['formId'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    msg = json['msg'].toString();
    read = json['read'].toString();
    toId = json['toId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['formId'] = formId;
    data['type'] = type.name;
    data['msg'] = msg;
    data['read'] = read;
    data['toId'] = toId;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }

extension TypeExtension on Type {
  String get name {
    switch (this) {
      case Type.text:
        return 'text';
      case Type.image:
        return 'image';
    }
  }
}
