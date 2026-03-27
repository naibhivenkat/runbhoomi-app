import 'package:flutter/material.dart';

class LookingScreen extends StatefulWidget {
  const LookingScreen({super.key});

  @override
  State<LookingScreen> createState() => _LookingScreenState();
}

class _LookingScreenState extends State<LookingScreen> {
  bool isLoading = true;
  List posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 1));

    // 🔥 MOCK → replace with API
    posts = [
      {
        "name": "Ravi",
        "role": "All-rounder",
        "distance": "2 km",
        "time": "10 min ago",
        "desc": "Need 2 players for evening match",
        "tags": ["Tennis", "Friendly", "₹100"],
        "likes": 12,
        "comments": 4
      },
      {
        "name": "Arjun",
        "role": "Bowler",
        "distance": "5 km",
        "time": "30 min ago",
        "desc": "Box cricket match tonight",
        "tags": ["Box", "Night", "₹200"],
        "likes": 5,
        "comments": 2
      }
    ];

    setState(() => isLoading = false);
  }

  Future<void> refresh() async {
    setState(() => isLoading = true);
    await fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _Loading();

    if (posts.isEmpty) {
      return const Center(child: Text("No Posts Found"));
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _PostCard(post: posts[index]);
            },
          ),
        ),

        // 🔥 FILTER BAR
        Positioned(
          top: 10,
          left: 16,
          right: 16,
          child: _FilterBar(),
        ),
      ],
    );
  }
}

// ---------------- POST CARD ----------------
class _PostCard extends StatelessWidget {
  final Map post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${post['name']} (${post['role']})",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "${post['distance']} • ${post['time']}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert)
            ],
          ),

          const SizedBox(height: 12),

          Text(post['desc']),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: (post['tags'] as List)
                .map((t) => _Tag(text: t))
                .toList(),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _action(Icons.thumb_up_alt_outlined, post['likes'].toString()),
              const SizedBox(width: 16),
              _action(Icons.chat_bubble_outline,
                  post['comments'].toString()),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Join"),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _action(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

// ---------------- FILTER BAR ----------------
class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.tune, size: 18),
          SizedBox(width: 8),
          Text("Filters"),
          Spacer(),
          Icon(Icons.location_on_outlined, size: 18),
          SizedBox(width: 4),
          Text("Nearby"),
        ],
      ),
    );
  }
}

// ---------------- TAG ----------------
class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.green, fontSize: 12),
      ),
    );
  }
}

// ---------------- LOADING ----------------
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
