import 'package:flutter/material.dart';
import 'package:wink_chat/src/features/account/domain/user.dart';

class UserInfoBadges extends StatelessWidget {
  final String gender;
  final UserLocation location;

  const UserInfoBadges({
    super.key,
    required this.gender,
    required this.location,
  });

  String _getGenderDisplay(String gender) {
    return gender == 'M' ? 'Mężczyzna' : 'Kobieta';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gender Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(_getGenderDisplay(gender)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Location Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(location.value),
            ],
          ),
        ),
      ],
    );
  }
}
