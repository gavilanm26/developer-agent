# Testing & Coverage Rules
El microservicio debe ser entregado con una suite de pruebas sólida y verificada.

1. **Mandato de Cobertura:** Todo microservicio debe tener un mínimo de **95%** de cobertura total.
2. **Comando de Verificación:** Se debe ejecutar `npm run test:cov`.
3. **Acción ante Fallos:**
   - El proceso **NO PUEDE PARAR** hasta que todos los tests pasen (Green) y la cobertura sea >= 95%.
   - La IA debe identificar todos los archivos con baja cobertura en el reporte y repararlos uno por uno.
4. **Restricción de Código:** 
   - **PROHIBIDO** dejar comentarios en el código generado (ni explicaciones, ni TODOs, ni comentarios de lógica).
   - El código debe ser autodocumentado y limpio.

