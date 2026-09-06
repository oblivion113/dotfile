# Codebase Documentation

Documentation in a codebase may target humans, Agents, or both; Agents keep the intended audience in mind when choosing depth and terminology. Maintain a Glossary of project-specific coined terms, because a shared vocabulary helps contributors communicate efficiently in issues and pull requests.

## Code comments

For important functions and classes, state what they do. When performance motivates an uncommon operation or algorithm, explain the principle. Unwelcome behaviors: commenting every function, comments so terse they read like a cipher, and decorative banners:

```python
# =====================
#    1. Some text
# =====================
```

## README

Treat the README as the quickstart of a mature project: what the project does, how to get started quickly, and links to deeper documentation. Avoid splitting every topic into its own section, because a healthy structure stays easy to modify and extend. Include a **For Agents** section that orients an incoming Agent to the codebase structure. A genuinely small project, such as a plugin, may use a single complete README.
