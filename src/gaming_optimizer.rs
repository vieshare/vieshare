use std::{
    collections::HashMap,
    time::{Duration, Instant},
    sync::{Arc, Mutex},
};
use hbb_common::log;

// Gaming process detection and optimization
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum GamingMode {
    Disabled,
    Auto,      // Automatically detect gaming scenarios
    Force,     // Force gaming optimizations
}

#[derive(Debug, Clone)]
pub struct GamingProfile {
    pub target_fps: u32,
    pub max_bitrate_multiplier: f32,
    pub input_priority: bool,
    pub immediate_frame_mode: bool,
    pub capture_optimization: bool,
}

impl Default for GamingProfile {
    fn default() -> Self {
        Self {
            target_fps: 60,
            max_bitrate_multiplier: 2.0,
            input_priority: true,
            immediate_frame_mode: true,
            capture_optimization: true,
        }
    }
}

pub struct GamingOptimizer {
    mode: GamingMode,
    profile: GamingProfile,
    detected_games: HashMap<String, Instant>,
    is_gaming_active: bool,
    last_input_time: Instant,
    gaming_start_time: Option<Instant>,
}

impl Default for GamingOptimizer {
    fn default() -> Self {
        Self {
            mode: GamingMode::Auto,
            profile: GamingProfile::default(),
            detected_games: HashMap::new(),
            is_gaming_active: false,
            last_input_time: Instant::now(),
            gaming_start_time: None,
        }
    }
}

impl GamingOptimizer {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn set_mode(&mut self, mode: GamingMode) {
        log::info!("Gaming mode set to {:?}", mode);
        self.mode = mode;
    }

    pub fn set_profile(&mut self, profile: GamingProfile) {
        log::info!("Gaming profile updated: target_fps={}, bitrate_mult={}", 
                   profile.target_fps, profile.max_bitrate_multiplier);
        self.profile = profile;
    }

    // Check if gaming optimizations should be active
    pub fn should_optimize_for_gaming(&mut self) -> bool {
        match self.mode {
            GamingMode::Disabled => false,
            GamingMode::Force => true,
            GamingMode::Auto => self.detect_gaming_scenario(),
        }
    }

    // Gaming detection logic based on multiple heuristics
    fn detect_gaming_scenario(&mut self) -> bool {
        let mut gaming_detected = false;

        // Heuristic 1: Process-based detection (Windows/Linux)
        #[cfg(target_os = "windows")]
        {
            gaming_detected |= self.detect_gaming_processes_windows();
        }
        #[cfg(target_os = "linux")]
        {
            gaming_detected |= self.detect_gaming_processes_linux();
        }

        // Heuristic 2: High input frequency (mouse/keyboard activity)
        gaming_detected |= self.detect_high_input_frequency();

        // Heuristic 3: Fullscreen exclusive application
        gaming_detected |= self.detect_fullscreen_exclusive();

        // Update gaming state
        if gaming_detected && !self.is_gaming_active {
            self.gaming_start_time = Some(Instant::now());
            self.is_gaming_active = true;
            log::info!("Gaming scenario detected - optimizations activated");
        } else if !gaming_detected && self.is_gaming_active {
            // Add cooldown period to prevent rapid switching
            if let Some(start_time) = self.gaming_start_time {
                if start_time.elapsed() > Duration::from_secs(30) {
                    self.is_gaming_active = false;
                    self.gaming_start_time = None;
                    log::info!("Gaming scenario ended - optimizations deactivated");
                }
            }
        }

        self.is_gaming_active
    }

    #[cfg(target_os = "windows")]
    fn detect_gaming_processes_windows(&mut self) -> bool {
        use std::process::Command;
        
        // Use PowerShell to check for gaming processes
        let output = Command::new("powershell")
            .args(&["-Command", 
                    "Get-Process | Where-Object {$_.ProcessName -match '(steam|epic|origin|uplay|battle|minecraft|unity|unreal|directx|d3d|opengl)'} | Select-Object ProcessName"])
            .output();

        if let Ok(output) = output {
            let stdout = String::from_utf8_lossy(&output.stdout);
            let has_gaming_process = !stdout.trim().is_empty() && stdout.contains("ProcessName");
            
            if has_gaming_process {
                log::debug!("Gaming processes detected via PowerShell");
            }
            
            has_gaming_process
        } else {
            false
        }
    }

    #[cfg(target_os = "linux")]
    fn detect_gaming_processes_linux(&mut self) -> bool {
        use std::fs;
        
        // Check for common gaming processes in /proc
        if let Ok(entries) = fs::read_dir("/proc") {
            for entry in entries.flatten() {
                if let Some(name) = entry.file_name().to_str() {
                    if name.chars().all(char::is_numeric) {
                        if let Ok(cmdline) = fs::read_to_string(format!("/proc/{}/cmdline", name)) {
                            let cmdline_lower = cmdline.to_lowercase();
                            if cmdline_lower.contains("steam") ||
                               cmdline_lower.contains("wine") ||
                               cmdline_lower.contains("lutris") ||
                               cmdline_lower.contains("gamemode") ||
                               cmdline_lower.contains("mangohud") {
                                log::debug!("Gaming process detected: {}", cmdline);
                                return true;
                            }
                        }
                    }
                }
            }
        }
        false
    }

    fn detect_high_input_frequency(&self) -> bool {
        // Consider gaming if we've had recent input activity
        // This is a placeholder - would be integrated with actual input monitoring
        self.last_input_time.elapsed() < Duration::from_millis(100)
    }

    fn detect_fullscreen_exclusive(&self) -> bool {
        // Platform-specific fullscreen detection
        #[cfg(target_os = "windows")]
        {
            self.detect_fullscreen_windows()
        }
        #[cfg(not(target_os = "windows"))]
        {
            false
        }
    }

    #[cfg(target_os = "windows")]
    fn detect_fullscreen_windows(&self) -> bool {
        use std::process::Command;
        
        // Check if any window is in fullscreen exclusive mode
        let output = Command::new("powershell")
            .args(&["-Command", 
                    "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::PrimaryScreen.Bounds"])
            .output();
            
        // This is simplified - would need proper Win32 API calls for accurate detection
        output.is_ok()
    }

    // Called when input events are received
    pub fn on_input_event(&mut self) {
        self.last_input_time = Instant::now();
    }

    // Get optimized settings for current scenario
    pub fn get_optimized_settings(&self) -> GamingSettings {
        if self.is_gaming_active {
            GamingSettings {
                fps: self.profile.target_fps,
                bitrate_multiplier: self.profile.max_bitrate_multiplier,
                input_priority: self.profile.input_priority,
                immediate_frame: self.profile.immediate_frame_mode,
                capture_optimization: self.profile.capture_optimization,
                low_latency_mode: true,
            }
        } else {
            GamingSettings::default()
        }
    }

    pub fn is_gaming_active(&self) -> bool {
        self.is_gaming_active
    }
}

#[derive(Debug, Clone)]
pub struct GamingSettings {
    pub fps: u32,
    pub bitrate_multiplier: f32,
    pub input_priority: bool,
    pub immediate_frame: bool,
    pub capture_optimization: bool,
    pub low_latency_mode: bool,
}

impl Default for GamingSettings {
    fn default() -> Self {
        Self {
            fps: 30,
            bitrate_multiplier: 1.0,
            input_priority: false,
            immediate_frame: false,
            capture_optimization: false,
            low_latency_mode: false,
        }
    }
}

// Global gaming optimizer instance
lazy_static::lazy_static! {
    pub static ref GAMING_OPTIMIZER: Arc<Mutex<GamingOptimizer>> = 
        Arc::new(Mutex::new(GamingOptimizer::new()));
}

// Convenience functions for global access
pub fn set_gaming_mode(mode: GamingMode) {
    if let Ok(mut optimizer) = GAMING_OPTIMIZER.lock() {
        optimizer.set_mode(mode);
    }
}

pub fn set_gaming_profile(profile: GamingProfile) {
    if let Ok(mut optimizer) = GAMING_OPTIMIZER.lock() {
        optimizer.set_profile(profile);
    }
}

pub fn should_optimize_for_gaming() -> bool {
    GAMING_OPTIMIZER.lock()
        .map(|mut optimizer| optimizer.should_optimize_for_gaming())
        .unwrap_or(false)
}

pub fn on_input_event() {
    if let Ok(mut optimizer) = GAMING_OPTIMIZER.lock() {
        optimizer.on_input_event();
    }
}

pub fn get_gaming_settings() -> GamingSettings {
    GAMING_OPTIMIZER.lock()
        .map(|optimizer| optimizer.get_optimized_settings())
        .unwrap_or_default()
}

pub fn is_gaming_active() -> bool {
    GAMING_OPTIMIZER.lock()
        .map(|optimizer| optimizer.is_gaming_active())
        .unwrap_or(false)
}