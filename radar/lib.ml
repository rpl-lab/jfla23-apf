(*
 * Copyright 2018-2020 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

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

