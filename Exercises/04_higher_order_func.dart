
typedef IntPredicate = bool Function(int);

List<int> processList(List<int> numbers, IntPredicate predicate) {
  final result = <int>[];
  for (var number in numbers) {
    if (predicate(number)) {
      result.add(number);
    }
  }
  return result;
}

// More concise version using where
List<int> processListFunctional(List<int> numbers, bool Function(int) predicate) {
  return numbers.where(predicate).toList();
}

// Generic version that works with any type
List<T> processListGeneric<T>(List<T> items, bool Function(T) predicate) {
  return items.where(predicate).toList();
}

// Function that returns a function (closure)
Function makePredicate(int threshold) {
  return (int number) => number > threshold;
}

// Function that returns a typed function
int Function(int) makeMultiplier(int factor) {
  return (int x) => x * factor;
}

void main() {
  final nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  
  print('🎯 HIGHER-ORDER FUNCTION DEMO');
  print('=' * 40);
  
  // Test with different predicates
  final even = processList(nums, (n) => n % 2 == 0);
  print('Even numbers: $even');
  
  final greaterThan5 = processList(nums, (n) => n > 5);
  print('Numbers > 5: $greaterThan5');
  
  final multiplesOf3 = processList(nums, (n) => n % 3 == 0);
  print('Multiples of 3: $multiplesOf3');
  
  // Using the functional version
  final odd = processListFunctional(nums, (n) => n % 2 != 0);
  print('Odd numbers: $odd');
  
  // Using generic version with different types
  print('\n📝 Generic version with strings:');
  final words = ['apple', 'cat', 'banana', 'dog', 'elephant'];
  final longWords = processListGeneric<String>(words, (word) => word.length > 4);
  print('Words longer than 4 chars: $longWords');
  
  // Custom higher-order function that returns a function
  print('\n🔄 Function returning a function:');
  
  final greaterThan7 = makePredicate(7) as bool Function(int);
  final numbersGreaterThan7 = nums.where(greaterThan7).toList();
  print('Numbers > 7: $numbersGreaterThan7');
  
  // Create multiplier functions
  final double = makeMultiplier(2);
  final triple = makeMultiplier(3);
  
  print('\n🔢 Multiplier functions:');
  print('Double 5: ${double(5)}');
  print('Triple 5: ${triple(5)}');
  
  // Anonymous functions (lambdas)
  print('\n🔄 Anonymous functions:');
  
  // Using forEach with anonymous function
  print('Numbers with their squares:');
  nums.take(5).forEach((n) {
    print('  $n → ${n * n}');
  });
  
  // Sorting with custom comparator
  final unsorted = [3, 1, 4, 1, 5, 9, 2, 6];
  unsorted.sort((a, b) => a.compareTo(b));
  print('Sorted: $unsorted');
  
  // Custom comparator for descending order
  unsorted.sort((a, b) => b.compareTo(a));
  print('Descending: $unsorted');
}