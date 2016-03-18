defmodule Mix.Tasks.Deployment.FreshDeploy do
  use Mix.Task

  @moduledoc """
  Deploys to a stage.

      mix deployment.fresh_deploy production

  The argument is the name of a stage.
  """

  @shortdoc "Deploys to the given stage"

  def run([stage]) do
    stage = String.to_atom(stage)
    Exdm.deploy_fresh(stage)
    {:ok}
  end
end
