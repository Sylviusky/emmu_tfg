# Plantilla de Comprobaciones de Seguridad y Privacidad

## Información General
- **Fecha**: ___________
- **Evaluador**: ___________
- **Versión de la App**: ___________
- **Build**: ___________

---

## 1. Permisos de Android

### Permisos Solicitados en AndroidManifest.xml

| Permiso | ¿Necesario? | Justificación | Riesgo |
|---------|-------------|---------------|--------|
| INTERNET | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |
| ACCESS_FINE_LOCATION | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |
| ACCESS_COARSE_LOCATION | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |
| CAMERA | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |
| READ_EXTERNAL_STORAGE | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |
| WRITE_EXTERNAL_STORAGE | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |
| READ_MEDIA_IMAGES | ☐ Sí ☐ No | | ☐ Bajo ☐ Medio ☐ Alto |

**Observaciones**: 
_________________________________________________________

---

## 2. Gestión de Claves y Secretos

### Claves API y Secretos

| Recurso | Ubicación Actual | ¿Expuesto? | Acción Tomada |
|---------|------------------|------------|---------------|
| Google Maps API Key | | ☐ Sí ☐ No | |
| Firebase API Keys | | ☐ Sí ☐ No | |
| OAuth Client IDs | | ☐ Sí ☐ No | |
| Otros secretos | | ☐ Sí ☐ No | |

**Recomendaciones**:
- [ ] Usar `flutter_dotenv` para variables de entorno
- [ ] Mover claves a Firebase Remote Config
- [ ] Usar Android Keystore para secretos sensibles
- [ ] Nunca subir claves reales al repositorio público

**Estado**: ☐ Cumplido ☐ Pendiente

---

## 3. Reglas de Seguridad de Firebase

### Firestore Security Rules

**Archivo**: `firestore.rules`

**Reglas actuales**:
```javascript
// Pegar aquí las reglas actuales
```

**Pruebas realizadas**:
- [ ] Usuario no autenticado no puede leer datos privados
- [ ] Usuario no autenticado no puede escribir datos
- [ ] Usuario solo puede modificar sus propios datos
- [ ] Validación de campos requeridos

**Resultados**:
| Prueba | Resultado Esperado | Resultado Obtenido | ¿Pasa? |
|--------|-------------------|-------------------|--------|
| Lectura sin auth | Error 403 | | ☐ Sí ☐ No |
| Escritura sin auth | Error 403 | | ☐ Sí ☐ No |
| Modificar datos ajenos | Error 403 | | ☐ Sí ☐ No |

---

### Firebase Storage Security Rules

**Archivo**: `storage.rules`

**Reglas actuales**:
```javascript
// Pegar aquí las reglas actuales
```

**Pruebas realizadas**:
- [ ] Usuario no autenticado no puede subir archivos
- [ ] Usuario solo puede subir a su propia carpeta
- [ ] Validación de tipos de archivo permitidos
- [ ] Límite de tamaño de archivo

**Resultados**:
| Prueba | Resultado Esperado | Resultado Obtenido | ¿Pasa? |
|--------|-------------------|-------------------|--------|
| Subida sin auth | Error 403 | | ☐ Sí ☐ No |
| Subida a carpeta ajena | Error 403 | | ☐ Sí ☐ No |
| Tipo de archivo no permitido | Error 400 | | ☐ Sí ☐ No |

---

## 4. Autenticación

### Firebase Authentication

**Métodos de autenticación implementados**:
- [ ] Email/Contraseña
- [ ] Google Sign-In
- [ ] OAuth (otros proveedores)

**Validaciones implementadas**:
- [ ] Verificación de email
- [ ] Validación de fortaleza de contraseña
- [ ] Rate limiting en intentos de login
- [ ] Manejo seguro de tokens

**Problemas detectados**:
_________________________________________________________

---

## 5. Comunicación de Red

### HTTPS/TLS

- [ ] Todas las comunicaciones usan HTTPS
- [ ] Certificados SSL válidos
- [ ] No hay tráfico HTTP inseguro
- [ ] Pinning de certificados (si aplica)

**Herramienta utilizada**: ☐ Charles Proxy ☐ Burp Suite ☐ Otra: ___________

**Resultados**:
_________________________________________________________

---

## 6. Almacenamiento Local

### Datos Sensibles en Dispositivo

| Tipo de Dato | ¿Se Almacena? | Método de Almacenamiento | ¿Encriptado? |
|--------------|---------------|--------------------------|--------------|
| Credenciales | ☐ Sí ☐ No | | ☐ Sí ☐ No |
| Tokens de sesión | ☐ Sí ☐ No | | ☐ Sí ☐ No |
| Datos de usuario | ☐ Sí ☐ No | | ☐ Sí ☐ No |

**Recomendaciones**:
- [ ] Usar `flutter_secure_storage` para datos sensibles
- [ ] No almacenar contraseñas en texto plano
- [ ] Limpiar datos al cerrar sesión

---

## 7. Análisis Estático de Seguridad

### Herramientas Utilizadas

- [ ] MobSF (Mobile Security Framework)
- [ ] Flutter Analyze
- [ ] Android Lint
- [ ] Otra: ___________

### Vulnerabilidades Detectadas

| Severidad | Descripción | Ubicación | Estado |
|-----------|-------------|-----------|--------|
| Crítica | | | ☐ Abierta ☐ Cerrada |
| Alta | | | ☐ Abierta ☐ Cerrada |
| Media | | | ☐ Abierta ☐ Cerrada |
| Baja | | | ☐ Abierta ☐ Cerrada |

---

## 8. Privacidad de Datos

### Datos Personales Recopilados

| Tipo de Dato | ¿Se Recopila? | ¿Se Comparte? | Consentimiento |
|--------------|---------------|---------------|----------------|
| Email | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| Nombre | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| Ubicación | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| Fotos | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| Teléfono | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |

**Cumplimiento GDPR/Protección de Datos**:
- [ ] Política de privacidad disponible
- [ ] Consentimiento explícito para datos sensibles
- [ ] Opción de eliminar cuenta y datos
- [ ] Exportación de datos del usuario

---

## 9. Pruebas de Penetración Básicas

### Intentos de Acceso No Autorizado

| Prueba | Resultado | ¿Vulnerable? |
|--------|-----------|-------------|
| Acceso sin autenticación | | ☐ Sí ☐ No |
| Modificación de datos ajenos | | ☐ Sí ☐ No |
| Inyección SQL (si aplica) | | ☐ Sí ☐ No |
| XSS en campos de entrada | | ☐ Sí ☐ No |
| CSRF en operaciones críticas | | ☐ Sí ☐ No |

---

## 10. Resumen y Acciones

### Problemas Críticos Encontrados
1. _________________________________________________________
2. _________________________________________________________

### Problemas Menores Encontrados
1. _________________________________________________________
2. _________________________________________________________

### Acciones Correctivas Aplicadas
1. _________________________________________________________
2. _________________________________________________________

### Estado General de Seguridad
- **Nivel de Seguridad**: ☐ Excelente ☐ Bueno ☐ Regular ☐ Deficiente
- **¿Lista para producción?**: ☐ Sí ☐ No (especificar por qué)

---

## Referencias

- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)

