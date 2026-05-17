// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_quicknode_suppression.dart';

class QuickNodeResult {
  const QuickNodeResult({
    this.endpointId,
    this.chain,
    this.network,
    this.method,
    this.blockHeight,
    this.addonName,
    this.creditsUsed,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? endpointId;
  final String? chain;
  final String? network;
  final String? method;
  final int? blockHeight;
  final String? addonName;
  final int? creditsUsed;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class QuickNodeCallResult<T> {
  const QuickNodeCallResult({required this.value, this.result});
  final T value;
  final QuickNodeResult? result;
}

Future<T> tracedQuickNode<T>({
  required String operation,
  required Future<QuickNodeCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (quickNodeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_quicknode');
  final span = t.startSpan('quicknode $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'quicknode');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.endpointId != null) {
        span.setStringAttribute('quicknode.endpoint.id', res.endpointId!);
      }
      if (res.chain != null) {
        span.setStringAttribute('quicknode.chain', res.chain!);
      }
      if (res.network != null) {
        span.setStringAttribute('quicknode.network', res.network!);
      }
      if (res.method != null) {
        span.setStringAttribute('quicknode.method', res.method!);
      }
      if (res.blockHeight != null) {
        span.setIntAttribute('quicknode.block.height', res.blockHeight!);
      }
      if (res.addonName != null) {
        span.setStringAttribute('quicknode.addon', res.addonName!);
      }
      if (res.creditsUsed != null) {
        span.setIntAttribute('quicknode.credits', res.creditsUsed!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('quicknode.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'quicknode.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
