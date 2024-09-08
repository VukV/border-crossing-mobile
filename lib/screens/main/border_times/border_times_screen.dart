import 'package:border_crossing_mobile/widgets/border_analytics_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/border/border_analytics.dart';
import 'package:border_crossing_mobile/models/border/border_crossing.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/border_crossing_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:border_crossing_mobile/widgets/bc_button.dart';
import 'package:border_crossing_mobile/widgets/border_time_widget.dart';
import 'package:border_crossing_mobile/widgets/empty_state_widget.dart';
import 'package:border_crossing_mobile/widgets/manual_crossing_popup.dart';

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CrossingPopup(
          borderId: widget.border.id,
          onCallback: _refreshData,
        );
      },
    );
  }

  Future<void> _refreshData() async {
    await _loadBorderData();
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
          style: const TextStyle(color: Colors.white),
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
                  onPressed: _addNewWaitingTime,
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
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                          onRefresh: _refreshData,
                          child: _recentCrossings.isEmpty
                              ? const Center(child: EmptyStateWidget(passedText: 'recent crossings'),)
                              : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                            itemCount: _recentCrossings.length,
                            itemBuilder: (context, index) {
                              final crossing = _recentCrossings[index];
                              return BorderTimeWidget(borderCrossing: crossing);
                            },
                          ),
                        ),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _borderAnalytics == null
                            ? const Center(child: EmptyStateWidget(passedText: 'statistics'))
                            : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16.0),
                              Text(
                                'Averages',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[800],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Today',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          '${_borderAnalytics!.averageToday} minutes',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 16.0,
                                    thickness: 1.0,
                                    color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'This Week',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          '${_borderAnalytics!.averageWeek} minutes',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 16.0,
                                    thickness: 1.0,
                                    color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'This Month',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          '${_borderAnalytics!.averageMonth} minutes',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[400]!),
                                    bottom: BorderSide(color: Colors.grey[400]!),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Average for Arrivals in Current Hour:   ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple[700],
                                      ),
                                    ),
                                    Text(
                                      '${_borderAnalytics!.averageCurrentHour} minutes',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                )
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Average Waiting Times by Hour',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Center(
                                  child: BorderAnalyticsChart(
                                    averageByHour: _borderAnalytics!.averageByHour,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
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
