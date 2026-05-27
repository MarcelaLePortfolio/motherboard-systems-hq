export const db = {
  select: (...args: any[]) => db,
  from: (...args: any[]) => db,
  where: (...args: any[]) => db,
  orderBy: (...args: any[]) => db,
  limit: (...args: any[]) => db,
  all: () => [],
  eq: (...args: any[]) => db,
  prepare: (...args: any[]) => ({ run: (..._: any) => {}, get: (..._: any) => ({ c: 0 }), all: () => [] }),
  exec: (...args: any[]) => {},
  desc: (val: any) => val,
};
export const sqlite = db;
