import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import * as jwt from 'jsonwebtoken';
import jwtConfig from '../../domain/jwt.config';
import * as process from 'process';
import Crypto from '../../../../commons/crypto/crypto';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  private readonly logger = new Logger(JwtAuthGuard.name);
  private readonly urlHttpHeaders =
    process.env.APIURLIDENTITYMANAGEMENT ||
    'ERROR APIURLIDENTITYMANAGEMENT NOT FOUND';
  private readonly version = '/v1';

  constructor(private readonly httpService: HttpService) {
    super();
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractJwtToken(request);

    if (!token) {
      throw new UnauthorizedException();
    }

    try {
      jwt.verify(token, jwtConfig.publicKey, {
        algorithms: [jwtConfig.algorithm],
      });
    } catch (err) {
      this.logger.error('Error al verificar el token JWT', err.stack);
      throw new UnauthorizedException();
    }

    if (!request?.body?.data) {
      return request;
    }

    const tokenData = this.getDecodedTokenData(token);
    if (!tokenData) {
      this.logger.warn('No se pudo desencriptar el token');
      throw new UnauthorizedException();
    }

    const bodyDocumentNumber = this.getDocumentNumberFromBody(request);
    const tokenDocumentNumber = tokenData?.documentNumber;
    const processId = tokenData?.processId;

    if (bodyDocumentNumber !== tokenDocumentNumber) {
      const errorMsg = `Los documentos no coinciden. Body: ${bodyDocumentNumber}, Token: ${tokenDocumentNumber}`;
      this.logger.warn(errorMsg);
      throw new UnauthorizedException();
    }

    const isValid = await this.validateTokenWithService(processId);

    if (isValid) {
      return request;
    }

    this.logger.warn(`Validación fallida.`);
    throw new UnauthorizedException();
  }

  private extractJwtToken(request: {
    headers: { authorization: string };
  }): string | null {
    const auth = request.headers.authorization;
    if (auth) {
      const parts = auth.split(' ');
      return parts[1];
    }
    return null;
  }

  private getDocumentNumberFromBody(request: {
    body: { data: string };
  }): string | null {
    try {
      const decrypted = Crypto.decrypt(request.body.data);
      const body =
        typeof decrypted === 'string' ? JSON.parse(decrypted) : decrypted;

      return body?.documentNumber || body?.userData?.documentNumber || null;
    } catch (err) {
      this.logger.error(
        'Error al desencriptar o parsear body.data',
        err instanceof Error ? err.stack : `${err}`,
      );
      return null;
    }
  }

  private getDecodedTokenData(token: string): any {
    try {
      const decoded: any = jwt.decode(token);
      if (!decoded?.data) return null;

      const decryptedPayloadRaw = Crypto.decrypt(
        decoded.data,
        process.env.APPENCRYPTJWT,
      );
      return JSON.parse(decryptedPayloadRaw);
    } catch (err) {
      this.logger.error(
        'Error al desencriptar o decodificar el token',
        err instanceof Error ? err.stack : `${err}`,
      );
      return null;
    }
  }

  private async validateTokenWithService(processId: any): Promise<boolean> {
    const processIdValue =
      typeof processId === 'object' && processId !== null
        ? processId.consecutive
        : processId;

    try {
      const response = await firstValueFrom(
        this.httpService.get(
          `${this.urlHttpHeaders}${this.version}/redis/${processIdValue}`,
        ),
      );

      if (response?.status === 200) {
        return true;
      }

      return false;
    } catch (error) {
      return false;
    }
  }
}
