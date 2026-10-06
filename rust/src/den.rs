use std::{collections::HashMap, fmt::{self, Display}, path::PathBuf};
use serde::{Serialize, Deserialize};
use anyhow::Result;

use crate::utils;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct DenBuilder {
  pub name: String,
  pub description: String,
  pub authors: Vec<String>,
  pub version: String,
  pub search_paths: Vec<String>,
  pub build_functions: Vec<String>,
  pub aggregate_functions: Vec<String>,
  pub default_path: String,
  pub template_path: String,
}

impl DenBuilder {
    fn field(f: &mut fmt::Formatter<'_>, label: &str, value: &str) -> fmt::Result {
        writeln!(f, "  {:<width$}{}", format!("{label}:"), value, width = 18)
    }

    fn list_field(f: &mut fmt::Formatter<'_>, label: &str, items: &[String]) -> fmt::Result {
        if items.is_empty() {
            return Self::field(f, label, "(none)");
        }

        writeln!(f, "  {label}:")?;
        for item in items {
            writeln!(f, "    - {item}")?;
        }

        Ok(())
    }
}

impl Display for DenBuilder {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "{} (v{})", self.name, self.version)?;

        for line in self.description.lines() {
            writeln!(f, "  {line}")?;
        }

        writeln!(f)?;

        Self::list_field(f, "Authors", &self.authors)?;
        Self::list_field(f, "Search Paths", &self.search_paths)?;
        Self::list_field(f, "Build Functions", &self.build_functions)?;
        Self::list_field(f, "Aggregate Functions", &self.aggregate_functions)?;

        Ok(())
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DenSchema {
  pub builders: HashMap<String, DenBuilder>,
  pub version: String,
}

impl DenSchema {
    pub fn new(flake_ref: String) -> Result<Self> {
        let builders = utils::get_flake_attr::<HashMap<String, DenBuilder>>(flake_ref.as_str(), "den.internal.builders")?;
        let version = utils::get_flake_attr::<String>(flake_ref.as_str(), "den.internal.version")?;

        Ok(Self { builders, version })
    }


    pub fn query_builder_path(&self, name: String) -> Option<PathBuf> {
        if let Some(builder) = self.builders.get(&name) {
            return Some(PathBuf::from(builder.default_path.clone()));
        } else {
            return None;
        }
    }

    pub fn query_template_path(&self, name: String) -> Option<PathBuf> {
        if let Some(builder) = self.builders.get(&name) {
            return Some(PathBuf::from(builder.template_path.clone()));
        } else {
            return None;
        }
    }

    pub fn query_builder(&self, name: String) -> Option<DenBuilder> {
        Some(self.builders.get(&name).cloned()?)
    }
}

impl std::fmt::Display for DenSchema {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "Den")?;
        writeln!(f, "Schema Version {}", self.version)?;

        if self.builders.is_empty() {
            return writeln!(f, "No builders defined.");
        }

        let mut keys: Vec<&String> = self.builders.keys().collect();
        keys.sort();

        for key in keys {
            writeln!(f, "\n")?;
            write!(f, "{}", self.builders[key])?;
        }

        Ok(())
    }
}
