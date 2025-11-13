export const startMatilda = {
  handleMessage: async (message: string) => {
    console.log(`💬 Matilda received: ${message}`);
    return `Matilda says: You said "${message}"`;
  },
};
