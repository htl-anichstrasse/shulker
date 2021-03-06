import 'package:intl/intl.dart';

class Credential {
  String uuid;
  DateTime startDateTime;
  DateTime endDateTime;
  int usesLeft;
  String secret;
  String label;

  Credential(this.uuid, this.startDateTime, this.endDateTime, this.usesLeft,
      this.secret, this.label);

  factory Credential.fromJson(Map<String, dynamic> item) {
    return Credential(
        item["uuid"],
        DateTime.parse(item["start_time"]),
        DateTime.parse(item["end_time"]),
        item["uses_left"],
        item["secret"],
        item["label"]);
  }

  String toJson() {
    DateFormat aspFormat = DateFormat("y-MM-ddTHH:mm:ss.000");

    return "{\"uuid\": \"" +
        this.uuid +
        "\","
            "\"start_time\": \"" +
        aspFormat.format(this.startDateTime) + "Z" +
        "\","
            "\"end_time\": \"" +
        aspFormat.format(this.endDateTime) + "Z" +
        "\","
            "\"uses_left\": " +
        this.usesLeft.toString() +
        ","
            "\"secret\": \"" +
        this.secret.toString() +
        "\","
            "\"label\": \"" +
        this.label +
        "\" }";
  }

  static List<Credential> creds = [
    new Credential(
        "04bbb3b1-80b7-4ed2-a501-a077ce11cf04",
        DateTime.utc(2020, 11, 1),
        DateTime.utc(2022, 1, 1),
        -1,
        "secretuk",
        "Main"),
    new Credential(
        "09394daa-0ca1-4ac5-a24f-dc50844c8835",
        DateTime.utc(2021, 1, 1),
        DateTime.utc(9999, 1, 1),
        25,
        "anothersecret",
        "Oma"),
    new Credential(
        "3d4fe54e-0684-46d5-9fbf-a80f999e6fe0",
        DateTime.utc(2003, 1, 1),
        DateTime.utc(2025, 1, 1),
        -1,
        "stillsecret",
        "Opa"),
    new Credential(
        "f84bff9a-e550-4cac-ad30-a402450ab499",
        DateTime.utc(2021, 5, 23),
        DateTime.utc(2022, 1, 1),
        -1,
        "stillsecret",
        "Putzkraft"),
    new Credential(
        "6f488a65-2942-4acf-ab00-a039e9a41daa",
        DateTime.utc(2020, 15, 3),
        DateTime.utc(2027, 1, 1),
        -1,
        "stillsecret",
        "Zusatz"),
    new Credential(
        "14f86ce8-ca8a-493d-a5e6-4c4458e80840",
        DateTime.utc(2013, 9, 12),
        DateTime.utc(2022, 1, 1),
        -1,
        "stillsecret",
        "Test"),
  ];

  static List<Credential> getExampleCredentials() {
    return creds;
  }
}
