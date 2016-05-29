open Lwt;
open Cohttp;
open Cohttp_lwt_unix;
open Hashtbl;
open Array;
open Char;

let limit = 250000;

let tbl : Hashtbl.t int (array char)  = Hashtbl.create limit;

type counter = {mutable c: int};

let server = {
  let cnt:counter = {c: 0};
  let callback _conn req body => {
    let k = cnt.c;

    Hashtbl.add tbl k (Array.make 1024 (Char.chr (k mod 256)));
    if (k > limit) {
      Hashtbl.remove tbl (k - limit);
    };

    cnt.c = cnt.c + 1;
    Server.respond_string status::`OK body::"OK" ()

  };
  let s = Server.make callback::callback ();
  Server.create s
};

let () = ignore (Lwt_main.run server);
