use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use std::{collections::HashMap, sync::Mutex};

struct HashCounter {
    items: HashMap<i32, Vec<u8>>,
    counter: i32,
}

struct AppState {
    hash_counter: Mutex<HashCounter>,
}
const TOTAL: i32 = 250000;

#[get("/")]
async fn hello(data: web::Data<AppState>) -> impl Responder {
    let new_data = vec![0_u8; 1024];
    {
        let mut full_data = data.hash_counter.lock().unwrap();

        let new_counter = full_data.counter + 1;
        full_data.items.insert(new_counter, new_data);
        if new_counter > TOTAL {
            full_data.items.remove(&(new_counter - TOTAL));
        }
        full_data.counter = new_counter;
    };
    // items.

    HttpResponse::Ok().body("OK")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let my_state = web::Data::new(AppState {
        hash_counter: Mutex::new(HashCounter {
            items: HashMap::new(),
            counter: 0,
        }),
    });

    HttpServer::new(move || App::new().app_data(my_state.clone()).service(hello))
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
