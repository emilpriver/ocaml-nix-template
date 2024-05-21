
(* test_hello.ml *)
open OUnit2

let say_hello () = "Hello from OCaml"

(* Test case for say_hello function *)
let test_say_hello _ =
  assert_equal "Hello from OCaml" (say_hello ())

  (* Test suite *)
let suite =
  "Hello Tests" >::: [
    "test_say_hello" >:: test_say_hello;
  ]

(* Run the tests *)
let () =
  run_test_tt_main suite
