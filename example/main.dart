// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_quicknode/otel_quicknode.dart';

/// Traces Quicknode calls with OpenTelemetry.
///
/// `otel_quicknode` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Quicknode call in
/// [tracedQuickNode]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'quicknode-example');

  // Traces a Quicknode call.
  final quickNodeId = await tracedQuickNode<String>(
    operation: 'create',
    invoke: () async {
      // Make the Quicknode call here, then report what it returned.
      const id = 'quicknode_8f3a2c';
      return const QuickNodeCallResult(
          value: id,
          result: QuickNodeResult(
              endpointId: 'endpoint_8f3a2c',
              chain: 'example',
              network: 'example',
              method: 'POST',
              blockHeight: 1,
              addonName: 'example',
              creditsUsed: 1,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedQuickNode create returned $quickNodeId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutQuickNodeInstrumentationAsync.
  await runWithoutQuickNodeInstrumentationAsync(
    () => tracedQuickNode<String>(
      operation: 'create',
      invoke: () async {
        const id = 'quicknode_8f3a2c';
        return const QuickNodeCallResult(
            value: id,
            result: QuickNodeResult(
                endpointId: 'endpoint_8f3a2c',
                chain: 'example',
                network: 'example',
                method: 'POST',
                blockHeight: 1,
                addonName: 'example',
                creditsUsed: 1,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
