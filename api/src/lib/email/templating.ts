import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import Handlebars from "handlebars";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Path to templates directory
// Adjusted to reach src/templates from src/lib
const TEMPLATES_DIR = path.resolve(__dirname, "..", "..", "templates", "emails");

/**
 * Renders an email template with a layout.
 *
 * @param templateName - The name of the template file (without .hbs)
 * @param context - The data to pass to the template
 * @param subject - The subject line for the layout header
 * @returns rendered HTML string
 */
export async function renderTemplate(
  templateName: string,
  context: Record<string, any>,
  subject: string,
): Promise<string> {
  try {
    // Read layout and template files
    const [layoutSource, templateSource] = await Promise.all([
      fs.readFile(path.join(TEMPLATES_DIR, "layout.hbs"), "utf-8"),
      fs.readFile(path.join(TEMPLATES_DIR, `${templateName}.hbs`), "utf-8"),
    ]);

    // Compile templates
    const layout = Handlebars.compile(layoutSource);
    const template = Handlebars.compile(templateSource);

    // Render inner content
    const body = template(context);

    // Render full layout
    return layout({
      ...context,
      subject,
      body,
      year: new Date().getFullYear(),
    });
  } catch (error) {
    console.error(`Error rendering email template "${templateName}":`, error);
    throw new Error(`Failed to render email template: ${templateName}`);
  }
}
