export const matilda = {
    handler: async (task) => {
        console.log("Matilda handling task:", task);
        return { status: "completed" };
    }
};
