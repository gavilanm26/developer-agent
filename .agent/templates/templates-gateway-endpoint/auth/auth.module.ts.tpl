import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import jwtConfig from './domain/jwt.config';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './infrastructure/adapters/inbound/http/auth.controller';
import { AuthUsecase } from './application/ports/auth.usecase';
import { JwtAuthService } from './application/jwt-auth.service';
import { Validate } from './application/use-case/validate';
import { TokenUsecase } from './application/ports/token.usecase';
import { TokenGuard } from './infrastructure/adapters/inbound/http/security/service/token.guard';
import { JwtAuthGuard } from './infrastructure/adapters/inbound/http/security/guard/auth.guard';
import { JwtStrategy } from './infrastructure/adapters/inbound/http/security/strategy/jwt.strategy';
import { MsIdentityAuthRestClient } from './infrastructure/adapters/outbound/clients/ms-identity-auth.rest.client';
import { HttpModule } from '@nestjs/axios';
import { TokenKycService } from './application/token-kyc-service.service';
import { Algorithm } from 'jsonwebtoken';

@Module({
  imports: [
    JwtModule.register({
      privateKey: jwtConfig.privateKey,
      publicKey: jwtConfig.publicKey,
      signOptions: {
        expiresIn: jwtConfig.expiresIn as any,
        algorithm: jwtConfig.algorithm as Algorithm,
      },
    }),
    PassportModule,
    HttpModule,
  ],
  providers: [
    Validate,
    JwtAuthGuard,
    JwtStrategy,
    MsIdentityAuthRestClient,
    TokenKycService,
    { provide: AuthUsecase, useClass: JwtAuthService },
    { provide: TokenUsecase, useClass: TokenGuard },
  ],
  controllers: [AuthController],
  exports: [JwtAuthGuard, JwtStrategy, TokenKycService],
})
export class AuthModule {}
