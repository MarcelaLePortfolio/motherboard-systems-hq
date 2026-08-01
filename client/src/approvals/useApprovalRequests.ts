import { useApprovalRequestContext } from "./ApprovalRequestProvider";

export function useApprovalRequests() {
  return useApprovalRequestContext();
}
