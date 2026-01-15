List<Map<String, dynamic>> sortByMembership(
  List<Map<String, dynamic>> results,
) {
  // Liste simulée des shops abonnés (viendra plus tard de ton backend)
  const memberShops = {
    "Nike Store",
    "Foot Locker",
    "Decathlon",
    "JD Sports",
    "Sneaker World",
  };

  bool isMember(String? shopName) {
    if (shopName == null) return false;
    return memberShops.contains(shopName);
  }

  // Ajoute le flag isMember
  for (final item in results) {
    item['isMember'] = isMember(item['shopName']);
  }

  // Tri: membres d'abord
  results.sort((a, b) {
    final aMember = a['isMember'] == true ? 1 : 0;
    final bMember = b['isMember'] == true ? 1 : 0;
    return bMember.compareTo(aMember);
  });

  return results;
}
