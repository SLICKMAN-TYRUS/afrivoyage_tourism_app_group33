import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides English [MaterialLocalizations] for any locale not covered
/// by [GlobalMaterialLocalizations] (e.g. Kinyarwanda).
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
          const DefaultMaterialLocalizations());

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Provides English [CupertinoLocalizations] for any locale not covered
/// by [GlobalCupertinoLocalizations] (e.g. Kinyarwanda).
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
          const DefaultCupertinoLocalizations());

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
