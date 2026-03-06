
void main() {
  final words = ['apple', 'cat', 'banana', 'dog', 'elephant', 'bird', 'hippopotamus'];
  
  print('📚 COLLECTION TRANSFORMATION');
  print('=' * 40);
  print('Original words: $words');
  
  // Solution 1: Using Map.fromIterable
  print('\n🔑 Solution 1: Using Map.fromIterable');
  final wordLengthMap = Map.fromIterable(
    words,
    key: (word) => word,
    value: (word) => (word as String).length,
  );
  
  wordLengthMap.forEach((word, length) {
    if (length > 4) {
      print('$word has length $length');
    }
  });
  
  // Solution 2: Manual map building
  print('\n🔑 Solution 2: Manual map building');
  final wordLengthMap2 = <String, int>{};
  for (var word in words) {
    wordLengthMap2[word] = word.length;
  }
  
  wordLengthMap2.forEach((word, length) {
    if (length > 4) {
      print('$word → $length characters');
    }
  });
  
  // Solution 3: Using collection-for with filtering
  print('\n🔑 Solution 3: Collection-for with filtering');
  final filteredMap = {
    for (var word in words)
      if (word.length > 4) word: word.length
  };
  
  filteredMap.forEach((word, length) {
    print('$word has length $length');
  });
  
  // Solution 4: Grouping by first letter
  print('\n🔑 Solution 4: Grouping by first letter');
  final wordsByFirstLetter = <String, List<String>>{};
  
  for (var word in words) {
    final firstLetter = word[0];
    wordsByFirstLetter.putIfAbsent(firstLetter, () => []);
    wordsByFirstLetter[firstLetter]!.add(word);
  }
  
  wordsByFirstLetter.forEach((letter, wordList) {
    print('$letter: $wordList');
  });
  
  // Additional transformations
  print('\n📊 Statistics:');
  
  // Find longest word
  final longestWord = words.reduce((a, b) => a.length > b.length ? a : b);
  print('Longest word: $longestWord (${longestWord.length} chars)');
  
  // Average word length
  final totalLength = words.fold(0, (sum, word) => sum + word.length);
  final avgLength = totalLength / words.length;
  print('Average length: ${avgLength.toStringAsFixed(2)}');
  
  // Words grouped by length
  final wordsByLength = <int, List<String>>{};
  for (var word in words) {
    wordsByLength.putIfAbsent(word.length, () => []);
    wordsByLength[word.length]!.add(word);
  }
  
  print('\nWords grouped by length:');
  wordsByLength.forEach((length, wordList) {
    print('  $length chars: $wordList');
  });
  
  // Create a map of first letter to count
  final letterCount = <String, int>{};
  for (var word in words) {
    final letter = word[0];
    letterCount[letter] = (letterCount[letter] ?? 0) + 1;
  }
  print('\nLetter frequencies: $letterCount');
  
  // Bonus: Build a word index
  print('\n📖 Word Index:');
  words..sort().asMap().forEach((index, word) {
    print('  $index: $word');
  });
}