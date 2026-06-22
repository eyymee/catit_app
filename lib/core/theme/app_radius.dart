import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double small = 4;
  static const double medium = 8;
  static const double large = 12;
  static const double extraLarge = 16;
  static const double card = 16;
  static const double pill = 9999;

  static BorderRadius get smallBR => BorderRadius.circular(small);
  static BorderRadius get mediumBR => BorderRadius.circular(medium);
  static BorderRadius get largeBR => BorderRadius.circular(large);
  static BorderRadius get extraLargeBR => BorderRadius.circular(extraLarge);
  static BorderRadius get cardBR => BorderRadius.circular(card);
  static BorderRadius get pillBR => BorderRadius.circular(pill);
}
