import "dotenv/config";import "dotenv/config";const matildaTaskRunner = async (task: any) => { return { status: "stub", task }; };export const matilda = {
  name: "Matilda",
  role: "Delegation & Liaison",
  handler: matildaTaskRunner
};
