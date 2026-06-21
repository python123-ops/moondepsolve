///|
async fn main {
  run_command(parse_cli(@env.args()[1:])) catch {
    error => {
      @stdio.stderr.write("error: \{cli_error_text(error)}\n")
      process_exit(2)
    }
  }
}

///|
extern "c" fn process_exit(code : Int) = "exit"

///|
fn cli_error_text(error : Error) -> String {
  match error {
    Failure::Failure(message) =>
      match message.split_once(" FAILED: ") {
        Some((_, detail)) => detail.to_owned()
        None => message
      }
    _ => error.to_string()
  }
}

///|
async fn run_command(command : CliCommand) -> Unit {
  match command {
    Resolve(registry~, roots~, format~) => run_resolve(registry, roots, format)
    Plan(registry~, lock_path~, roots~, strategy~, max_states~) =>
      run_plan(registry, lock_path, roots, strategy, max_states)
  }
}

///|
async fn run_resolve(
  registry_path : String,
  roots : Array[@moondepsolve.Dependency],
  format : OutputFormat,
) -> Unit {
  let registry = load_registry(registry_path)
  let resolution = match @moondepsolve.resolve(roots, registry) {
    Ok(resolution) => resolution
    Err(error) => fail(@moondepsolve.format_error(error))
  }
  match format {
    LockOutput => @stdio.stdout.write(@moondepsolve.format_lock(resolution))
    TextOutput =>
      @stdio.stdout.write(
        @moondepsolve.format_graph_text(
          @moondepsolve.build_dependency_graph(roots, resolution),
        ),
      )
    DotOutput =>
      @stdio.stdout.write(
        @moondepsolve.format_graph_dot(
          @moondepsolve.build_dependency_graph(roots, resolution),
        ),
      )
  }
}

///|
async fn run_plan(
  registry_path : String,
  lock_path : String,
  roots : Array[@moondepsolve.Dependency],
  strategy : @moondepsolve.UpgradeStrategy,
  max_states : Int,
) -> Unit {
  let registry = load_registry(registry_path)
  let current = load_lock(lock_path)
  let plan = match
    @moondepsolve.plan_upgrade(roots, current, registry, {
      strategy,
      max_states,
    }) {
    Ok(plan) => plan
    Err(error) => fail(@moondepsolve.format_upgrade_error(error))
  }
  @stdio.stdout.write(@moondepsolve.format_upgrade_plan(plan))
  @stdio.stdout.write("target lock:\n")
  @stdio.stdout.write(@moondepsolve.format_lock(plan.resolution))
}

///|
async fn load_registry(path : String) -> @moondepsolve.Registry {
  let input = @fs.read_file(path).text()
  match @moondepsolve.parse_registry(input) {
    Ok(registry) => registry
    Err(error) => fail(@moondepsolve.format_error(error))
  }
}

///|
async fn load_lock(path : String) -> @moondepsolve.Resolution {
  let input = @fs.read_file(path).text()
  match @moondepsolve.parse_lock(input) {
    Ok(resolution) => resolution
    Err(error) => fail(@moondepsolve.format_error(error))
  }
}
