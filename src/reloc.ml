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

let exec_magic_number = "Caml1999X008"
let len_magic_number = String.length exec_magic_number
let blocksize = 4096

(* magic number is at the end *)
let is_bytecode_exe ic =
  let magic_number = String.create len_magic_number in
  let pos_trailer = in_channel_length ic - len_magic_number in
  if pos_trailer < 0 then false else
    let _ = seek_in ic pos_trailer in
    let _ = really_input ic magic_number 0 len_magic_number in
    magic_number = exec_magic_number

let reloc new_interp verbose dry_run file =
  let stats = Unix.lstat file in
  if stats.Unix.st_kind <> Unix.S_REG then
    (if verbose then
       Printf.printf "Skipping %S (not a regular file)\n" file)
  else
  if stats.Unix.st_size < len_magic_number + 2 then
    (if verbose then
       Printf.printf "Skipping %S (not an ocaml exe)\n" file)
  else
  let ic = open_in_bin file in
  let magic =
    let a = input_char ic in
    let b = input_char ic in
    a,b
  in
  if magic <> ('#','!') || not (is_bytecode_exe ic) then
    (if verbose then
       Printf.printf "Skipping %S (not an ocaml exe)\n" file;
     close_in ic)
  else
  let () = seek_in ic 0 in
  let interp = input_line ic in
  let interp = String.sub interp 2 (String.length interp - 2) in
  if interp = new_interp then
    (Printf.printf "Skipping %S (already up-to-date)\n" file;
     close_in ic)
  else
  let () =
    Printf.printf "Updating %s (was using %S)\n" file interp
  in
  if dry_run then close_in ic else
  let oc =
    Sys.remove file;
    let oc = open_out_bin file in
    let fd = Unix.descr_of_out_channel oc in
    Unix.(fchown fd stats.st_uid stats.st_gid);
    Unix.(fchmod fd stats.st_perm);
    oc
  in
  output_string oc ("#!"^new_interp^"\n");
  let buf = String.create blocksize in
  try while true do
    let n = input ic buf 0 blocksize in
    if n = 0 then raise Exit;
    output oc buf 0 n
    done
  with Exit ->
    close_out oc;
    close_in ic
