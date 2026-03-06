

class Person {
  final String name;
  final int age;
  
  Person(this.name, this.age);
  
  @override
  String toString() => 'Person(name: $name, age: $age)';
}

void main() {
  final people = [
    Person('Alice', 25),
    Person('Bob', 30),
    Person('Charlie', 35),
    Person('Anna', 22),
    Person('Ben', 28),
    Person('David', 40),
    Person('Eve', 29),
    Person('Alex', 33),
    Person('Bella', 27),
    Person('George', 45)
  ];
  
  print('👥 COMPLEX DATA PROCESSING');
  print('=' * 50);
  print('All people:');
  people.forEach((p) => print('  ${p.name} (${p.age})'));
  
  // Solution 1: Step-by-step approach
  print('\n📝 Solution 1: Step-by-step');
  
  // Step 1: Filter people whose name starts with 'A' or 'B'
  final filteredPeople = people.where((person) {
    final firstLetter = person.name[0];
    return firstLetter == 'A' || firstLetter == 'B';
  }).toList();
  
  print('People with names starting with A or B:');
  filteredPeople.forEach((p) => print('  ${p.name} (${p.age})'));
  
  // Step 2: Extract ages
  final ages = filteredPeople.map((p) => p.age).toList();
  print('Ages: $ages');
  
  // Step 3: Calculate average
  final averageAge = ages.isNotEmpty 
      ? ages.reduce((a, b) => a + b) / ages.length 
      : 0.0;
  
  // Step 4: Format and print
  print('Average age: ${averageAge.toStringAsFixed(1)}');
  
  // Solution 2: Functional chain
  print('\n⚡ Solution 2: Functional chain');
  final result = people
      .where((p) => ['A', 'B'].contains(p.name[0]))
      .map((p) => p.age)
      .toList();
  
  final avg = result.isNotEmpty 
      ? result.reduce((a, b) => a + b) / result.length 
      : 0.0;
  
  print('Average age (A/B names): ${avg.toStringAsFixed(1)}');
  
  // Solution 3: Using fold for sum and count
  print('\n🔢 Solution 3: Using fold');
  final stats = people
      .where((p) => p.name[0] == 'A' || p.name[0] == 'B')
      .fold<Map<String, dynamic>>(
        {'sum': 0, 'count': 0},
        (acc, person) {
          acc['sum'] = acc['sum'] + person.age;
          acc['count'] = acc['count'] + 1;
          return acc;
        }
      );
  
  final totalAge = stats['sum'] as int;
  final count = stats['count'] as int;
  final avg2 = count > 0 ? totalAge / count : 0.0;
  
  print('Total age: $totalAge');
  print('Count: $count');
  print('Average: ${avg2.toStringAsFixed(1)}');
  
  // Additional analytics
  print('\n📊 Additional Statistics:');
  
  // Group by first letter
  final byFirstLetter = <String, List<Person>>{};
  for (var person in people) {
    final letter = person.name[0];
    byFirstLetter.putIfAbsent(letter, () => []);
    byFirstLetter[letter]!.add(person);
  }
  
  print('Grouped by first letter:');
  byFirstLetter.forEach((letter, persons) {
    final avgAgeForLetter = persons.map((p) => p.age).reduce((a, b) => a + b) / persons.length;
    print('  $letter: ${persons.length} people, avg age = ${avgAgeForLetter.toStringAsFixed(1)}');
  });
  
  // Age distribution
  print('\n📈 Age distribution:');
  final ageGroups = <String, List<Person>>{};
  
  for (var person in people) {
    String group;
    if (person.age >= 20 && person.age <= 29) {
      group = '20s';
    } else if (person.age >= 30 && person.age <= 39) {
      group = '30s';
    } else if (person.age >= 40 && person.age <= 49) {
      group = '40s';
    } else {
      group = 'Other';
    }
    
    ageGroups.putIfAbsent(group, () => []);
    ageGroups[group]!.add(person);
  }
  
  ageGroups.forEach((group, persons) {
    print('  $group: ${persons.length} people (${persons.map((p) => p.name).join(', ')})');
  });
  
  // Find oldest and youngest in A/B group
  final aBPeople = people.where((p) => ['A', 'B'].contains(p.name[0])).toList();
  
  if (aBPeople.isNotEmpty) {
    aBPeople.sort((a, b) => a.age.compareTo(b.age));
    final youngest = aBPeople.first;
    final oldest = aBPeople.last;
    
    print('\n🏆 A/B Name Statistics:');
    print('  Youngest: ${youngest.name} (${youngest.age})');
    print('  Oldest: ${oldest.name} (${oldest.age})');
  }
}