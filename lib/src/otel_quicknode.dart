// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'quicknode')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.endpointId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('quicknode.endpoint.id', res.endpointId!)]));
      }
      if (res.chain != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('quicknode.chain', res.chain!)]));
      }
      if (res.network != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('quicknode.network', res.network!)]));
      }
      if (res.method != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('quicknode.method', res.method!)]));
      }
      if (res.blockHeight != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('quicknode.block.height', res.blockHeight!)]));
      }
      if (res.addonName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('quicknode.addon', res.addonName!)]));
      }
      if (res.creditsUsed != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('quicknode.credits', res.creditsUsed!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('quicknode.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'quicknode.error',
          )
        ]));
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
