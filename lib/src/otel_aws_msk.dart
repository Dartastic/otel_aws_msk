// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_msk_suppression.dart';

class AwsMSKResult {
  const AwsMSKResult({
    this.clusterName,
    this.clusterArn,
    this.topic,
    this.partition,
    this.broker,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? clusterName;
  final String? clusterArn;
  final String? topic;
  final int? partition;
  final String? broker;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsMSKCallResult<T> {
  const AwsMSKCallResult({required this.value, this.result});
  final T value;
  final AwsMSKResult? result;
}

Future<T> tracedAwsMSK<T>({
  required String operation,
  required Future<AwsMSKCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsMSKInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_msk');
  final span = t.startSpan('msk $operation', kind: SpanKind.producer);
  try {
    span.setStringAttribute('messaging.system', 'kafka');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.clusterName != null) {
        span.setStringAttribute('aws.msk.cluster.name', res.clusterName!);
      }
      if (res.clusterArn != null) {
        span.setStringAttribute('aws.msk.cluster.arn', res.clusterArn!);
      }
      if (res.topic != null) {
        span.setStringAttribute('messaging.destination.name', res.topic!);
      }
      if (res.partition != null) {
        span.setIntAttribute(
          'messaging.kafka.destination.partition',
          res.partition!,
        );
      }
      if (res.broker != null) {
        span.setStringAttribute('server.address', res.broker!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('msk.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'msk.error',
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
