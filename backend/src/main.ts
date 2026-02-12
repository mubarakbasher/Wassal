import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

// Handle uncaught exceptions from node-routeros library
// The library throws errors via event emitters that bypass try-catch
process.on('uncaughtException', (error) => {
  const errno = (error as any).errno || '';
  const message = error.message || '';

  // Check if it's a known node-routeros error that shouldn't crash the server
  const isKnownRouterosError =
    errno === 'UNKNOWNREPLY' || errno === 'SOCKTMOUT' || errno === 'ECONNRESET' || errno === 'ECONNREFUSED' ||
    message.includes('!empty') || message.includes('Timed out');

  if (isKnownRouterosError) {
    console.warn(`[MikroTik] Caught ${errno || 'error'}: ${message.substring(0, 60)} - ignoring`);
    return; // Don't crash the server
  }

  // For other uncaught exceptions, log and exit
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  // Check if it's the known node-routeros !empty reply bug
  if (String(reason).includes('!empty') || String(reason).includes('UNKNOWNREPLY')) {
    console.warn('[MikroTik] Caught !empty reply rejection - ignoring');
    return;
  }

  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global validation pipe - validates all incoming DTOs automatically
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,           // Strip properties not in DTO
      forbidNonWhitelisted: true, // Throw error if unknown properties sent
      transform: true,           // Auto-transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // Convert query string types automatically
      },
    }),
  );

  // Enable CORS for admin dashboard and mobile app
  app.enableCors({
    origin: true, // Allow all origins in development
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  // Swagger API Documentation
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Wassal API')
    .setDescription('MikroTik Hotspot Management System API')
    .setVersion('1.0')
    .addBearerAuth(
      { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      'JWT',
    )
    .addTag('Auth', 'User authentication endpoints')
    .addTag('Routers', 'MikroTik router management')
    .addTag('Vouchers', 'Hotspot voucher management')
    .addTag('Profiles', 'Hotspot profile management')
    .addTag('Sessions', 'Active session management')
    .addTag('Sales', 'Sales analytics')
    .addTag('Admin', 'Admin panel endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT ?? 3001;
  await app.listen(port, '0.0.0.0');
  console.log(`Application is running on: ${await app.getUrl()}`);
  console.log(`Swagger docs available at: ${await app.getUrl()}/api/docs`);
}
bootstrap();

