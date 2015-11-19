defmodule WhiteBread.Outputers.Console do

  def start do
    spawn fn -> work end
  end

  def stop(pid) do
    send pid, {:stop, self}
    receive do
      :stop_complete -> :ok
    after
      2_000 -> :ok
    end
  end

  defp work do
    continue = receive do
      {:scenario_result, result, scenario, feature} ->
        output_scenario_result(result, scenario, feature)
      {:final_results, results} ->
        output_final_results(results)
      {:stop, caller} ->
        send caller, :stop_complete
        :stop
    end
    unless continue == :stop, do: work
  end

  defp output_scenario_result({result, _result_info}, scenario, _feature) do
    IO.puts "#{scenario.name} ---> #{result}"
    :ok
  end

  defp output_final_results(results) do
    results
      |> WhiteBread.FinalResultPrinter.text
      |> IO.puts
    :ok
  end

end
