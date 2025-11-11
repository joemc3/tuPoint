# Set up a Flutter project

## Create a theme template

Use the `/createThemeTemplate` command to generate a comprehensive visual design system for your application.

### Usage

```bash
/createThemeTemplate [your requirements]
```

Provide details such as:
- Application type (e.g., fintech, gaming, e-commerce)
- Target audience (e.g., young professionals, children)
- Desired colors (hex codes or color names)
- Brand personality (e.g., playful, professional, luxury)

The command calls the theme-architect agent, which creates a complete theme specification in `project_standards/project-theme.md` including color palettes, typography, spacing guidelines, and accessibility standards. Any missing information is intelligently inferred based on context.

### Examples

```bash
/createThemeTemplate I'm building a fintech app for young professionals. Use blue as the primary color.
```

```bash
/createThemeTemplate Children's educational game app. Make it colorful and fun.
```

```bash
/createThemeTemplate E-commerce platform for luxury fashion. Colors: #1a1a1a, #d4af37
```
