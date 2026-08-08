import 'package:flutter/material.dart';

import '../presentation/models/news_screen_models.dart';
import '../presentation/models/news_details_models.dart';
import '../../../core/constants/app_strings.dart';

const List<NewsCategoryChipData> newsCategoryChips = <NewsCategoryChipData>[
  NewsCategoryChipData(id: 'all', label: 'الكل', isSelected: true),
  NewsCategoryChipData(id: 'events', label: 'مهرجانات', isSelected: false),
  NewsCategoryChipData(id: 'urgent', label: 'تنبيهات', isSelected: false),
  NewsCategoryChipData(id: 'services', label: 'خدمات', isSelected: false),
  NewsCategoryChipData(id: 'electricity', label: 'خدمة عامّة', isSelected: false),
];

const List<NewsItemData> newsItems = <NewsItemData>[
  NewsItemData(
    id: 'urgent-water',
    type: NewsItemType.urgent,
    categories: <String>['all', 'urgent', 'services'],
    title: 'قطع مياه متوقّع',
    body: 'القيام بصيانة طارئة في شبكة المياه الرئيسية.\nفي حي الوادي',
    date: 'يوم الجمعة، 22 مايو 2026',
    detailsDescription:
        'البلدية ستُنفّذ أعمال صيانة عاجلة على خطوط المياه الرئيسية في حي الوادي. يُرجى الالتزام بالتعليمات ودعم فرق الصيانة لإعادة الخدمة بسرعة.',
    detailsMetaItems: <NewsDetailsMetaItem>[
      NewsDetailsMetaItem(icon: Icons.place, text: 'الموقع: حي الوادي'),
      NewsDetailsMetaItem(icon: Icons.access_time, text: 'التاريخ: 22 مايو 2026'),
    ],
    actionText: AppStrings.newsDetailsEnableAlert,
    buttonLabel: AppStrings.openMap,
  ),
  NewsItemData(
    id: 'info-electricity',
    type: NewsItemType.info,
    categories: <String>['all', 'electricity', 'services'],
    title: 'أعمال صيانة كهرباء في شارع الكورنيش',
    body: 'ورشاتنا تباشر في تبديل الكابلات في دخلة مدرسة باب بريد.',
    date: '24 مايو 2026',
    detailsDescription:
        'فرق الصيانة الكهربائية تعمل في شارع الكورنيش على تبديل الكابلات التالفة. يُرجى الانتباه إلى تحويلات المرور واحترام حدود السرعة الأمنية.',
    detailsMetaItems: <NewsDetailsMetaItem>[
      NewsDetailsMetaItem(icon: Icons.place, text: 'المكان: الكورنيش، دخلة مدرسة باب بريد'),
      NewsDetailsMetaItem(icon: Icons.access_time, text: 'التاريخ: 24 مايو 2026'),
    ],
    actionText: AppStrings.newsDetailsEnableAlert,
    status: 'ريف دمشق - داريا',
    buttonLabel: AppStrings.openMap,
  ),
  NewsItemData(
    id: 'event-spring',
    type: NewsItemType.event,
    categories: <String>['all', 'events'],
    title: 'مهرجان الربيع السنوي في حديقة تشرين',
    body: 'ترحب بكم البلدية لحضور فعالية المهرجان ومعرض الزهور والأنشطة الترفيهية للأطفال.',
    date: '24 مايو 2026',
    detailsDescription:
        'انضموا إلينا في مهرجان الربيع السنوي بحديقة تشرين، حيث الفعاليات العائلية والمعارض الفنية والمسابقات الترفيهية.',
    detailsMetaItems: <NewsDetailsMetaItem>[
      NewsDetailsMetaItem(icon: Icons.place, text: 'المكان: حديقة تشرين'),
      NewsDetailsMetaItem(icon: Icons.access_time, text: 'التاريخ: 24 مايو 2026'),
      NewsDetailsMetaItem(icon: Icons.people_outline, text: 'الحضور المتوقع: آلاف الزوار'),
    ],
    actionText: AppStrings.newsDetailsEnableAlert,
    imageUrl:
        'https://images.unsplash.com/photo-1461354464878-ad92f492a5a0?auto=format&fit=crop&w=1000&q=80',
  ),
];
