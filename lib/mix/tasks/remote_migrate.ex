defmodule Mix.Tasks.RemoteMigrate do
  use Mix.Task

  @shortdoc "Runs migrations on a given stage"

  def run([stage]) do
    stage
      |> String.to_atom
      |> remote_migrations
  end

  def remote_migrations(stage) do
    case Exdm.Connection.execute(stage, [boot_script_path(stage), "rpc", "Elixir.Exdm", "run_migrations"]) do
      {:ok, result} ->
        IO.puts result
      {:error, result, code} ->
        IO.puts "Error #{code}: #{result}"
    end
  end

  def boot_script_path(stage) do
    stage
      |> Exdm.Config.load!
      |> Exdm.Remote.boot_script_path!
  end
end
