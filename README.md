# otel_aws_msk

Dartastic OpenTelemetry bridge for AWS MSK (managed Kafka).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_msk/otel_aws_msk.dart';

await tracedAwsMSK<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsMSKCallResult(value: r, result: AwsMSKResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsMSKInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
