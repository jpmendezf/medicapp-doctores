class TodaysAppointment {
  bool? success;
  List<Datas>? data;
  String? msg;

  TodaysAppointment({this.success, this.data, this.msg});

  TodaysAppointment.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Datas>[];
      json['data'].forEach((v) {
        data!.add(new Datas.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Datas {
  int? id;
  int? hospitalId;
  String? time;
  String? date;
  int? age;
  String? patientName;
  int? amount;
  String? patientAddress;
  int? userId;
  int? rate;
  int? review;
  User? user;
  Hospital? hospital;

  Datas(
      {this.id,
        this.hospitalId,
        this.time,
        this.date,
        this.age,
        this.patientName,
        this.amount,
        this.patientAddress,
        this.userId,
        this.rate,
        this.review,
        this.user,
        this.hospital});

  Datas.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hospitalId = json['hospital_id'];
    time = json['time'];
    date = json['date'];
    age = json['age'];
    patientName = json['patient_name'];
    amount = json['amount'];
    patientAddress = json['patient_address'];
    userId = json['user_id'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    hospital = json['hospital'] != null
        ? new Hospital.fromJson(json['hospital'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hospital_id'] = this.hospitalId;
    data['time'] = this.time;
    data['date'] = this.date;
    data['age'] = this.age;
    data['patient_name'] = this.patientName;
    data['amount'] = this.amount;
    data['patient_address'] = this.patientAddress;
    data['user_id'] = this.userId;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? image;
  String? fullImage;

  User({this.id, this.image, this.fullImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Hospital {
  int? id;
  String? name;
  String? address;

  Hospital({this.id, this.name, this.address});

  Hospital.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    return data;
  }
}

