use std::{path::PathBuf, process::Command};

use anyhow::{Result, anyhow};
use serde::de::DeserializeOwned;

fn uri_trim_if_path(url: &str) -> &str {
    if let Some(split) = url.trim().strip_prefix("file://") {
        split
    } else {
        url
    }
}

pub fn get_flake_attr<T: DeserializeOwned>(url: &str, attr: &str) -> Result<T> {
    let uri = uri_trim_if_path(url);

    let output = Command::new("nix")
        .arg("eval")
        .arg(format!("{}#{}", uri, attr))
        .arg("--json")
        .arg("--impure")
        .arg("--extra-experimental-features")
        .arg("nix-command flakes")
        .output()
        .map_err(|e| anyhow!("Failed to execute nix command: {}", e))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(anyhow!("Nix evaluation failed:\n{}", stderr));
    }

    let result: T = serde_json::from_slice(&output.stdout)
        .map_err(|e| anyhow!("Failed to parse JSON: {}", e))?;

    Ok(result)
}
