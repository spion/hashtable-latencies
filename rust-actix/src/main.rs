use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use std::{
    collections::HashMap,
};
use fast_async_mutex::mutex::Mutex;

struct HashCounter {
    items: HashMap<i32, Vec<u8>>,
    counter: i32,
}

const TOTAL: i32 = 250000;

#[get("/")]
async fn hello(data: web::Data<Mutex<HashCounter>>) -> impl Responder {
    let new_data = vec![0_u8; 1024];

    // Deallocate the old data outside the mutex block
    let _old_data = {
        let mut full_data = data.lock().await;

        let new_counter = full_data.counter + 1;
        full_data.items.insert(new_counter, new_data);
        full_data.counter = new_counter;

        if new_counter > TOTAL {
            full_data.items.remove(&(new_counter - TOTAL))
        } else {
            Option::None
        }
    };

    HttpResponse::Ok().body("OK")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let my_state = web::Data::new(Mutex::new(HashCounter {
        items: HashMap::new(),
        counter: 0,
    }));

    HttpServer::new(move || App::new().app_data(my_state.clone()).service(hello))
        // .workers(1)
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
