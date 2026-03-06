class User {
  final String name;
  final String? email;
  
  User(this.name, this.email);
  
  @override
  String toString() => 'User(name: $name, email: $email)';
}

void main() {
  // Sample data
  final users = [
    User('Alex', 'alex@example.com'),
    User('Blake', null),
    User('Casey', 'casey@work.com'),
    User('Jordan', 'jordan@school.edu'),
    User('Taylor', null),
    User('Morgan', 'morgan@company.org')
  ];
  
  print('📧 EMAIL PROCESSING REPORT');
  print('=' * 40);
  
  // Solution 1: Using conditional and null-aware operators
  var validEmailCount = 0;
  
  for (var user in users) {
    // Using conditional to check if email is not null
    if (user.email != null) {
      print('✅ ${user.name}: ${user.email!.toUpperCase()}');
      validEmailCount++;
    } else {
      print('❌ ${user.name} has no email');
    }
  }
  
  print('=' * 40);
  print('📊 Summary: $validEmailCount users have valid emails');
  
  // Alternative solution using whereType
  final validEmails = users.where((user) => user.email != null).toList();
  print('Alternative count: ${validEmails.length} valid emails');
  
  // Bonus: Extract domains from emails
  print('\n🌐 Email Domains:');
  for (var user in users) {
    if (user.email != null) {
      final domain = user.email!.split('@')[1];
      print('  ${user.name}: $domain');
    }
  }
  
  // Using forEach with null-aware operator
  print('\n🔄 Using forEach:');
  users.forEach((user) {
    user.email != null 
        ? print('  ${user.name}: ${user.email!.toUpperCase()}')
        : print('  ${user.name}: No email');
  });
}