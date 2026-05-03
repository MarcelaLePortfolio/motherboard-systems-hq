export const matilda = {
  handler: async (task: any) => {
    console.log("Matilda handling task:", task);
    return { status: "completed" };
  }
};
