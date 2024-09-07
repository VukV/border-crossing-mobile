import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/border/border_analytics.dart';
import 'package:border_crossing_mobile/models/border/border_crossing.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/border_crossing_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:border_crossing_mobile/widgets/bc_button.dart';
import 'package:border_crossing_mobile/widgets/border_time_widget.dart'; // Import your custom widget
import 'package:flutter/material.dart';

class BorderTimesScreen extends StatefulWidget {
  final BorderCheckpoint border;

  const BorderTimesScreen({super.key, required this.border});

  @override
  State<BorderTimesScreen> createState() => _BorderTimesScreenState();
}

class _BorderTimesScreenState extends State<BorderTimesScreen> {
  final BorderCrossingService _borderCrossingService = BorderCrossingService();
  List<BorderCrossing> _recentCrossings = [];
  BorderAnalytics? _borderAnalytics = null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBorderData();
  }

  Future<void> _loadBorderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recentCrossings = await _borderCrossingService.getRecentCrossings(widget.border.id);
      final analytics = await _borderCrossingService.getBorderAnalytics(widget.border.id);

      if (analytics != null) {
        setState(() {
          _borderAnalytics = analytics;
        });
      }
      if (recentCrossings != null) {
        setState(() {
          _recentCrossings = recentCrossings;
        });
      }
    } catch (e) {
      if (e is BCError) {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, e.message);
        }
      } else {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, 'An unknown error occurred.');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addNewWaitingTime() {
    // For now, just print something to the console
    print('Add new waiting time button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.border.name,
          style: const TextStyle(
              color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '${widget.border.countryFrom.name.toUpperCase()} ➔ ${widget.border.countryTo.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'View details of crossings and statistics for this border.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.deepPurple[700],
                  ),
                ),
                const SizedBox(height: 8.0),
                BCButton(
                    text: 'Add New Waiting Time',
                    onPressed: _addNewWaitingTime
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.deepPurple,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(text: 'Recent Crossings'),
                      Tab(text: 'Statistics'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Content for Recent Crossings tab
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _recentCrossings.isEmpty
                            ? Center(
                          child: Text(
                            'No recent crossings',
                            style: TextStyle(fontSize: 16.0, color: Colors.deepPurple[700]),
                          ),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
                          itemCount: _recentCrossings.length,
                          itemBuilder: (context, index) {
                            final crossing = _recentCrossings[index];
                            return BorderTimeWidget(borderCrossing: crossing);
                          },
                        ),
                        // Content for Statistics tab
                        Center(
                          child: Text(
                            'Statistics Content',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
