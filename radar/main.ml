(* simulation (discrete) function *)
let main =
  let open Ztypes in
  let Cnode { alloc = alloc; step = step; reset = reset } = Radar_pf.main in
  let mem = alloc () in
  reset mem;
  (fun x -> step mem x);;
(* (discrete) simulation loop *)
while true do main () done;
exit(0);;
