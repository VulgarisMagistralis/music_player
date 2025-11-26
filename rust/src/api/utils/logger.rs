use android_logger::Config;
use log::info;
#[no_mangle]
pub extern "C" fn init_rust_logger() {
    android_logger::init_once(
        Config::default()
            .with_max_level(log::LevelFilter::Info)
            .with_tag("rust"),
    );
    info!("LOGGER INIT WORKED");
}
