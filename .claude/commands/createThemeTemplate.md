---
description: Create a comprehensive theme template using the theme-architect agent. Provide details about your application type, target audience, desired colors, or any other visual design preferences. The agent will infer any missing information.
---

You are tasked with gathering theme requirements from the user and delegating to the theme-architect agent to create a comprehensive theme template.

**Your Workflow:**

1. **Extract User Requirements**: Parse the user's input for:
   - Application type (e.g., fintech, gaming, social media, e-commerce, healthcare, etc.)
   - Target audience (e.g., young professionals, children, enterprise users, etc.)
   - Desired colors (specific hex codes, color names, or general preferences)
   - Brand personality (e.g., playful, professional, luxury, minimalist, etc.)
   - Specific requirements (e.g., dark mode support, accessibility needs, cultural considerations)
   - Any other relevant visual design preferences

2. **Structure the Request**: Create a detailed prompt for the theme-architect agent that includes:
   - All information provided by the user
   - Clear instructions about what needs to be generated
   - Note that any missing information should be intelligently inferred based on the context

3. **Call the theme-architect Agent**: Use the Task tool to invoke the theme-architect agent with the structured request. The prompt should be comprehensive and include all user preferences.

**Example Usage:**

```
/createThemeTemplate I'm building a fintech app for young professionals. Use blue as the primary color.
```

```
/createThemeTemplate Create a theme for a children's educational game app. Make it colorful and fun.
```

```
/createThemeTemplate E-commerce platform targeting luxury fashion buyers. Colors: #1a1a1a (black), #d4af37 (gold)
```

**Important Notes:**
- You do NOT create the theme yourself - you ONLY gather requirements and delegate to theme-architect
- Be thorough in passing along all user-provided information
- If the user's request is extremely minimal, you can ask for clarification, but in most cases the theme-architect agent can infer missing details
- The theme-architect agent will create/update the `project_standards/project-theme.md` file

Now proceed to gather the user's requirements from their input after the `/createThemeTemplate` command and call the theme-architect agent.
