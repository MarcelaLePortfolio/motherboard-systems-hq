export interface OperatorAcknowledgement {

  surfaceId:string;

  acknowledged:boolean;

  acknowledgedAt:number | null;

  acknowledgedBy:string | null;

}
