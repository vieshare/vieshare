use hbb_common::config::Config;
use crate::gaming_optimizer::{GamingMode, GamingProfile, set_gaming_mode, set_gaming_profile};

// Gaming configuration keys
pub const GAMING_MODE_KEY: &str = "gaming_mode";
pub const GAMING_TARGET_FPS_KEY: &str = "gaming_target_fps";
pub const GAMING_BITRATE_MULT_KEY: &str = "gaming_bitrate_multiplier";
pub const GAMING_INPUT_PRIORITY_KEY: &str = "gaming_input_priority";
pub const GAMING_IMMEDIATE_FRAME_KEY: &str = "gaming_immediate_frame";
pub const GAMING_CAPTURE_OPT_KEY: &str = "gaming_capture_optimization";

// Default configuration values
pub const DEFAULT_GAMING_FPS: u32 = 60;
pub const DEFAULT_GAMING_BITRATE_MULT: f32 = 2.0;

pub fn load_gaming_config() {
    let mode = match Config::get_option(GAMING_MODE_KEY).as_str() {
        "auto" => GamingMode::Auto,
        "force" => GamingMode::Force,
        _ => GamingMode::Auto, // Default to auto mode
    };
    
    let target_fps = Config::get_option(GAMING_TARGET_FPS_KEY)
        .parse::<u32>()
        .unwrap_or(DEFAULT_GAMING_FPS)
        .clamp(30, 120);
        
    let bitrate_multiplier = Config::get_option(GAMING_BITRATE_MULT_KEY)
        .parse::<f32>()
        .unwrap_or(DEFAULT_GAMING_BITRATE_MULT)
        .clamp(1.0, 5.0);
        
    let input_priority = Config::get_option(GAMING_INPUT_PRIORITY_KEY) == "Y";
    let immediate_frame = Config::get_option(GAMING_IMMEDIATE_FRAME_KEY) == "Y";
    let capture_optimization = Config::get_option(GAMING_CAPTURE_OPT_KEY) == "Y";
    
    let profile = GamingProfile {
        target_fps,
        max_bitrate_multiplier: bitrate_multiplier,
        input_priority,
        immediate_frame_mode: immediate_frame,
        capture_optimization,
    };
    
    hbb_common::log::info!(
        "Gaming config loaded: mode={:?}, fps={}, bitrate_mult={:.1}", 
        mode, target_fps, bitrate_multiplier
    );
    
    set_gaming_mode(mode);
    set_gaming_profile(profile);
}

pub fn save_gaming_config(mode: GamingMode, profile: &GamingProfile) {
    let mode_str = match mode {
        GamingMode::Disabled => "disabled",
        GamingMode::Auto => "auto", 
        GamingMode::Force => "force",
    };
    
    Config::set_option(GAMING_MODE_KEY.to_owned(), mode_str.to_owned());
    Config::set_option(GAMING_TARGET_FPS_KEY.to_owned(), profile.target_fps.to_string());
    Config::set_option(GAMING_BITRATE_MULT_KEY.to_owned(), profile.max_bitrate_multiplier.to_string());
    Config::set_option(GAMING_INPUT_PRIORITY_KEY.to_owned(), if profile.input_priority { "Y" } else { "N" }.to_owned());
    Config::set_option(GAMING_IMMEDIATE_FRAME_KEY.to_owned(), if profile.immediate_frame_mode { "Y" } else { "N" }.to_owned());
    Config::set_option(GAMING_CAPTURE_OPT_KEY.to_owned(), if profile.capture_optimization { "Y" } else { "N" }.to_owned());
    
    set_gaming_mode(mode);
    set_gaming_profile(profile.clone());
    
    hbb_common::log::info!("Gaming config saved and applied");
}

// Preset gaming configurations
pub fn apply_gaming_preset_low_latency() {
    let profile = GamingProfile {
        target_fps: 60,
        max_bitrate_multiplier: 1.5,
        input_priority: true,
        immediate_frame_mode: true,
        capture_optimization: true,
    };
    save_gaming_config(GamingMode::Auto, &profile);
}

pub fn apply_gaming_preset_high_quality() {
    let profile = GamingProfile {
        target_fps: 120,
        max_bitrate_multiplier: 3.0,
        input_priority: true,
        immediate_frame_mode: false,
        capture_optimization: true,
    };
    save_gaming_config(GamingMode::Auto, &profile);
}

pub fn apply_gaming_preset_balanced() {
    let profile = GamingProfile {
        target_fps: 75,
        max_bitrate_multiplier: 2.0,
        input_priority: true,
        immediate_frame_mode: true,
        capture_optimization: true,
    };
    save_gaming_config(GamingMode::Auto, &profile);
}