# otel_quicknode

Dartastic OpenTelemetry bridge for QuickNode (multi-chain RPC + indexing).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_quicknode/otel_quicknode.dart';

await tracedQuickNode<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return QuickNodeCallResult(value: r, result: QuickNodeResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutQuickNodeInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
