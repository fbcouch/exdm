defmodule Mix.Tasks.Deployment.Deploy do
  use Mix.Task
  import Logger

  @moduledoc """
  Deploys to a stage.

      mix deployment.deploy production

  The argument is the name of a stage.

  Before running, it checks the following:
  * is the application deployed to the remote host?
  * is a release available of the current version of the application?
  * if so, is it possible to upgrade from the local release from the currently
    deployed one?
  """

  @shortdoc "Deploys to the given stage"

  def run([stage]) do
    stage = String.to_atom(stage)
    case Exdm.Remote.get_version(stage) do
      {:ok, remote_version} ->
        {:ok, local_version} = Exdm.Local.get_version
        Logger.info "Upgrading #{remote_version} -> #{local_version}"
        handle_can_transition_from(stage, Exdm.Local.can_transition_from(remote_version))
      {:error, reason} ->
        Logger.info "Cannot upgrade, trying fresh deploy..."
        Exdm.deploy_fresh(stage)
        {:ok}
    end
  end

  defp handle_can_transition_from(stage, {:ok}) do
    Exdm.deploy(stage)
    {:ok}
  end

  defp handle_can_transition_from(_stage, {:error, reason}) do
    {:error, reason}
  end
end
