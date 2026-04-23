import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;

  // Seed nutrition data
  await firestore.collection('nutrition').doc('dailyProgress').set({
    'calories': 1450,
    'maxCalories': 2200,
    'protein': 85,
    'maxProtein': 120,
    'carbs': 180,
    'maxCarbs': 250,
    'fats': 45,
    'maxFats': 70,
  });

  // Seed suggested meal
  await firestore.collection('meals').doc('suggested').set({
    'name': 'Plantain & Egg Stew',
    'tag': 'HIGH IN PROTEIN',
    'imageUrl':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB4L0BmYcmY6hpUDnyzl_pjvQEk8lg0QVc-Fwl1DzPhMYGtv7wlMFPtxjgkbrRtt1SbHGphZk5sfjmfRw08RP_1iiJPJbaq_OO3D06SP1sy72pN1KFhQgyh6Yg04pcOlqg7n4NlfI3dPG2Yk-CyE8YOkeXmO4pywi8sRJWdV5iYriPiVEBsQ0xb5lyR0QPLG-qB69gHD4wac24whRU0r4y28lppe2o2lqV-NVXqm_OUOuwvjEPCICgIddQr9gr4qsAess8g1mtUx7ak',
  });

  // Clear existing activities
  final activities = await firestore.collection('activities').get();
  for (final doc in activities.docs) {
    await doc.reference.delete();
  }

  // Seed recent activities
  await firestore.collection('activities').add({
    'title': 'Breakfast: Fufu & Ndolé',
    'subtitle': 'Today, 8:30 AM',
    'trailing': '850 kcal',
    'icon': 'breakfast_dining',
    'color': 'primary',
  });

  await firestore.collection('activities').add({
    'title': 'Grocery Receipt',
    'subtitle': 'Yesterday, 5:45 PM',
    'trailing': '\$45.20',
    'icon': 'receipt_long',
    'color': 'tertiary',
  });
}
