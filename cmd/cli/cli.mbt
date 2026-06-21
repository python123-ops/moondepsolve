///|
priv enum OutputFormat {
  LockOutput
  TextOutput
  DotOutput
}

///|
priv enum CliCommand {
  Resolve(
    registry~ : String,
    roots~ : Array[@moondepsolve.Dependency],
    format~ : OutputFormat
  )
  Plan(
    registry~ : String,
    lock_path~ : String,
    roots~ : Array[@moondepsolve.Dependency],
    strategy~ : @moondepsolve.UpgradeStrategy,
    max_states~ : Int
  )
}

///|
fn parse_cli(argv : ArrayView[String]) -> CliCommand raise {
  let resolve_command = @argparse.Command(
    "resolve",
    about="Resolve dependencies from a registry file.",
    options=[
      OptionArg(
        "registry",
        about="Path to a MoonDepSolve registry file.",
        required=true,
      ),
      OptionArg(
        "root",
        about="Root dependency in NAME:REQ form; repeat as needed.",
        action=Append,
        required=true,
      ),
      OptionArg("format", about="Output format: lock, text, or dot.", default_values=[
        "lock",
      ]),
    ],
  )
  let plan_command = @argparse.Command(
    "plan",
    about="Plan dependency upgrades from an existing lock file.",
    options=[
      OptionArg(
        "registry",
        about="Path to a MoonDepSolve registry file.",
        required=true,
      ),
      OptionArg(
        "lock",
        about="Path to an existing MoonDepSolve lock file.",
        required=true,
      ),
      OptionArg(
        "root",
        about="Root dependency in NAME:REQ form; repeat as needed.",
        action=Append,
        required=true,
      ),
      OptionArg("strategy", about="Upgrade strategy: highest or minimal.", default_values=[
        "highest",
      ]),
      OptionArg(
        "max-states",
        about="Maximum states explored by minimal-change search.",
        default_values=["100000"],
      ),
    ],
  )
  let matches = @argparse.Command(
    "moondepsolve",
    about="Resolve and plan MoonBit package dependencies.",
    version="0.3.0",
    subcommands=[resolve_command, plan_command],
    subcommand_required=true,
  ).parse(argv~, env={})
  guard matches.subcommand is Some((name, values)) else {
    fail("a subcommand is required")
  }
  match name {
    "resolve" =>
      Resolve(
        registry=single_value(values, "registry"),
        roots=parse_roots(repeated_values(values, "root")),
        format=parse_output_format(single_value(values, "format")),
      )
    "plan" =>
      Plan(
        registry=single_value(values, "registry"),
        lock_path=single_value(values, "lock"),
        roots=parse_roots(repeated_values(values, "root")),
        strategy=parse_upgrade_strategy(single_value(values, "strategy")),
        max_states=parse_max_states(single_value(values, "max-states")),
      )
    _ => fail("unsupported subcommand: \{name}")
  }
}

///|
fn single_value(matches : @argparse.Matches, name : String) -> String raise {
  match matches.values.get(name) {
    Some([value]) => value
    _ => fail("expected one value for --\{name}")
  }
}

///|
fn repeated_values(
  matches : @argparse.Matches,
  name : String,
) -> Array[String] raise {
  match matches.values.get(name) {
    Some(values) if values.length() > 0 => values
    _ => fail("expected at least one --\{name}")
  }
}

///|
fn parse_roots(inputs : Array[String]) -> Array[@moondepsolve.Dependency] raise {
  let roots : Array[@moondepsolve.Dependency] = []
  for input in inputs {
    let (name, requirement) = match input.split_once(":") {
      Some((name, requirement)) =>
        (
          name.to_owned().trim().to_owned(),
          requirement.to_owned().trim().to_owned(),
        )
      None => fail("invalid root '\{input}'; expected NAME:REQ")
    }
    if name.length() == 0 || requirement.length() == 0 {
      fail("invalid root '\{input}'; expected NAME:REQ")
    }
    let req = match @moondepsolve.parse_req(requirement) {
      Ok(req) => req
      Err(error) => fail(@moondepsolve.format_error(error))
    }
    roots.push({ name, req })
  }
  roots
}

///|
fn parse_output_format(input : String) -> OutputFormat raise {
  match input {
    "lock" => LockOutput
    "text" => TextOutput
    "dot" => DotOutput
    _ => fail("invalid format '\{input}'; expected lock, text, or dot")
  }
}

///|
fn parse_upgrade_strategy(
  input : String,
) -> @moondepsolve.UpgradeStrategy raise {
  match input {
    "highest" => HighestCompatible
    "minimal" => MinimalChange
    _ => fail("invalid strategy '\{input}'; expected highest or minimal")
  }
}

///|
fn parse_max_states(input : String) -> Int raise {
  let value = @string.parse_int(input) catch {
    _ => fail("invalid max states '\{input}'; expected a positive integer")
  }
  if value <= 0 {
    fail("invalid max states '\{input}'; expected a positive integer")
  }
  value
}
