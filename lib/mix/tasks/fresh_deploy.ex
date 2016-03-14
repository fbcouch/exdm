defmodule Mix.Tasks.Deployment.FreshDeploy do
  use Mix.Task
  import Logger

  @moduledoc """
  Deploys to a stage.

      mix deployment.fresh_deploy production

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
    case Exdm.Remote.has_directory?(stage) do
      {:ok, _} ->
        Exdm.deploy_fresh(stage)
      {:error, reason} ->
        Logger.error reason
      {:error, reason, _} ->
        Logger.error reason
    end
  end
end
