import 'dart:async';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isLoading = true;
  List posts = [];

  bool _disposed = false; // ✅ lifecycle guard
  Timer? _fetchTimer; // ✅ track timer

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    _fetchTimer?.cancel();

    _fetchTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted || _disposed) return;

      // 🔥 MOCK DATA → replace with API
      posts = [
        {
          "user": "Rahul",
          "time": "2 hrs ago",
          "content": "Great match today! 🏏",
          "likes": 20,
          "comments": 5
        },
        {
          "user": "Suresh",
          "time": "5 hrs ago",
          "content": "Looking for weekend tournament players",
          "likes": 10,
          "comments": 2
        }
      ];

      if (!mounted || _disposed) return;

      setState(() => isLoading = false);
    });
  }

  Future<void> refresh() async {
    if (!mounted || _disposed) return;
    setState(() => isLoading = true);
    await fetchPosts();
  }

  @override
  void dispose() {
    _disposed = true;
    _fetchTimer?.cancel(); // ✅ cancel timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _Loading();

    if (posts.isEmpty) {
      return const Center(child: Text("No Community Posts"));
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _PostCard(post: posts[index]);
            },
          ),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        )
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
                    Text(post['user'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post['time'],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert)
            ],
          ),

          const SizedBox(height: 12),

          Text(post['content']),

          const SizedBox(height: 14),

          Row(
            children: [
              _action(Icons.thumb_up_alt_outlined,
                  post['likes'].toString()),
              const SizedBox(width: 16),
              _action(Icons.chat_bubble_outline,
                  post['comments'].toString()),
              const Spacer(),
              const Icon(Icons.share_outlined)
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