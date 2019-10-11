(* uberspark front-end command processing logic for command: bridges *)
(* author: amit vasudevan (amitvasudevan@acm.org) *)

open Uberspark
open Cmdliner

type opts = { 
  ar_bridge: bool;
  as_bridge: bool;
  cc_bridge: bool;
  ld_bridge: bool;
  pp_bridge: bool;
  vf_bridge: bool;
  output_filename: string option;
};;

(* fold all bridges options into type opts *)
let cmd_bridges_opts_handler 
  (ar_bridge: bool)
  (as_bridge: bool)
  (cc_bridge: bool)
  (ld_bridge: bool)
  (pp_bridge: bool)
  (vf_bridge: bool)
  (output_filename: string option)
  : opts = 
  { ar_bridge=ar_bridge;
    as_bridge=as_bridge;
    cc_bridge=cc_bridge;
    ld_bridge=ld_bridge;
    pp_bridge=pp_bridge;
    vf_bridge=v_bridge;
    output_filename=output_filename
  }
;;

(* handle bridges command options *)
let cmd_bridges_opts_t =
  let docs = "ACTION OPTIONS" in
  
  let ar_bridge =
  let doc = "Select archiver (ar) bridge namespace prefix." in
  Arg.(value & flag & info ["ar"; "ar-bridge"] ~doc ~docs)
  in

  let as_bridge =
  let doc = "Select assembler (as) bridge namespace prefix." in
  Arg.(value & flag & info ["as"; "as-bridge"] ~doc ~docs)
  in

  let cc_bridge =
  let doc = "Select compiler (cc) bridge namespace prefix." in
  Arg.(value & flag & info ["cc"; "cc-bridge"] ~doc ~docs)
  in

  let ld_bridge =
  let doc = "Select linker (ld) bridge namespace prefix." in
  Arg.(value & flag & info ["ld"; "ld-bridge"] ~doc ~docs)
  in

  let pp_bridge =
  let doc = "Select pre-processor (pp) bridge namespace prefix." in
  Arg.(value & flag & info ["pp"; "pp-bridge"] ~doc ~docs)
  in

  let vf_bridge =
  let doc = "Select verification (vf) bridge namespace prefix." in
  Arg.(value & flag & info ["vf"; "vf-bridge"] ~doc ~docs)
  in

  let output_filename =
    let doc = "Select output filename, $(docv)."  in
      Arg.(value & opt (some string) None & info ["o"; "output-filename"] ~docs ~docv:"NAME" ~doc)
  in

  Term.(const cmd_bridges_opts_handler $ ar_bridge $ as_bridge $ cc_bridge $ ld_bridge $ pp_bridge $ vf_bridge $ output_filename)


(* main handler for bridges command *)
let handler_bridges 
  (copts : Commonopts.opts)
  (cmd_bridges_opts: opts)
  (action : [> `Create | `Dump | `Rebuild | `Remove] as 'a)
  (path_ns : string option)
  = 

  let retval = 
  match action with
    | `Create -> 

      (* perform common initialization *)
      Commoninit.initialize copts;
      `Ok()


    | `Dump ->

      (* perform common initialization *)
      Commoninit.initialize copts;
      `Ok()


    | `Rebuild -> 
 
      (* perform common initialization *)
      Commoninit.initialize copts;
      `Ok()
 


    | `Remove -> 

      (* perform common initialization *)
      Commoninit.initialize copts;
      `Ok()
        
  in

  retval

;;