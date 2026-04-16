import '../../domain/entities/fish_species.dart';
import '../../domain/repositories/fish_repository.dart';

/// Şimdilik sabit liste; sonra SQLite veya API ile değiştirilebilir.
class FishRepositoryImpl implements FishRepository {
  static final List<FishSpecies> _mock = [
    const FishSpecies(
      id: 'clownfish',
      name: 'Palyaço balığı',
      scientificName: 'Amphiprioninae',
      shortDescription:
          'Mercan resiflerinde yaşayan, turuncu ve beyaz çizgili küçük balıklar.',
    ),
    const FishSpecies(
      id: 'shark',
      name: 'Köpekbalığı',
      scientificName: 'Selachimorpha',
      shortDescription:
          'Kıkırdak iskeletli, çoğunlukla etobur büyük deniz balıkları.',
    ),
    const FishSpecies(
      id: 'betta',
      name: 'Betta (Siyam dövüşçüsü)',
      scientificName: 'Betta splendens',
      shortDescription:
          'Tatlı su akvaryumlarında popüler, canlı renkli yüzgeçlere sahip tür.',
    ),
  ];

  @override
  Future<List<FishSpecies>> getAllSpecies() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<FishSpecies>.from(_mock);
  }
}
