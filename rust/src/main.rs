pub mod cli;
use std::collections::HashMap;

use cli::Cli;
use den::{den::DenBuilder, utils::get_flake_attr};

fn main() {
    //Cli::new()
    //    .unwrap()
    //    .run()
    //    .unwrap();

    let schema: HashMap<String, DenBuilder> = get_flake_attr("../test", "den.internal.builders").unwrap();

    println!("{:?}", schema);
}
