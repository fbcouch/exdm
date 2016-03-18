defmodule Exdm do

  @doc """
  Deploys a local release, build with exrm, to the indicated stage.
  """
  def deploy(stage) do
    config = Exdm.Config.load!(stage)
    Exdm.Connection.upload(stage, release_tarball, remote_release_path!(config))
    boot_script_path = Exdm.Remote.boot_script_path!(config)
    Exdm.Connection.execute(stage, [boot_script_path, "upgrade", version])
  end

  @doc """
  Deploys a local release, build with exrm, to the indicated stage (first time).
  """
  def deploy_fresh(stage) do
    config = Exdm.Config.load!(stage)
    Exdm.Connection.execute(stage, ["mkdir", "-p", remote_release_path!(config)])
    Exdm.Connection.upload(stage, release_tarball, remote_release_path!(config))
    remote_tarball = Path.join([remote_release_path!(config), "#{application_name}.tar.gz"])
    application_path = Exdm.Config.application_path!(config)
    Exdm.Connection.execute(stage, ["tar", "-xzvf", remote_tarball, "-C", application_path])
    boot_script_path = Exdm.Remote.boot_script_path!(config)
    Exdm.Connection.execute(stage, [boot_script_path, "start"])
  end

  @doc """
  Runs the migrations for the MyApplication.Repo
  """
  def run_migrations do
    migration_path = Application.app_dir(String.to_atom(application_name))
      |> Path.join("priv")
      |> Path.join("repo")
      |> Path.join("migrations")
    Ecto.Migrator.run Module.concat([Mix.Utils.camelize(application_name), "Repo"]), migration_path, :up, all: true
  end

  def application_name do
    Mix.Project.config[:app] |> Atom.to_string
  end

  defp release_tarball do
    {:ok, path} = Exdm.Local.tarball_pathname
    path
  end

  defp remote_release_path!(config) do
    releases_path = Exdm.Remote.releases_path!(config)
    releases_path <> "/" <> version
  end

  defp version do
    {:ok, version} = Exdm.Local.get_version
    version
  end
end
