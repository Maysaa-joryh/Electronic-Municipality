import 'news_mock.dart';
import '../presentation/models/news_screen_models.dart';

class NewsRepository {
  const NewsRepository();

  List<NewsCategoryChipData> getCategories() {
    return newsCategoryChips
        .map((e) => NewsCategoryChipData(id: e.id, label: e.label, isSelected: e.isSelected))
        .toList(growable: false);
  }

  List<NewsItemData> getNewsItems() {
    return newsItems;
  }
}
