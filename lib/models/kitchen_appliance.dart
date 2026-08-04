enum ApplianceType {
  conventionalOven,
  fanOven,
  airFryer,
  microwave,
  stovetop,
  slowCooker,
  pressureCooker,
  grill,
  riceCooker,
  sousVide,
  toasterOven,
}

extension ApplianceTypeLabel on ApplianceType {
  String get label {
    switch (this) {
      case ApplianceType.conventionalOven:
        return 'Conventional oven';
      case ApplianceType.fanOven:
        return 'Fan oven';
      case ApplianceType.airFryer:
        return 'Air fryer';
      case ApplianceType.microwave:
        return 'Microwave';
      case ApplianceType.stovetop:
        return 'Hob / stovetop';
      case ApplianceType.slowCooker:
        return 'Slow cooker';
      case ApplianceType.pressureCooker:
        return 'Pressure cooker';
      case ApplianceType.grill:
        return 'Grill';
      case ApplianceType.riceCooker:
        return 'Rice cooker';
      case ApplianceType.sousVide:
        return 'Sous-vide';
      case ApplianceType.toasterOven:
        return 'Toaster oven';
    }
  }

  String get defaultName => label;

  int get defaultMinCelsius {
    switch (this) {
      case ApplianceType.microwave:
        return 0;
      case ApplianceType.slowCooker:
        return 60;
      case ApplianceType.sousVide:
        return 30;
      case ApplianceType.stovetop:
        return 0;
      default:
        return 50;
    }
  }

  int get defaultMaxCelsius {
    switch (this) {
      case ApplianceType.airFryer:
        return 240;
      case ApplianceType.microwave:
        return 0;
      case ApplianceType.slowCooker:
        return 120;
      case ApplianceType.sousVide:
        return 95;
      case ApplianceType.stovetop:
        return 0;
      case ApplianceType.riceCooker:
        return 120;
      default:
        return 300;
    }
  }

  bool get supportsTemperature =>
      this != ApplianceType.microwave &&
      this != ApplianceType.stovetop;

  bool get usuallyPreheats =>
      this == ApplianceType.conventionalOven ||
      this == ApplianceType.fanOven ||
      this == ApplianceType.airFryer ||
      this == ApplianceType.grill ||
      this == ApplianceType.toasterOven;
}

class KitchenAppliance {
  const KitchenAppliance({
    required this.id,
    required this.type,
    required this.name,
    required this.minCelsius,
    required this.maxCelsius,
    required this.preheatRequired,
    this.capacityLitres,
    this.powerWatts,
  });

  final String id;
  final ApplianceType type;
  final String name;
  final int minCelsius;
  final int maxCelsius;
  final bool preheatRequired;
  final double? capacityLitres;
  final int? powerWatts;

  KitchenAppliance copyWith({
    String? name,
    int? minCelsius,
    int? maxCelsius,
    bool? preheatRequired,
    double? capacityLitres,
    int? powerWatts,
  }) {
    return KitchenAppliance(
      id: id,
      type: type,
      name: name ?? this.name,
      minCelsius: minCelsius ?? this.minCelsius,
      maxCelsius: maxCelsius ?? this.maxCelsius,
      preheatRequired: preheatRequired ?? this.preheatRequired,
      capacityLitres: capacityLitres ?? this.capacityLitres,
      powerWatts: powerWatts ?? this.powerWatts,
    );
  }
}

enum TemperatureUnit { celsius, fahrenheit }

extension TemperatureUnitLabel on TemperatureUnit {
  String get symbol => this == TemperatureUnit.celsius ? '°C' : '°F';
}
