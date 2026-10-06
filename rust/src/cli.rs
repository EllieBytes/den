use clap::{Subcommand, Parser};
use anyhow::{Result, anyhow};
use crate::den::DenSchema;

#[derive(Debug, Parser)]
#[command(version, about, long_about = None)]
pub struct Cli {
    #[arg(short, long)]
    flake: Option<String>,

    #[command(subcommand)]
    command: CliSubcmds,
}

impl Cli {
    pub fn new() -> Result<Self> {
        Ok(Self::parse())
    }

    pub fn run(&self) -> Result<()> {
        let uri = match self.flake.clone() {
            Some(uri) => uri,
            None => ".".to_string(),
        };

        let schema = DenSchema::new(uri)?;

        match &self.command {
            CliSubcmds::Show => {
                println!("{schema}");
            }

            CliSubcmds::New {} => {
                let output = std::process::Command::new("nix")
                    .arg("--extra-expermental-features")
                    .arg("nix-command flakes")
                    .arg("flake")
                    .arg("init")
                    .arg("-t")
                    .arg("github:EllieBytes/den")
                    .output()
                    .unwrap();

                if !&output.status.success() {
                    let stderr = String::from_utf8_lossy(&output.stderr);
                    return Err(anyhow!("Nix failed: {}", stderr));
                }

                return Ok(());
            }

            CliSubcmds::Add { descriptor } => {

            }

            CliSubcmds::Remove { descriptor } => {}
        }

        Ok(())
    }
}

#[derive(Debug, Subcommand)]
pub enum CliSubcmds {
    New {},

    Show,

    Add {
        descriptor: Option<String>,
    },

    Remove {
        descriptor: Option<String>,
    },
}
