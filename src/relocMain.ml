(**************************************************************************)
(*                                                                        *)
(*  Copyright 2013 OCamlPro                                               *)
(*                                                                        *)
(*  All rights reserved.  This file is distributed under the terms of     *)
(*  the Lesser GNU Public License version 3.0.                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  Lesser GNU General Public License for more details.                   *)
(*                                                                        *)
(**************************************************************************)

open Cmdliner

let ocamlrun =
  let doc = "Path to the new ocamlrun exe to use" in
  let arg = Arg.(value & opt (some string) None &
                 info ["ocamlrun"] ~docv:"PATH" ~doc) in
  let default () =
    try
      let ic = Unix.open_process_in "which ocamlrun" in
      let s = input_line ic in
      close_in ic;
      Printf.printf "Will use %s\n" s;
      s
    with _ ->
      prerr_endline
        "ERROR: Could not locate an ocamlrun exe. Please use `--ocamlrun'.";
      exit 2
  in
  Term.(pure (function Some s -> s | None -> default ()) $ arg)

let verbose =
  let doc = "Be more verbose about processed files" in
  Arg.(value & flag & info ["verbose";"v"] ~doc)

let dry_run =
  let doc = "Run the checks but don't actually modify any files" in
  Arg.(value & flag & info ["dry-run"] ~doc)

let files =
  let doc = "Files or directories to relocate. Any directories will be fully \
             traversed for OCaml bytecode files." in
  Arg.(non_empty & pos_all file [] & info ~docv:"FILES" [] ~doc)


let dir_files path =
  List.map (Filename.concat path) (Array.to_list (Sys.readdir path))

let rec rec_files flist =
  let dirs,files =
    List.partition (fun f -> try Sys.is_directory f with _ -> false) flist
  in
  List.fold_left (fun acc dir ->
      List.rev_append (rec_files (dir_files dir)) acc)
    files dirs

let process =
  Term.(
    pure (fun ocamlrun verbose dry_run files ->
        List.iter (Reloc.reloc ocamlrun verbose dry_run) (rec_files files))
    $ ocamlrun $ verbose $ dry_run $ files
  )

let info =
  let doc = "Changes the headers of OCaml bytecode file to account for a \
             different location of ocamlrun" in
  Term.info "ocp-reloc" ~version:"0.1" ~doc

let () =
  match Term.eval (process,info) with
  | `Error _ -> exit 1
  | _ -> exit 0
