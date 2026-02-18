import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import jwtConfig from './domain/jwt.config';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './infrastructure/controller/auth.controller';
import { AuthService } from './domain/auth.service';
import { JwtAuthService } from './application/jwt-auth.service';
import { Validate } from './application/use-case/validate';
import { TokenService } from './domain/token.service';
import { TokenGuard } from './infrastructure/service/token.guard';
import { JwtAuthGuard } from './infrastructure/guard/auth.guard';
import { JwtStrategy } from './infrastructure/strategy/jwt.strategy';
import { MsIdentityAuth } from './infrastructure/adapter/ms-identity-auth';
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
    MsIdentityAuth,
    TokenKycService,
    { provide: AuthService, useClass: JwtAuthService },
    { provide: TokenService, useClass: TokenGuard },
  ],
  controllers: [AuthController],
  exports: [JwtAuthGuard, JwtStrategy, TokenKycService],
})
export class AuthModule {}