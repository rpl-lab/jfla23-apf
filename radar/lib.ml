open Probzelus
open Owl
open Distribution

let _  = Random.self_init ()

let of_lists l = Mat.of_arrays (Array.of_list (List.map Array.of_list l))
let of_list l n m = Mat.of_array (Array.of_list l) n m

let diagm l = Mat.diagm (of_lists [l])
let vec l = of_list l (List.length l) 1
let vec_get x i = Mat.get x i 0

let ( +@ ) m1 m2 = Mat.add m1 m2
let ( *@ ) x m = Mat.mul_scalar m x

let extract_samples n d =
  List.init n (fun _ -> draw d)

let string_of_list pp l =
  let body = match l with
  | [] -> ""
  | x::l -> (pp x)^(List.fold_left (fun acc x -> acc^","^(pp x)) "" l)
in  "["^body^"]"

let zeros = vec [0.; 0.]
let ones = vec [1.; 1.]
let i2 = diagm [1.0; 1.0]

(** Constants *)
let alpha_noise = 0.001
let delta_noise = 0.001
let speed = 0.5
let ping_speed = 100.
let x0 = vec [10.; 10.]

