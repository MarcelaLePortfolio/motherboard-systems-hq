import type { OperatorSurface }
from "./operatorSurface.types.ts";

import type { OperatorAcknowledgement }
from "./operatorAcknowledgement.types.ts";

export function createOperatorAcknowledgement(
  surface:OperatorSurface
):OperatorAcknowledgement{

  return{

    surfaceId:surface.id,

    acknowledged:false,

    acknowledgedAt:null,

    acknowledgedBy:null

  };

}

export function acknowledgeOperatorSurface(
  ack:OperatorAcknowledgement,
  operatorId:string,
  ts:number
):OperatorAcknowledgement{

  if(ack.acknowledged){
    return ack;
  }

  return{

    surfaceId:ack.surfaceId,

    acknowledged:true,

    acknowledgedAt:ts,

    acknowledgedBy:operatorId

  };

}
