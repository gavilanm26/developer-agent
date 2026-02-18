# Runtime Verification Rule
Todo microservicio o módulo generado debe ser verificado en tiempo de ejecución.

1. **Mandato:** Es obligatorio ejecutar `npm run start:dev` tras la compilación exitosa.
2. **Tiempo de Prueba:** El servicio debe mantenerse estable y responder (healtcheck) o simplemente no crashear por al menos 15 segundos.
3. **Manejo de Errores:** 
   - Si el comando falla, se debe leer el final del log de error.
   - El Arquitecto IA debe identificar si el fallo es por:
     - Dependencias circulares.
     - Falta de configuración (.env / ConfigService).
     - Errores de lógica en `main.ts` o `AppModule`.
   - Se debe aplicar un fix y reintentar hasta que el arranque sea limpio.
