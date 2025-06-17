# prepare_book.exs

defmodule BookPreview do
  def run do
    Process.flag(:trap_exit, true)

    convert()
    clean_and_replace()
    launch_quarto()
  end

  defp convert do
    input_file = "index.ipynb"

    {out, status} = System.cmd("quarto", ["convert", input_file])

    if status != 0 do
      IO.puts("❌ Quarto convert failed.")
      System.halt(status)
    end

    IO.puts("✅ Quarto Convert done : #{out}")
  end

  defp clean_and_replace do
    output_file = "index.qmd"

    {:ok, content} = File.read(output_file)

    cleaned =
      content
      |> String.split("\n")
      |> Enum.reject(&(String.trim(&1) |> String.starts_with?("jupyter:")))
      |> Enum.map(&String.replace(&1, "AI Prompt", "Python Pro"))
      |> Enum.map(&String.replace(&1, "AI Response", "AI Mentor"))

    File.write!(output_file, Enum.join(cleaned, "\n"))
    IO.puts("✅ Replaced content and cleaned frontmatter.")
  end

  defp launch_quarto do
    port = "3314"
    IO.puts("🚀 Launching preview on http://localhost:#{port}")

    spawn(fn ->
      System.cmd("quarto", ["preview", "--port", port],
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )
    end)

    Process.sleep(:infinity)
  end
end

BookPreview.run()
