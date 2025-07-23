// screens/age_group_engine.dart

import 'dart:ui';
import 'package:flutter/material.dart';

enum AgeGroup { genz, millennial, elderly }

class AgeGroupProfile {
  final String type;
  final String displayName;
  final String ageRange;
  final List<String> commonGoals;
  final List<String> typicalChallenges;
  final List<String> preferredFeatures;
  final UITheme uiTheme;
  final CommunicationTone communicationTone;

  AgeGroupProfile({
    required this.type,
    required this.displayName,
    required this.ageRange,
    required this.commonGoals,
    required this.typicalChallenges,
    required this.preferredFeatures,
    required this.uiTheme,
    required this.communicationTone,
  });
}

class UITheme {
  final List<Color> primaryGradient;
  final List<Color> accentGradient;
  final List<Color> backgroundGradient;
  final String fontStyle;
  final BorderRadius componentBorderRadius;

  UITheme({
    required this.primaryGradient,
    required this.accentGradient,
    required this.backgroundGradient,
    required this.fontStyle,
    required this.componentBorderRadius,
  });
}

class CommunicationTone {
  final String formality;
  final bool emoji;
  final bool slang;
  final String encouragementStyle;

  CommunicationTone({
    required this.formality,
    required this.emoji,
    required this.slang,
    required this.encouragementStyle,
  });
}

AgeGroup assignAgeGroup(int age) {
  if (age >= 18 && age <= 27) return AgeGroup.genz;
  if (age >= 28 && age <= 43) return AgeGroup.millennial;
  return AgeGroup.elderly;
}

Map<AgeGroup, AgeGroupProfile> ageGroupProfiles = {
  AgeGroup.genz: AgeGroupProfile(
    type: 'genz',
    displayName: 'Gen Z Financial Explorer',
    ageRange: '18-27',
    commonGoals: ['debt', 'emergency_fund', 'travel', 'education'],
    typicalChallenges: ['Student loans', 'First job income', 'Living with parents', 'FOMO spending'],
    preferredFeatures: ['Visual learning', 'Gamification', 'Social features', 'Mobile-first'],
    uiTheme: UITheme(
      primaryGradient: [Color(0xFF9F7AEA), Color(0xFFED64A6)],
      accentGradient: [Color(0xFFF6E05E), Color(0xFFED8936)],
      backgroundGradient: [Color(0xFFF3E8FF), Color(0xFFFFE4E6), Color(0xFFFFF9C4)],
      fontStyle: 'modern',
      componentBorderRadius: BorderRadius.circular(24),
    ),
    communicationTone: CommunicationTone(
      formality: 'casual',
      emoji: true,
      slang: true,
      encouragementStyle: 'hype',
    ),
  ),
  AgeGroup.millennial: AgeGroupProfile(
    type: 'millennial',
    displayName: 'Millennial Wealth Builder',
    ageRange: '28-43',
    commonGoals: ['house', 'retirement', 'emergency_fund', 'business'],
    typicalChallenges: ['Career growth', 'Family planning', 'Housing costs', 'Work-life balance'],
    preferredFeatures: ['Goal tracking', 'Investment advice', 'Family planning', 'Career tools'],
    uiTheme: UITheme(
      primaryGradient: [Color(0xFF4299E1), Color(0xFF667EEA)],
      accentGradient: [Color(0xFF68D391), Color(0xFF63B3ED)],
      backgroundGradient: [Color(0xFFEBF8FF), Color(0xFFE6FFFA), Color(0xFFEDF2F7)],
      fontStyle: 'professional',
      componentBorderRadius: BorderRadius.circular(20),
    ),
    communicationTone: CommunicationTone(
      formality: 'professional',
      emoji: false,
      slang: false,
      encouragementStyle: 'motivational',
    ),
  ),
  AgeGroup.elderly: AgeGroupProfile(
    type: 'elderly',
    displayName: 'Wise Money Manager',
    ageRange: '44+',
    commonGoals: ['retirement', 'emergency_fund', 'education', 'travel'],
    typicalChallenges: ['Retirement planning', 'Healthcare costs', 'Technology adoption', 'Fixed income'],
    preferredFeatures: ['Simple interface', 'Clear explanations', 'Safety focus', 'Voice support'],
    uiTheme: UITheme(
      primaryGradient: [Color(0xFF38A169), Color(0xFF319795)],
      accentGradient: [Color(0xFFF6AD55), Color(0xFFED8936)],
      backgroundGradient: [Color(0xFFE6FFFA), Color(0xFFE0F2F1), Color(0xFFE3F2FD)],
      fontStyle: 'traditional',
      componentBorderRadius: BorderRadius.circular(16),
    ),
    communicationTone: CommunicationTone(
      formality: 'professional',
      emoji: false,
      slang: false,
      encouragementStyle: 'supportive',
    ),
  ),
};

AgeGroupProfile getAgeGroupProfile(AgeGroup group) {
  return ageGroupProfiles[group]!;
}
