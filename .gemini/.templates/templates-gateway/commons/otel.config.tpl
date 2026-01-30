import { Module, Global } from '@nestjs/common';
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { resourceFromAttributes } from '@opentelemetry/resources';

@Global()
@Module({})
export class OpenTelemetryConfig {
  private static sdk: NodeSDK;

  static async initialize() {
    this.sdk = new NodeSDK({
      resource: resourceFromAttributes({
        'service.name': 'bcs-breb-api-gateway',
        'service.namespace': 'bcs-breb',
      }),
      traceExporter: new OTLPTraceExporter({
        url: process.env.GRAFANAURLTRACES,
        headers: {},
      }),
      instrumentations: [getNodeAutoInstrumentations()],
    });

    this.sdk.start();
    console.log('OpenTelemetry SDK initialized');
  }
}
