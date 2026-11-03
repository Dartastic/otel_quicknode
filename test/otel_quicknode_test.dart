// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_quicknode/otel_quicknode.dart';
import 'package:test/test.dart';

void main() {
  group('otel_quicknode', () {
    test('suppression toggles in zone', () async {
      expect(quickNodeInstrumentationSuppressed(), isFalse);
      await runWithoutQuickNodeInstrumentationAsync(() async {
        expect(quickNodeInstrumentationSuppressed(), isTrue);
      });
      expect(quickNodeInstrumentationSuppressed(), isFalse);
    });

    test('QuickNodeResult fields default null', () {
      const r = QuickNodeResult();
      expect(r.statusCode, isNull);
    });
  });
}
