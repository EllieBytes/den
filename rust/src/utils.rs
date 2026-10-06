use std::{path::PathBuf, process::Command};

use anyhow::{Result, anyhow};
use serde::de::DeserializeOwned;

pub fn get_flake_attr<T: DeserializeOwned>(url: &str, attr: &str) -> Result<T> {
  let output = Command::new("nix")
    .arg("eval")
    .arg("--json")
    .arg("--extra-experimental-features")
    .arg("nix-command flakes")
    .arg(format!("{}#{}", url, attr))
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
