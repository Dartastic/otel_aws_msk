// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_msk/otel_aws_msk.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_msk', () {
    test('suppression toggles in zone', () async {
      expect(awsMSKInstrumentationSuppressed(), isFalse);
      await runWithoutAwsMSKInstrumentationAsync(() async {
        expect(awsMSKInstrumentationSuppressed(), isTrue);
      });
      expect(awsMSKInstrumentationSuppressed(), isFalse);
    });

    test('AwsMSKResult fields default null', () {
      const r = AwsMSKResult();
      expect(r.statusCode, isNull);
    });
  });
}
