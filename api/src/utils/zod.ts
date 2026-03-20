import z from "zod";

type ZodErrorTree = {
  errors?: string[];
  properties?: Record<string, ZodErrorTree>;
  items?: Array<ZodErrorTree | undefined>;
};

export function zodErrorMapper(error: z.ZodError): Record<string, string> {
  const tree = z.treeifyError(error) as ZodErrorTree;
  const result: Record<string, string> = {};

  if (!tree.properties) {
    return result;
  }

  for (const [field, node] of Object.entries(tree.properties)) {
    if (node.errors?.[0]) {
      result[field] = node.errors[0];
      continue;
    }

    if (node.items) {
      for (const item of node.items) {
        if (item?.errors?.[0]) {
          result[field] = item.errors[0];
          break;
        }
      }
    }
  }

  return result;
}
