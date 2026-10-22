# Zood Design System — Pay at Table

مرجع الهوية البصرية لتطبيق **Zood Pay at Table**.

**المصدر المعتمد:** Teams / Dot-Ai  
(`Dot-Ai-Apps2/core/lib/config/theme.dart`)

**الوضع:** فاتح فقط (Light).

نفس هوية Self Order / Teams — لون أساسي واحد عبر منتجات زود للعميل.

---

## القرار

| البند | القيمة |
|--------|--------|
| Primary / CTA | `#004FEE` |
| الخط | `Cairo` |
| مرجع البراند | Teams / Dot-Ai primary — **ليس** براند Dot-Ai الفرعي `kiosk` |

### ممنوع

- الإبقاء على أزرق PAT القديم `#1B3FDB` أو برتقالي `#E8892C` كـ brand
- استبدال `Cairo` بخط آخر في واجهة العميل
- ألوان براندات فرعية إلا بطلب صريح:
  - IM وردي `#FA6A99`
  - Teams wordmark بنفسجي `#7048C0`
  - Dot-Ai kiosk سماوي `#78CBEF` / زر وردي `#FF608F`
- تدرجات كريمي/برتقالي كـ brand (الخلفية القديمة `#F4F1EB`)

---

## Color tokens

### Brand

| الدور | Hex | ملاحظات |
|--------|-----|---------|
| Primary | `#004FEE` | أزرار CTA، روابط، تمييز نشط |
| Primary dark | `#0039C7` | تدرجات / ضغط |
| Primary bright | `#4C7AF5` | highlights |
| Primary disabled | `#82A9F8` | أزرار غير مفعّلة |
| Soft primary | `#E7EDFB` | chips، أزرار ثانوية |

### Semantic

| الدور | Hex |
|--------|-----|
| Success | `#0F9F8A` |
| Success border / accent | `#1BDAC0` |
| Error | `#C01148` |

### Text

| الدور | Hex | توكن PAT |
|--------|-----|----------|
| Ink primary | `#1C2434` | `ink` |
| Body / secondary | `#4D5F73` | `inkMuted` |
| Muted | `#9B9B9B` | `inkSubtle` |

### Surfaces

| الدور | Hex | توكن PAT |
|--------|-----|----------|
| Background | `#F5F7FA` | `background` |
| Surface | `#FFFFFF` | `surface` |
| Surface muted | `#EEF2FA` | `surfaceMuted` |
| Border | `#F2F2F2` | `border` |

### Gradients

```
pageGradient:  #EEF2FA → #F5F7FD → #EDF0F8
ctaGradient:   #0039C7 → #004FEE → #4C7AF5
heroGradient:  ضمن عائلة الأزرق الغامق/الفاتح أعلاه فقط
```

لا تدرجات برتقالية (`warmGradient` السابق) كـ brand.

---

## Typography

- **العائلة:** `Cairo` (كما في `pubspec.yaml` / `AppTheme.fontFamily`)
- عناوين `w700`، جسم `w400` / `w600`
- الإبقاء على ضبط `height` و`leadingDistribution` في `AppTheme`

---

## Radii & controls

من `AppTheme` الحالي (مقبول مع الهوية):

| Token | Value |
|-------|-------|
| `radiusSm` | 10 |
| `radiusMd` | 16 |
| `radiusLg` | 24 |
| `maxContentWidth` | 1080 |

---

## Component patterns

### Primary button / CTA

- خلفية: `#004FEE` أو `ctaGradient`
- نص أبيض
- معطل: `#82A9F8`

### Secondary

- خلفية: `#E7EDFB` أو `surfaceMuted`
- نص: `#004FEE`

### Cards

- سطح أبيض، حد `#F2F2F2`، ظل خفيف (`softShadow`) بدون tint برتقالي

### Status

- نجاح: `#0F9F8A`
- خطأ: `#C01148`

---

## Mapping to Pay at Table code

حدّث:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart` (يتبع التوكنات تلقائياً إن بقيت الأسماء)
- `pubspec.yaml` / Android / web `theme_color` إن وُجدت قيم قديمة `#1F4EE5` / `#1B3FDB`

ألوان placeholder للفئات (مشروبات/حلويات) تبقى تزيينية للمنتجات وليست brand.

---

## Sources

- `Dot-Ai-Apps2/core/lib/config/theme.dart`
- Self Order: `docs/ZOOD_DESIGN_SYSTEM.md` (نفس القرار)
- قاعدة Cursor: `.cursor/rules/zood-design.mdc`
