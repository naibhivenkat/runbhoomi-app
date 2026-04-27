import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddPlayerScreen extends StatefulWidget {
  final int teamId;

  const AddPlayerScreen({super.key, required this.teamId});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final TextEditingController controller = TextEditingController();

  List players = [];
  bool isLoading = false;
  String query = "";

  Timer? _debounce;

  ////////////////////////////////////////////////////////////
  /// 🔍 SEARCH
  ////////////////////////////////////////////////////////////
  void onSearchChanged(String value) {
    query = value;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      if (value.trim().isEmpty) {
        setState(() => players = []);
        return;
      }

      setState(() => isLoading = true);

      try {
        final res =
            await ApiService.searchPlayers(value, widget.teamId);

        if (!mounted) return;

        setState(() {
          players = res;
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    });
  }

  ////////////////////////////////////////////////////////////
  /// ADD PLAYER
  ////////////////////////////////////////////////////////////
  Future<void> addExistingPlayer(int playerId, bool already) async {
    if (already) {
      showError("Player already added");
      return;
    }

    try {
      await ApiService.addPlayerToTeam(widget.teamId, playerId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      showError("Failed to add player");
    }
  }

  ////////////////////////////////////////////////////////////
  /// QUICK ADD
  ////////////////////////////////////////////////////////////
  Future<void> quickAddPlayer(String input) async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final isPhone = RegExp(r'^\d{10}$').hasMatch(input);

      final newPlayer = await ApiService.quickAddPlayer(
        name: isPhone ? "Player $input" : input,
        phone: isPhone ? input : null,
      );

      await ApiService.addPlayerToTeam(
        widget.teamId,
        newPlayer["id"],
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      showError("Quick add failed");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  ////////////////////////////////////////////////////////////
  /// PLAYER TILE
  ////////////////////////////////////////////////////////////
  Widget buildPlayerTile(dynamic p) {
    final name = p["name"] ?? "Player";
    final phone = p["phone"] ?? "";
    final email = p["email"] ?? "";
    final already = p["already_added"] == true;

    return ListTile(
      leading: CircleAvatar(child: Text(name[0])),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phone.isNotEmpty) Text(phone),
          if (email.isNotEmpty) Text(email),
        ],
      ),
      trailing: already
          ? const Chip(
              label: Text("ADDED"),
              backgroundColor: Colors.grey,
            )
          : const Icon(Icons.add, color: Colors.green),
      onTap: () => addExistingPlayer(p["id"], already),
    );
  }

  ////////////////////////////////////////////////////////////
  /// QUICK ADD TILE
  ////////////////////////////////////////////////////////////
  Widget buildQuickAdd() {
    return ListTile(
      leading: const Icon(Icons.flash_on, color: Colors.orange),
      title: Text('Add "$query"'),
      onTap: () => quickAddPlayer(query),
    );
  }

  ////////////////////////////////////////////////////////////
  /// DISPOSE (🔥 FIXED)
  ////////////////////////////////////////////////////////////
  @override
  void dispose() {
    _debounce?.cancel();      // ✅ FIX: cancel timer
    controller.dispose();     // ✅ good practice
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Player")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search name / phone / email",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : players.isEmpty
                    ? buildQuickAdd()
                    : ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (_, i) =>
                            buildPlayerTile(players[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

