// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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
