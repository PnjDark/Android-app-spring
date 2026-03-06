
String describeTemperature(int? temp) {
  if (temp == null) {
    return 'No data';
  }
  
  // Using switch statement with cases
  switch (temp) {
    case <= 0:
      return 'Freezing';
    case >= 1 && <= 15:
      return 'Cold';
    case >= 16 && <= 25:
      return 'Mild';
    case >= 26 && <= 35:
      return 'Warm';
    case >= 36 && <= 45:
      return 'Hot';
    default:
      return 'Extreme';
  }
}

// Alternative implementation using if-else
String describeTemperatureV2(int? temp) {
  if (temp == null) return 'No data';
  if (temp <= 0) return 'Freezing';
  if (temp <= 15) return 'Cold';
  if (temp <= 25) return 'Mild';
  if (temp <= 35) return 'Warm';
  if (temp <= 45) return 'Hot';
  return 'Extreme';
}

void main() {
  // Sample temperatures (including nulls)
  final temperatures = [
    -5, 0, 8, 17, 22, 29, 37, 42, 48, null, 12, null, 31
  ];
  
  print('🌡️ TEMPERATURE DESCRIPTIONS');
  print('=' * 40);
  
  // Process each temperature
  for (var i = 0; i < temperatures.length; i++) {
    final temp = temperatures[i];
    final description = describeTemperature(temp);
    final tempDisplay = temp?.toString().padLeft(3) ?? 'N/A';
    print('Day ${i + 1}: $tempDisplay°C → $description');
  }
  
  print('=' * 40);
  
  // Statistics
  final validTemps = temperatures.whereType<int>().toList();
  final average = validTemps.isEmpty 
      ? 0.0 
      : validTemps.reduce((a, b) => a + b) / validTemps.length;
  
  print('📈 Statistics:');
  print('  Valid readings: ${validTemps.length}/${temperatures.length}');
  print('  Average: ${average.toStringAsFixed(1)}°C');
  print('  Max: ${validTemps.isNotEmpty ? validTemps.reduce((a, b) => a > b ? a : b) : 'N/A'}°C');
  print('  Min: ${validTemps.isNotEmpty ? validTemps.reduce((a, b) => a < b ? a : b) : 'N/A'}°C');
  
  // Bonus: Group by description using map
  print('\n📊 Grouped by description:');
  final descriptionMap = <String, List<int?>>{};
  
  for (var temp in temperatures) {
    final desc = describeTemperature(temp);
    descriptionMap.putIfAbsent(desc, () => []);
    descriptionMap[desc]!.add(temp);
  }
  
  descriptionMap.forEach((desc, temps) {
    print('  $desc: ${temps.map((t) => t?.toString() ?? 'N/A').join(', ')}');
  });
}