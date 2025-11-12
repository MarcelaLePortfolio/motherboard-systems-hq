export async function ask(input) {
  return `Stub response for: ${input}`;
}

export const matilda = {
  name: "Matilda",
  handler: async (task) => {
    // Stub handler: simply returns the task received
    return { status: 'success', task };
  },
};
