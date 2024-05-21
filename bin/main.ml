open Riot

open Logger.Make (struct
  let namespace = ["examples"]
end)

type Message.t += Hello_world

let rec loop pid = 
  let _ = send pid Hello_world in
  loop pid

let rec receive_loop () = 
  let _ = match receive_any () with
  | Hello_world ->
      Logger.info (fun f -> f "hello world from %a!" Pid.pp (self ()));
      sleep 2.0;
      receive_loop ();
    | _ -> failwith "oops"
  in

  ()

let () =
  Riot.run @@ fun () ->

  let _ = Logger.start () |> Result.get_ok in
  set_log_level (Some Logger.Debug);

  let pid = spawn (fun () -> receive_loop ()) in
  
  print_endline "started receiver";

  let _ = loop pid in

  ()

