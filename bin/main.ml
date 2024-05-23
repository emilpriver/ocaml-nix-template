let rec loop () = 
  print_endline "Hello world";
  Unix.sleep 1;
  loop ()

let () =
  let _ = loop () in

  ()

