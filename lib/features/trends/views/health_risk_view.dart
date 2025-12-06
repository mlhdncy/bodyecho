import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/ml_service.dart';
import '../../../models/ml_prediction_model.dart';
import '../../../core/authentication/viewmodels/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../models/health_record_model.dart';
import '../../home/viewmodels/home_provider.dart';
import '../../../widgets/body_risk_map_widget.dart';

class HealthRiskView extends StatefulWidget {
  const HealthRiskView({super.key});

  @override
  State<HealthRiskView> createState() => _HealthRiskViewState();
}

class _HealthRiskViewState extends State<HealthRiskView>
    with SingleTickerProviderStateMixin {
  final _mlService = MlService();
  bool _isLoading = false;
  MlResponse? _response;
  late TabController _tabController;

  // Form controllers
  final _ageController = TextEditingController(text: '30');
  final _bmiController = TextEditingController(text: '25.0');
  final _glucoseController = TextEditingController(text: '100');
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getPredictions() async {
    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final age = int.tryParse(_ageController.text) ?? 30;
      final bmi = double.tryParse(_bmiController.text) ?? 25.0;
      final glucose = int.tryParse(_glucoseController.text) ?? 100;
      
      // 1. Verileri Firestore'a Kaydet (Anonim)
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.anonymousId;
      
      if (userId != null) {
        final firestoreService = FirestoreService();
        
        // Sağlık Kaydı Ekle
        await firestoreService.addHealthRecord(HealthRecordModel(
          userId: userId,
          bloodGlucoseLevel: glucose,
          // Diğer veriler de buraya eklenebilir (Tansiyon vb.)
        ));
        
        // Profil Güncelle (BMI için boy/kilo tahmini veya direkt giriş)
        // Not: Bu ekran sadece analiz içinse profil güncellemeyebiliriz,
        // ama "Sürekli Takip" istendiği için güncelliyoruz.
        await firestoreService.updateUserProfile(userId, {
          'age': age,
          'activityLevel': _isActive ? 'High' : 'Low',
          // BMI'dan boy/kilo çıkarmak zor, o yüzden şimdilik sadece bunları güncelliyoruz.
          // İdeal olan boy/kilo girişi almaktır.
        });
      }

      // 2. Tahmin Al
      final result = await _mlService.getPredictions(
        age: age,
        bmi: bmi,
        bloodGlucoseLevel: glucose,
        active: _isActive ? 1 : 0,
      );

      setState(() {
        _response = result;
      });
      
      // 3. Ana Ekranı Yenile (Insights güncellensin diye)
      if (mounted) {
         final homeProvider = context.read<HomeProvider>();
         if (userId != null) {
           homeProvider.loadData(userId, authProvider.currentUser);
         }
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sağlık Analizi'),
        bottom: _response != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.accessibility_new),
                    text: 'Vücut Haritası',
                  ),
                  Tab(
                    icon: Icon(Icons.list),
                    text: 'Liste',
                  ),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          // Input Section (Always visible at top)
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputSection(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getPredictions,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Analiz Et',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          // Results Section (Tabbed)
          if (_response != null)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Body Map View
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BodyRiskMapWidget(
                      riskResults: _response!.results,
                      isLoading: _isLoading,
                    ),
                  ),
                  // List View
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildResultsSection(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verileriniz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Yaş',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bmiController,
              decoration: const InputDecoration(
                labelText: 'Vücut Kitle İndeksi (BMI)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _glucoseController,
              decoration: const InputDecoration(
                labelText: 'Kan Şekeri',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bloodtype),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Aktif Yaşam Tarzı'),
              subtitle: const Text('Düzenli egzersiz yapıyor musunuz?'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
              secondary: const Icon(Icons.directions_run),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_response?.success == false) {
      return Center(
        child: Text(
          'Hata: ${_response?.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final results = _response!.results;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analiz Sonuçları',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildRiskCard(
          'Diyabet Riski',
          results['diabetes_risk'],
          Icons.water_drop,
        ),
        _buildRiskCard(
          'Obezite Riski',
          results['obesity_risk'],
          Icons.monitor_weight_outlined,
        ),
        _buildRiskCard(
          'Yüksek Şeker Riski',
          results['high_sugar_risk'],
          Icons.warning_amber,
        ),
        _buildRiskCard(
          'Kalp/Kolesterol Riski',
          results['high_cholesterol_risk'],
          Icons.favorite_border,
        ),
        _buildRiskCard(
          'Düşük Aktivite Riski',
          results['low_activity_risk'],
          Icons.directions_walk,
        ),
      ],
    );
  }

  Widget _buildRiskCard(String title, MlPredictionResult? result, IconData icon) {
    if (result == null) return const SizedBox.shrink();

    final isHighRisk = result.prediction == 1;
    final color = isHighRisk ? Colors.red : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          isHighRisk 
              ? 'Yüksek Risk (%${(result.probability * 100).toStringAsFixed(1)})' 
              : 'Düşük Risk',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: isHighRisk 
            ? const Icon(Icons.warning, color: Colors.red) 
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
}
