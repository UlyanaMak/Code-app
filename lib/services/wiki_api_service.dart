//Интерфейс
import '../models/lab.dart';

abstract class WikiApiService {
  Future<List<Lab>> getLabs();
  Future<Lab> getLabBySlug(String slug);
  String getAssetUrl(String assetPath); // для построения URL картинок
}