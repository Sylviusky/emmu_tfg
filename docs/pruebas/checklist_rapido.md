# Checklist Rápido - Empieza Aquí

## 🚀 Comienza con Seguridad (30 minutos)

### ✅ Paso 1: Revisar Permisos (10 min)

1. Abre: `android/app/src/main/AndroidManifest.xml`
2. Busca todas las líneas `<uses-permission`
3. Completa esta tabla rápida:

| Permiso | ¿Necesario? | Justificación Breve |
|---------|-------------|---------------------|
| INTERNET | ☐ Sí ☐ No | |
| ACCESS_FINE_LOCATION | ☐ Sí ☐ No | |
| CAMERA | ☐ Sí ☐ No | |
| READ_EXTERNAL_STORAGE | ☐ Sí ☐ No | |

**Guarda** en: `docs/pruebas/seguridad_permisos_[fecha].md`

---

### ✅ Paso 2: Buscar Claves API (10 min)

1. Abre: `lib/google_maps_api_key.dart`
2. ¿Está la clave hardcoded? ☐ Sí ☐ No
3. Si SÍ → **Problema**: Mover a `.env` o Remote Config
4. Si NO → ✅ OK

**Busca otras claves**:
```powershell
Select-String -Path lib\*.dart -Pattern "AIza" -CaseSensitive
```

**Anota** en: `docs/pruebas/seguridad_claves_[fecha].md`

---

### ✅ Paso 3: Revisar Firebase Rules (10 min)

1. Abre: `firestore.rules`
2. Lee las reglas
3. Responde:
   - ¿Usuarios sin auth pueden leer? ☐ Sí ☐ No (debe ser NO)
   - ¿Usuarios pueden modificar datos ajenos? ☐ Sí ☐ No (debe ser NO)

**Copia las reglas** a: `docs/pruebas/seguridad_firebase_[fecha].md`

---

## ⚡ Siguiente: Performance (1 hora)

### ✅ Paso 1: Abrir DevTools (5 min)

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Luego ejecuta:
```bash
flutter run --profile
```

---

### ✅ Paso 2: Medir Inicio (10 min)

1. Cierra la app completamente
2. Ábrela y cronometra hasta que esté lista
3. Anota: __________ segundos
4. Objetivo: < 3 segundos

---

### ✅ Paso 3: Navegar y Medir FPS (30 min)

1. En DevTools, ve a "Performance"
2. Navega por estas pantallas y anota FPS:
   - Inicio de sesión: FPS = ______
   - Lista eventos: FPS = ______
   - Lista clases: FPS = ______
   - Detalle anuncio: FPS = ______
3. Objetivo: FPS > 55

**Captura** pantalla de la gráfica de FPS

---

### ✅ Paso 4: Medir Memoria (15 min)

1. En DevTools, ve a "Memory"
2. Navega por cada pantalla
3. Anota memoria pico:
   - Inicio: ______ MB
   - Lista eventos: ______ MB
   - Lista clases: ______ MB
4. Objetivo: < 250 MB

**Captura** pantalla de la gráfica de memoria

---

## 📱 Después: Accesibilidad (2 horas)

### ✅ Paso 1: Preparar Dispositivo (10 min)

1. Toma un dispositivo Android
2. Ve a: Configuración → Accesibilidad → TalkBack
3. Activa TalkBack
4. Lee las instrucciones de gestos

---

### ✅ Paso 2: Probar Registro (30 min)

1. Abre la app
2. Navega al registro usando gestos TalkBack
3. Para cada elemento, anota:
   - Campo Email: TalkBack dice "______" ☐ Correcto ☐ Incorrecto
   - Campo Contraseña: TalkBack dice "______" ☐ Correcto ☐ Incorrecto
   - Botón Registrarse: TalkBack dice "______" ☐ Correcto ☐ Incorrecto

**Usa**: `plantilla_accesibilidad.md`

---

### ✅ Paso 3: Probar Otras Tareas (1 hora)

Repite para:
- Publicar anuncio
- Buscar anuncio
- Contactar usuario

---

## 👥 Finalmente: Usabilidad (3-5 días)

### ✅ Paso 1: Reclutar (1-2 días)

- Necesitas: 5-8 personas
- Mensaje: "¿Puedes probar mi app 30 minutos? Es para mi TFG"

---

### ✅ Paso 2: Primera Sesión (45 min)

1. Prepara dispositivo
2. Usa `plantilla_usabilidad.md`
3. Ejecuta las 5 tareas
4. Completa cuestionario SUS

---

### ✅ Paso 3: Repetir (2-3 días)

Repite con los demás participantes

---

## 📊 Consolidar Resultados

Cuando termines todo:

1. Completa `tabla_resumen_comprobaciones.md`
2. Redacta sección "Resultados" en la memoria
3. Adjunta todas las evidencias

---

## 🎯 Prioridad

**Haz primero** (hoy):
1. ✅ Seguridad - Permisos (10 min)
2. ✅ Seguridad - Claves API (10 min)
3. ✅ Seguridad - Firebase Rules (10 min)

**Haz después** (esta semana):
4. ⚡ Performance con DevTools (1 hora)
5. 📱 Accesibilidad con TalkBack (2 horas)

**Haz al final** (próximas semanas):
6. 👥 Usabilidad con participantes (3-5 días)

---

**¿Listo para empezar?** Comienza con el Paso 1 de Seguridad. ¡Es solo 10 minutos! 🚀

