import 'package:flutter/material.dart';

import '../models.dart';

/// SAMPLE DATA ONLY. Replace with the real trainer database (Supabase) later.

final List<Category> kCategories = [
  const Category(id: 'football', name: L('Football', 'كرة القدم'), icon: Icons.sports_soccer, color: Color(0xFF166534), tint: Color(0xFFDCFCE7)),
  const Category(id: 'swimming', name: L('Swimming', 'سباحة'), icon: Icons.pool, color: Color(0xFF1E40AF), tint: Color(0xFFDBEAFE)),
  const Category(id: 'drawing', name: L('Drawing', 'رسم'), icon: Icons.palette, color: Color(0xFF9A3412), tint: Color(0xFFFFEDD5)),
  const Category(id: 'piano', name: L('Piano', 'بيانو'), icon: Icons.piano, color: Color(0xFF5B21B6), tint: Color(0xFFEDE9FE)),
  const Category(id: 'chess', name: L('Chess', 'شطرنج'), icon: Icons.grid_on, color: Color(0xFF1F2937), tint: Color(0xFFE5E7EB)),
  const Category(id: 'karate', name: L('Karate', 'كاراتيه'), icon: Icons.sports_martial_arts, color: Color(0xFF991B1B), tint: Color(0xFFFEE2E2)),
  const Category(id: 'tennis', name: L('Tennis', 'تنس'), icon: Icons.sports_tennis, color: Color(0xFF854D0E), tint: Color(0xFFFEF9C3)),
  const Category(id: 'ballet', name: L('Ballet', 'باليه'), icon: Icons.accessibility_new, color: Color(0xFF9D174D), tint: Color(0xFFFCE7F3)),
];

Category categoryById(String id) => kCategories.firstWhere((c) => c.id == id);

const kDays = <String, L>{
  'sat': L('Sat', 'السبت'),
  'sun': L('Sun', 'الأحد'),
  'mon': L('Mon', 'الاثنين'),
  'tue': L('Tue', 'الثلاثاء'),
  'wed': L('Wed', 'الأربعاء'),
  'thu': L('Thu', 'الخميس'),
  'fri': L('Fri', 'الجمعة'),
};

const kTimes = <String, L>{
  'morning': L('Morning', 'صباحاً'),
  'afternoon': L('Afternoon', 'بعد الظهر'),
  'evening': L('Evening', 'مساءً'),
};

const kPlaces = <String, L>{
  'home': L('At home', 'في المنزل'),
  'venue': L("Trainer's venue", 'مكان المدرب'),
  'club': L('Sports club', 'نادٍ رياضي'),
};

final List<Trainer> kTrainers = [
  const Trainer(
    id: 't1',
    name: L('Karim Adel', 'كريم عادل'),
    categoryId: 'football',
    area: L('Nasr City', 'مدينة نصر'),
    rating: 4.9,
    reviewCount: 38,
    distanceKm: 1.2,
    pricePerSession: 300,
    yearsExperience: 8,
    ages: L('6–14 yrs', '6–14 سنة'),
    about: L(
      'Former player and certified youth coach. Focuses on core skills, fitness and teamwork, with a monthly progress check for each child.',
      'لاعب كرة سابق ومدرب ناشئين معتمد. يركّز على المهارات الأساسية واللياقة وروح الفريق، مع متابعة شهرية لمستوى كل طفل.',
    ),
    slots: [
      Slot(L('Saturday', 'السبت'), L('4 – 8 pm', '4 – 8 م')),
      Slot(L('Monday', 'الاثنين'), L('5 – 9 pm', '5 – 9 م')),
      Slot(L('Wednesday', 'الأربعاء'), L('5 – 9 pm', '5 – 9 م')),
    ],
    areas: [L('Nasr City', 'مدينة نصر'), L('Heliopolis', 'مصر الجديدة')],
    reviews: [
      Review(L("Youssef's mom", 'أم يوسف'), 5, L('Always on time, and my son improved a lot in two months.', 'ملتزم بالمواعيد وابني اتحسّن كتير في شهرين.')),
      Review(L("Adam's dad", 'أبو آدم'), 5, L('Calm and encouraging with the kids.', 'أسلوبه هادي ومشجّع مع الأطفال.')),
    ],
    color: Color(0xFF166534),
  ),
  const Trainer(
    id: 't2',
    name: L('Nour El-Sayed', 'نور السيد'),
    categoryId: 'swimming',
    area: L('Heliopolis', 'مصر الجديدة'),
    rating: 4.8,
    reviewCount: 52,
    distanceKm: 2.4,
    pricePerSession: 400,
    yearsExperience: 6,
    ages: L('5–12 yrs', '5–12 سنة'),
    about: L(
      'Certified swimming coach for beginners and intermediates, with a strong focus on water safety.',
      'مدربة سباحة معتمدة للمبتدئين والمستوى المتوسط، مع تركيز كبير على الأمان في الماء.',
    ),
    slots: [
      Slot(L('Sunday', 'الأحد'), L('9 am – 1 pm', '9 ص – 1 م')),
      Slot(L('Tuesday', 'الثلاثاء'), L('4 – 7 pm', '4 – 7 م')),
      Slot(L('Friday', 'الجمعة'), L('9 am – 12 pm', '9 ص – 12 م')),
    ],
    areas: [L('Heliopolis', 'مصر الجديدة'), L('Nasr City', 'مدينة نصر')],
    reviews: [
      Review(L("Sara's mom", 'أم سارة'), 5, L('My daughter was afraid of water and now swims on her own.', 'بنتي كانت بتخاف من المية ودلوقتي بتعوم لوحدها.')),
      Review(L("Malek's mom", 'أم مالك'), 4, L('Excellent, but limited time slots.', 'ممتازة بس المواعيد محدودة.')),
    ],
    color: Color(0xFF1E40AF),
  ),
  const Trainer(
    id: 't3',
    name: L('Mariam Fawzy', 'مريم فوزي'),
    categoryId: 'drawing',
    area: L('Maadi', 'المعادي'),
    rating: 4.7,
    reviewCount: 21,
    distanceKm: 3.1,
    pricePerSession: 250,
    yearsExperience: 5,
    ages: L('4–12 yrs', '4–12 سنة'),
    about: L(
      "Visual artist teaching drawing and painting that builds children's imagination and confidence.",
      'فنانة تشكيلية تقدّم حصص رسم وتلوين تنمّي الخيال والثقة بالنفس عند الأطفال.',
    ),
    slots: [
      Slot(L('Monday', 'الاثنين'), L('5 – 7 pm', '5 – 7 م')),
      Slot(L('Thursday', 'الخميس'), L('4 – 6 pm', '4 – 6 م')),
    ],
    areas: [L('Maadi', 'المعادي'), L('Degla', 'دجلة')],
    reviews: [
      Review(L("Laila's mom", 'أم ليلى'), 5, L('Laila looks forward to the class every week.', 'ليلى بتستنى الحصة كل أسبوع.')),
      Review(L("Jana's dad", 'أبو جنى'), 4, L('Fun, well-organised classes.', 'حصص ممتعة ومنظمة.')),
    ],
    color: Color(0xFF9A3412),
  ),
  const Trainer(
    id: 't4',
    name: L('Omar Hany', 'عمر هاني'),
    categoryId: 'chess',
    area: L('New Cairo', 'التجمع الخامس'),
    rating: 5.0,
    reviewCount: 14,
    distanceKm: 4.0,
    pricePerSession: 280,
    yearsExperience: 7,
    ages: L('6–16 yrs', '6–16 سنة'),
    about: L(
      'Rated chess player who teaches kids logical thinking and planning through chess.',
      'لاعب شطرنج مصنّف، يعلّم الأطفال التفكير المنطقي والتخطيط من خلال الشطرنج.',
    ),
    slots: [
      Slot(L('Sunday', 'الأحد'), L('4 – 8 pm', '4 – 8 م')),
      Slot(L('Tuesday', 'الثلاثاء'), L('4 – 8 pm', '4 – 8 م')),
    ],
    areas: [L('New Cairo', 'التجمع الخامس'), L('El Rehab', 'الرحاب')],
    reviews: [
      Review(L("Youssef's mom", 'أم يوسف'), 5, L('My son has become calmer and more focused.', 'ابني بقى أهدى وأكتر تركيز.')),
      Review(L("Omar's mom", 'أم عمر'), 5, L('Clear explanations and very patient.', 'شرح واضح وصبور جداً.')),
    ],
    color: Color(0xFF1F2937),
  ),
  const Trainer(
    id: 't5',
    name: L('Salma Ramy', 'سلمى رامي'),
    categoryId: 'piano',
    area: L('Zamalek', 'الزمالك'),
    rating: 4.6,
    reviewCount: 19,
    distanceKm: 5.6,
    pricePerSession: 450,
    yearsExperience: 10,
    ages: L('5–16 yrs', '5–16 سنة'),
    about: L(
      'Conservatoire graduate teaching piano from the very start up to grade exams.',
      'خريجة كونسرفتوار، تدرّس البيانو من البداية حتى امتحانات المستويات.',
    ),
    slots: [
      Slot(L('Wednesday', 'الأربعاء'), L('5 – 8 pm', '5 – 8 م')),
      Slot(L('Saturday', 'السبت'), L('11 am – 2 pm', '11 ص – 2 م')),
    ],
    areas: [L('Zamalek', 'الزمالك'), L('Mohandessin', 'المهندسين')],
    reviews: [
      Review(L("Mariam's mom", 'أم مريم'), 5, L('Very professional and organised.', 'محترفة جداً ومنظمة.')),
      Review(L("Karim's dad", 'أبو كريم'), 4, L('Excellent, though a bit pricey.', 'ممتازة بس السعر عالي شوية.')),
    ],
    color: Color(0xFF5B21B6),
  ),
];

Trainer trainerById(String id) => kTrainers.firstWhere((t) => t.id == id);

List<Booking> sampleBookings() => [
      Booking(
        id: 'b1',
        trainerId: 't1',
        childName: 'Youssef',
        childAge: 9,
        days: ['fri'],
        timeOfDay: 'evening',
        place: 'venue',
        area: 'Nasr City',
        notes: '',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: BookingStatus.alternativeOffered,
        alternativeTime: const L('Sat 5 pm instead of Fri evening', 'السبت 5 م بدلاً من الجمعة مساءً'),
      ),
      Booking(
        id: 'b2',
        trainerId: 't4',
        childName: 'Youssef',
        childAge: 9,
        days: ['sun', 'tue'],
        timeOfDay: 'afternoon',
        place: 'home',
        area: 'Nasr City',
        notes: '',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Booking(
        id: 'b3',
        trainerId: 't3',
        childName: 'Laila',
        childAge: 7,
        days: ['mon'],
        timeOfDay: 'evening',
        place: 'venue',
        area: 'Maadi',
        notes: '',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: BookingStatus.confirmed,
      ),
      Booking(
        id: 'b4',
        trainerId: 't5',
        childName: 'Laila',
        childAge: 7,
        days: ['wed'],
        timeOfDay: 'evening',
        place: 'home',
        area: 'Zamalek',
        notes: '',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: BookingStatus.declined,
      ),
    ];
