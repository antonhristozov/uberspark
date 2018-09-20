(* uberspark config tool: to locate hwm, libraries and headers *)
(* author: amit vasudevan (amitvasudevan@acm.org) *)

open Sys
open Unix
open Filename

open Uslog
open Libusmf

let log_mpf = "uberSpark";;

let g_install_prefix = "/usr/local";;
let g_uberspark_install_bindir = "/usr/local/bin";;
let g_uberspark_install_homedir = "/usr/local/uberspark";;
let g_uberspark_install_includedir = "/usr/local/uberspark/include";;
let g_uberspark_install_hwmdir = "/usr/local/uberspark/hwm";;
let g_uberspark_install_hwmincludedir = "/usr/local/uberspark/hwm/include";;
let g_uberspark_install_libsdir = "/usr/local/uberspark/libs";;
let g_uberspark_install_libsincludesdir = "/usr/local/uberspark/libs/include";;
let g_uberspark_install_toolsdir = "/usr/local/uberspark/tools";;


let copt_builduobj = ref false;;

let cmdopt_invalid opt = 
	Uslog.logf log_mpf Uslog.Info "invalid option: '%s'; use -help to see available options" opt;
	ignore(exit 1);
	;;

let cmdopt_uobjlist = ref "";;
let cmdopt_uobjlist_set value = cmdopt_uobjlist := value;;

let cmdopt_uobjmanifest = ref "";;
let cmdopt_uobjmanifest_set value = cmdopt_uobjmanifest := value;;

let file_copy input_name output_name =
	let buffer_size = 8192 in
	let buffer = Bytes.create buffer_size in
  let fd_in = openfile input_name [O_RDONLY] 0 in
  let fd_out = openfile output_name [O_WRONLY; O_CREAT; O_TRUNC] 0o666 in
  let rec copy_loop () = match read fd_in buffer 0 buffer_size with
    |  0 -> ()
    | r -> ignore (write fd_out buffer 0 r); copy_loop ()
  in
  copy_loop ();
  close fd_in;
  close fd_out;
	()
;;


(* Create a pipe for the subprocess output. *)


(* execute a process and print its output if verbose is set to true *)
(* return the error code of the process *)
let exec_process_withlog () =
	(* Launch the program, redirecting its stdout to the pipe.
   By calling Unix.create_process, we can avoid running the
   command through the shell. *)
		let readme, writeme = Unix.pipe () in
	  let pid = Unix.create_process
    "gcc" [| "gcc" ; "-P"; "-E"; "../../dat.c"; "-o" ; "dat.i" |]
    Unix.stdin writeme writeme in
  Unix.close writeme;
  let in_channel = Unix.in_channel_of_descr readme in
  let p_output = ref [] in
	let p_exitstatus = ref 0 in
	let p_exitsignal = ref false in
  begin
    try
      while true do
        p_output := input_line in_channel :: !p_output
      done
    with End_of_file -> 
			match	(Unix.waitpid [] pid) with
    	| (wpid, Unix.WEXITED status) ->
        	p_exitstatus := status;
					p_exitsignal := false;
    	| (wpid, Unix.WSIGNALED signal) ->
        	p_exitsignal := true;
    	| (wpid, Unix.WSTOPPED signal) ->
        	p_exitsignal := true;
			;
			()
  end;
  Unix.close readme;
  (* List.iter print_endline (List.rev !lines); *)
	(!p_exitstatus, (List.rev !p_output))
;;


				
let read_process_lines command =
  let lines = ref [] in
  let in_channel = Unix.open_process_in command in
  begin
    try
      while true do
        lines := input_line in_channel :: !lines
      done;
    with End_of_file ->
      ignore (Unix.close_process_in in_channel)
  end;
  List.rev !lines;
;;

let redirect_process () =
  let ph = Unix.open_process_in "gcc 2>&1" in
	try
	  while true do
	    let line = input_line ph in
				Uslog.logf log_mpf Uslog.Info "%s" line; 
    	()
  	done
		with End_of_file -> ()
;;
    						
								
let main () =
	begin
(*		let i = ref 0 in
		let speclist = [
			("--builduobj", Arg.Set copt_builduobj, "Build uobj binary by compiling and linking");
			("-b", Arg.Set copt_builduobj, "Build uobj binary by compiling and linking");
			("--uobjlist", Arg.String (cmdopt_uobjlist_set), "uobj list filename with path");
			("--uobjmanifest", Arg.String (cmdopt_uobjmanifest_set), "uobj list filename with path");

			] in
		let usage_msg = "uberSpark driver tool by Amit Vasudevan (amitvasudevan@acm.org)" in
		let uobj_id = ref 0 in
		let uobj_manifest_filename = ref "" in
		let uobj_name = ref "" in

						Uslog.current_level := Uslog.ord Uslog.Info;
			Arg.parse speclist cmdopt_invalid usage_msg;
 			Uslog.logf log_mpf Uslog.Info "copt_builduobj: %b" !copt_builduobj;

 			Uslog.logf log_mpf Uslog.Info "cmdopt_uobjlist: %s" !cmdopt_uobjlist;
 			(* Uslog.logf log_mpf Uslog.Info "dirname: %s" (Filename.dirname !cmdopt_uobjlist); *)

			Libusmf.usmf_parse_uobj_list (!cmdopt_uobjlist) ((Filename.dirname !cmdopt_uobjlist) ^ "/");
			Uslog.logf log_mpf Uslog.Info "g_totalslabs=%d \n" !Libusmf.g_totalslabs;

	
			uobj_manifest_filename := (Filename.basename !cmdopt_uobjmanifest);
			uobj_name := Filename.chop_extension !uobj_manifest_filename;
			uobj_id := (Hashtbl.find Libusmf.slab_nametoid !uobj_name);

		Uslog.logf log_mpf Uslog.Info "proceeding to parse includes...";
			Libusmf.usmf_parse_uobj_mf_includedirs !uobj_id !cmdopt_uobjmanifest;
			Uslog.logf log_mpf Uslog.Info "includes parsed.";

			let str_list = (Hashtbl.find_all Libusmf.slab_idtoincludedirs !uobj_id) in
				begin
					Uslog.logf log_mpf Uslog.Info "length=%u\n"  (List.length str_list);
					while (!i < (List.length str_list)) do
						begin
							let include_dir_str = (List.nth str_list !i) in
							Uslog.logf log_mpf Uslog.Info "i=%u --> %s" !i include_dir_str; 
							i := !i + 1;
						end
					done;
				end
*)

			Uslog.current_level := Uslog.ord Uslog.Info;
			Uslog.logf log_mpf Uslog.Info "proceeding to execute...\n";

			let result = exec_process_withlog () in
				let exit_status = fst result  in
				let process_output = snd result in
						Uslog.logf log_mpf Uslog.Info "Done: exit_status=%d\n" exit_status;
	
												 
			(* read_process_lines "gcc -P -E dat.c -o dat.i";*)
			(* redirect_process (); *)
(*
			file_copy !cmdopt_uobjmanifest (!uobj_name ^ ".gsm.pp");

			Uslog.logf log_mpf Uslog.Info "uobj_name=%s, uobj_id=%u\n"  !uobj_name !uobj_id;
			Libusmf.usmf_memoffsets := false;
			Libusmf.usmf_parse_uobj_mf (Hashtbl.find Libusmf.slab_idtogsm !uobj_id) (Hashtbl.find Libusmf.slab_idtommapfile !uobj_id);
*)

		end
	;;
 
		
main ();;


