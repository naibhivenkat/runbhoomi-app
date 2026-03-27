import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../match/match_detail_screen.dart';

////////////////////////////////////////////////////////////
/// 🎨 PREMIUM COLOR SYSTEM
////////////////////////////////////////////////////////////

class AppColors {
  static const primary = Color(0xFF0F172A);
  static const accent = Color(0xFF16A34A);
  static const live = Color(0xFFDC2626);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const card = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF1F5F9);
}

////////////////////////////////////////////////////////////
/// 🏠 HOME SCREEN
////////////////////////////////////////////////////////////

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List matches = [];
  bool loading = true;

  final PageController pageController =
      PageController(viewportFraction: 0.88);

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    try {
      final email = await SessionService.getEmail();
      if (email == null) return;

      final data = await ApiService.getMatches(email);

      setState(() {
        matches = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List filter(String type) {
    return matches.where((m) {
      final status = (m["status"] ?? "").toString().toLowerCase();
      if (type == "live") return status == "live";
      if (type == "completed") return status == "completed";
      return status == "upcoming";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bg,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "RunBhoomi",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Live"),
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
            ],
          ),
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildHorizontal(filter("live")),
                  _buildHorizontal(filter("upcoming")),
                  _buildHorizontal(filter("completed")),
                ],
              ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 HORIZONTAL CAROUSEL
  ////////////////////////////////////////////////////////////

  Widget _buildHorizontal(List list) {
    if (list.isEmpty) {
      return const Center(child: Text("No matches"));
    }

    return Column(
      children: [
        const SizedBox(height: 12),

        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                child: MatchTile(match: list[index]),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            list.length,
            (index) => Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 3),
              width: currentPage == index ? 8 : 6,
              height: currentPage == index ? 8 : 6,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? AppColors.accent
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// 🏏 MATCH TILE (PRODUCTION LEVEL)
////////////////////////////////////////////////////////////

class MatchTile extends StatefulWidget {
  final Map match;
  const MatchTile({super.key, required this.match});

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile>
    with SingleTickerProviderStateMixin {
  late AnimationController blinkController;

  @override
  void initState() {
    super.initState();
    blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final isLive =
        (match["status"] ?? "").toString().toLowerCase() == "live";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            )
          ],
          border: Border.all(
            color: isLive
                ? AppColors.live.withOpacity(0.25)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match["league"] ?? "Match",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isLive)
                  FadeTransition(
                    opacity: blinkController,
                    child: const Text(
                      "LIVE",
                      style: TextStyle(
                        color: AppColors.live,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 10),

            _teamRow(match["teamA"], match["scoreA"],
                match["teamA_logo"], true),

            const SizedBox(height: 8),

            _teamRow(match["teamB"], match["scoreB"],
                match["teamB_logo"], false),

            const SizedBox(height: 10),

            Divider(color: Colors.grey.shade200),

            const SizedBox(height: 6),
            _commentaryBar(match["note"] ?? "")
          ],
        ),
      ),
    );
  }

  Widget _commentaryBar(String text) {
  if (text.isEmpty) return const SizedBox();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF59D), // light yellow
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        const Icon(Icons.campaign, size: 14, color: Colors.black87),
        const SizedBox(width: 6),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

  ////////////////////////////////////////////////////////////
  /// TEAM ROW
  ////////////////////////////////////////////////////////////

  Widget _teamRow(
      String? name, String? score, String? logo, bool bold) {
    return Row(
      children: [
        _logo(logo, name),
        const SizedBox(width: 10),

        Expanded(
          child: Text(
            name ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  bold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        Text(
          score ?? "",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////
  /// LOGO
  ////////////////////////////////////////////////////////////

  Widget _logo(String? logo, String? name) {
    if (logo != null && logo.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(logo),
      );
    }

    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.accent.withOpacity(0.1),
      child: Text(
        (name ?? "T")[0],
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}