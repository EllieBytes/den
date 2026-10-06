use std::path::Path;

use crate::den::DenSchema;
use anyhow::{Result, anyhow};
use clap::{Parser, Subcommand};
use dircpy::copy_dir;
use fluent_uri::{Uri, UriRef, component::Scheme};

#[derive(Debug, Parser)]
#[command(version, about, long_about = None)]
pub struct Cli {
    #[arg(short, long)]
    flake: Option<UriRef<String>>,

    #[command(subcommand)]
    command: CliSubcmds,
}

impl Cli {
    pub fn new() -> Result<Self> {
        Ok(Self::parse())
    }

    fn handle_uri(potential: &str) -> Result<Uri<String>> {
        let uri_ref = UriRef::parse(String::from(potential))
            .map_err(|_| anyhow!("Failed to parse URI Ref"))?;

        if uri_ref.has_scheme() {
            return Uri::try_from(uri_ref).map_err(|_| anyhow!("Input is not a valid URI"));
        }

        let raw_path = uri_ref.path().as_str();
        let path = Path::new(raw_path);

        let absolute = if path.is_absolute() {
            path.to_path_buf()
        } else {
            std::env::current_dir().map(|cwd| cwd.join(path))?
        };

        let canonical = match absolute.canonicalize().ok() {
            Some(s) => Ok(s),
            None => Err(anyhow!("Failed to make path canonical.")),
        }?;

        let file_uri_str = format!("file://{}/", canonical.to_str().unwrap());

        Uri::parse(file_uri_str).map_err(|_| anyhow!("Failed to parse URI"))
    }

    pub fn run(&self) -> Result<()> {
        let uri: Uri<String> = match self.flake.clone() {
            Some(uri) => Self::handle_uri(uri.as_str())?,
            None => Self::handle_uri(".")?,
        };

        println!("{}", uri.as_str());

        let schema = DenSchema::new(uri.to_string())?;

        match &self.command {
            CliSubcmds::Show => {
                println!("{schema}");
            }

            CliSubcmds::New => {
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

            CliSubcmds::Add {
                name,
                builder,
                output,
            } => match schema.query_builder(builder.clone()) {
                Some(b) => {
                    let base = match uri.scheme().as_str() {
                        "file" => uri.clone(),
                        scheme => {
                            return Err(anyhow!("Invalid scheme {}", scheme));
                        }
                    };

                    println!("{}", base.as_str());

                    if b.default_path == "" {
                        eprintln!("{} has no default directory to output to.", b.name);
                        return Err(anyhow!("no default directory for {}", b.name));
                    }

                    let default_ref: UriRef<String> =
                        UriRef::parse(b.default_path.clone() + format!("/{}", name).as_str())
                            .map_err(|_| anyhow!("Failed to parse full URI"))?
                            .into();

                    println!("{}", default_ref.as_str());

                    let path = if let Some(p) = output {
                        p.to_string()
                    } else {
                        default_ref
                            .normalize()
                            .resolve_against(&base)
                            .map_err(|_| {
                                anyhow!(
                                    "Failed to resolve {} against base URI",
                                    b.default_path.clone() + format!("/{}", name).as_str()
                                )
                            })?
                            .path()
                            .decode()
                            .to_string()
                            .map_err(|_| anyhow!("Error decoding URI"))?
                            .to_string()
                    };

                    println!("{}", path);

                    if b.template_path == "" {
                        return Err(anyhow!("No template exists for builder: {}", b.name));
                    }

                    return copy_dir(b.template_path, path)
                        .map_err(|e| anyhow!("Copy failed: {e}"));
                }

                None => {
                    eprintln!("Selected builder {builder} does not exist");
                    return Err(anyhow!("builder {builder} does not exist"));
                }
            },
        }

        Ok(())
    }
}

#[derive(Debug, Subcommand)]
pub enum CliSubcmds {
    New,

    Show,

    Add {
        #[arg(short, long)]
        output: Option<String>,

        name: String,
        builder: String,
    },
}
