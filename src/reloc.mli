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

val reloc: string -> bool -> bool -> string -> unit
(** [reloc new_ocamlrun verbose dry_run file] checks that [file] is an ocaml
    bytecode executable, and relocates it to use [new_ocamlrun] if needed.
    With [verbose], display additional information, and with [dry_run], do
    the checks but don't modify anything. *)
